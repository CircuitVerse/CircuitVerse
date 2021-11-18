# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

# This module is intended to provide access to information about the host OS and
# [virtual] machine. It intentionally does no caching and maintains no state -
# caching should be handled by clients if needed. Methods should return nil if
# the requested information is unavailable.

require 'rbconfig'
require 'socket'

module NewRelic
  module Agent
    module SystemInfo
      def self.ruby_os_identifier
        RbConfig::CONFIG['target_os']
      end

      def self.darwin?
        !!(ruby_os_identifier =~ /darwin/i)
      end

      def self.linux?
        !!(ruby_os_identifier =~ /linux/i)
      end

      def self.bsd?
        !!(ruby_os_identifier =~ /bsd/i)
      end

      @processor_info = nil

      def self.ip_addresses
        Socket.ip_address_list.map(&:ip_address)
      end

      def self.clear_processor_info
        @processor_info = nil
      end

      def self.get_processor_info
        if @processor_info.nil?
          if darwin?
            @processor_info = {
              :num_physical_packages  => sysctl_value('hw.packages').to_i,
              :num_physical_cores     => sysctl_value('hw.physicalcpu_max').to_i,
              :num_logical_processors => sysctl_value('hw.logicalcpu_max').to_i
            }
            # in case those don't work, try backup values
            if @processor_info[:num_physical_cores] <= 0
              @processor_info[:num_physical_cores] = sysctl_value('hw.physicalcpu').to_i
            end
            if @processor_info[:num_logical_processors] <= 0
              @processor_info[:num_logical_processors] = sysctl_value('hw.logicalcpu').to_i
            end
            if @processor_info[:num_logical_processors] <= 0
              @processor_info[:num_logical_processors] = sysctl_value('hw.ncpu').to_i
            end

          elsif linux?
            cpuinfo = proc_try_read('/proc/cpuinfo')
            @processor_info = cpuinfo ? parse_cpuinfo(cpuinfo) : {}

          elsif bsd?
            @processor_info = {
              :num_physical_packages  => nil,
              :num_physical_cores     => nil,
              :num_logical_processors => sysctl_value('hw.ncpu').to_i
            }
          end

          # give nils for obviously wrong values
          @processor_info.keys.each do |key|
            value = @processor_info[key]
            if value.is_a?(Numeric) && value <= 0
              @processor_info[key] = nil
            end
          end
        end

        @processor_info
      rescue
        {}
      end

      def self.sysctl_value(name)
        # make sure to redirect stderr so we don't spew if the name is unknown
        `sysctl -n #{name} 2>/dev/null`
      end

      def self.parse_cpuinfo(cpuinfo)
        # Build a hash of the form
        #   { [phys_id, core_id] => num_logical_processors_on_this_core }
        cores = Hash.new(0)
        phys_id = core_id = nil

        total_processors = 0

        cpuinfo.split("\n").map(&:strip).each do |line|
          case line
          when /^processor\s*:/
            cores[[phys_id, core_id]] += 1 if phys_id && core_id
            phys_id = core_id = nil # reset these values
            total_processors += 1
          when /^physical id\s*:(.*)/
            phys_id = $1.strip.to_i
          when /^core id\s*:(.*)/
            core_id = $1.strip.to_i
          end
        end
        cores[[phys_id, core_id]] += 1 if phys_id && core_id

        num_physical_packages  = cores.keys.map(&:first).uniq.size
        num_physical_cores     = cores.size
        num_logical_processors = cores.values.reduce(0,:+)

        if num_physical_cores == 0
          num_logical_processors = total_processors

          if total_processors == 0
            # Likely a malformed file.
            num_logical_processors = nil
          end

          if total_processors == 1
            # Some older, single-core processors might not list ids,
            # so we'll just mark them all 1.
            num_physical_packages = 1
            num_physical_cores    = 1
          else
            # We have no way of knowing how many packages or cores
            # we have, even though we know how many processors there are.
            num_physical_packages = nil
            num_physical_cores    = nil
          end
        end

        {
          :num_physical_packages  => num_physical_packages,
          :num_physical_cores     => num_physical_cores,
          :num_logical_processors => num_logical_processors
        }
      end

      def self.num_physical_packages ; get_processor_info[:num_physical_packages ] end
      def self.num_physical_cores    ; get_processor_info[:num_physical_cores    ] end
      def self.num_logical_processors; get_processor_info[:num_logical_processors] end

      def self.processor_arch
        RbConfig::CONFIG['target_cpu']
      end

      def self.os_version
        proc_try_read('/proc/version')
      end

      def self.docker_container_id
        return unless ruby_os_identifier =~ /linux/

        cgroup_info = proc_try_read('/proc/self/cgroup')
        return unless cgroup_info

        parse_docker_container_id(cgroup_info)
      end

      def self.parse_docker_container_id(cgroup_info)
        cpu_cgroup = parse_cgroup_ids(cgroup_info)['cpu']
        return unless cpu_cgroup

        container_id = case cpu_cgroup
        # docker native driver w/out systemd (fs)
        when /[0-9a-f]{64,}/
          if $&.length == 64
            $&
          else # container ID is too long
            ::NewRelic::Agent.logger.debug("Ignoring docker ID of invalid length: '#{cpu_cgroup}'")
            return
          end
        # docker native driver with systemd
        when '/'              then nil
        # in a cgroup, but we don't recognize its format
        when /docker\/.*[^0-9a-f]/ then
          ::NewRelic::Agent.logger.debug("Cgroup indicates docker but container_id has invalid characters: '#{cpu_cgroup}'")
          return
        when /docker/ then
          ::NewRelic::Agent.logger.debug("Cgroup indicates docker but container_id unrecognized: '#{cpu_cgroup}'")
          ::NewRelic::Agent.increment_metric "Supportability/utilization/docker/error"
          return
        else
          ::NewRelic::Agent.logger.debug("Ignoring unrecognized cgroup ID format: '#{cpu_cgroup}'")
          return
        end

        if container_id && container_id.size != 64
          ::NewRelic::Agent.logger.debug("Found docker container_id with invalid length: #{container_id}")
          ::NewRelic::Agent.increment_metric "Supportability/utilization/docker/error"
          nil
        else
          container_id
        end
      end

      def self.parse_cgroup_ids(cgroup_info)
        cgroup_ids = {}

        cgroup_info.split("\n").each do |line|
          parts = line.split(':')
          next unless parts.size == 3
          _, subsystems, cgroup_id = parts
          subsystems = subsystems.split(',')
          subsystems.each do |subsystem|
            cgroup_ids[subsystem] = cgroup_id
          end
        end

        cgroup_ids
      end

      # A File.read against /(proc|sysfs)/* can hang with some older Linuxes.
      # See https://bugzilla.redhat.com/show_bug.cgi?id=604887, RUBY-736, and
      # https://github.com/opscode/ohai/commit/518d56a6cb7d021b47ed3d691ecf7fba7f74a6a7
      # for details on why we do it this way.
      def self.proc_try_read(path)
        return nil unless File.exist?(path)
        content = ''
        File.open(path) do |f|
          loop do
            begin
              content << f.read_nonblock(4096)
            rescue EOFError
              break
            rescue Errno::EWOULDBLOCK, Errno::EAGAIN
              content = nil
              break # don't select file handle, just give up
            end
          end
        end
        content
      end

      def self.ram_in_mib
        if darwin?
          (sysctl_value('hw.memsize').to_i / (1024 ** 2)).to_i
        elsif linux?
          meminfo = proc_try_read('/proc/meminfo')
          parse_linux_meminfo_in_mib(meminfo)
        elsif bsd?
          (sysctl_value('hw.realmem').to_i / (1024 ** 2)).to_i
        else
          ::NewRelic::Agent.logger.debug("Unable to determine ram_in_mib for host os: #{ruby_os_identifier}")
          nil
        end
      end

      def self.parse_linux_meminfo_in_mib(meminfo)
        if meminfo && mem_total = meminfo[/MemTotal:\s*(\d*)\skB/,1]
          (mem_total.to_i / 1024).to_i
        else
          ::NewRelic::Agent.logger.debug("Failed to parse MemTotal from /proc/meminfo: #{meminfo}")
          nil
        end
      end

      def self.boot_id
        return nil unless linux?
        if bid = proc_try_read('/proc/sys/kernel/random/boot_id')
          bid.chomp!

          if bid.ascii_only?
            if bid.empty?
              ::NewRelic::Agent.logger.debug("boot_id not found in /proc/sys/kernel/random/boot_id")
              ::NewRelic::Agent.increment_metric "Supportability/utilization/boot_id/error"
              nil

            elsif bid.bytesize == 36
              bid

            else
              ::NewRelic::Agent.logger.debug("Found boot_id with invalid length: #{bid}")
              ::NewRelic::Agent.increment_metric "Supportability/utilization/boot_id/error"
              bid[0,128]

            end
          else
            ::NewRelic::Agent.logger.debug("Found boot_id with non-ASCII characters: #{bid}")
            ::NewRelic::Agent.increment_metric "Supportability/utilization/boot_id/error"
            nil

          end
        else
          ::NewRelic::Agent.logger.debug("boot_id not found in /proc/sys/kernel/random/boot_id")
          ::NewRelic::Agent.increment_metric "Supportability/utilization/boot_id/error"
          nil

        end
      end
    end
  end
end
