require "open3"
require "socket"
require "tempfile"
require "timeout"
require "bundler/setup"
require "bundler/gem_tasks"

APP_READY_TIMEOUT ||= 30

def sh!(cmd)
  unless system(cmd)
    raise "[#{cmd}] failed with exit code #{$?.exitstatus}"
  end
end

def app_ready?(pid, port)
  Process.getpgid(pid) && port_open?(port)
rescue Errno::ESRCH
  false
end

def create_app(name, env = {})
  puts "[#{name}] Creating Rails app"
  rails_new_options = %w[-A -G -C -T -J -S --skip-spring --skip-listen --skip-bootsnap --skip-action-mailbox --skip-jbuilder --skip-active-storage]
  rails_new_options << "-O" if name == "idp"
  env.merge!("RUBY_SAML_VERSION" => OneLogin::RubySaml::VERSION)
  Dir.chdir(working_directory) do
    FileUtils.rm_rf(name)
    puts("[#{working_directory}] rails _#{Rails.version}_ new #{name} #{rails_new_options.join(" ")} -m #{File.expand_path("../#{name}_template.rb", __FILE__)}")
    system(env, "rails", "_#{Rails.version}_", "new", name, *rails_new_options, "-m", File.expand_path("../#{name}_template.rb", __FILE__))
  end
end

def start_app(name, port, options = {})
  puts "[#{name}] Starting Rails app"
  pid = nil
  app_bundle_install(name)

  with_clean_env do
    Dir.chdir(app_dir(name)) do
      pid = Process.spawn(app_env(name), "bundle exec rails server -p #{port} -e test", chdir: app_dir(name), out: "log/#{name}.log", err: "log/#{name}.err.log")
      begin
        Timeout.timeout(APP_READY_TIMEOUT) do
          sleep 1 until app_ready?(pid, port)
        end
        if app_ready?(pid, port)
          puts "[#{name}] Launched #{name} on port #{port} (pid #{pid})..."
        else
          raise "#{name} failed after starting"
        end
      rescue Timeout::Error
        raise "#{name} failed to start"
      end
    end
  end
  pid
rescue RuntimeError => e
  warn "=== #{name}"
  Dir.chdir(app_dir(name)) do
    warn File.read("log/#{name}.log") if File.exist?("log/#{name}.log")
    warn File.read("log/#{name}.err.log") if File.exist?("log/#{name}.err.log")
  end
  raise e
end

def stop_app(name, pid)
  if pid
    Process.kill(:INT, pid)
    Process.wait(pid)
  end
  Dir.chdir(app_dir(name)) do
    if File.exist?("log/#{name}.log")
      puts "=== [#{name}] stdout"
      puts File.read("log/#{name}.log")
    end
    if File.exist?("log/#{name}.err.log")
      warn "=== [#{name}] stderr"
      warn File.read("log/#{name}.err.log")
    end
    if File.exist?("log/test.log")
      puts "=== [#{name}] Rails logs"
      puts File.read("log/test.log")
    end
  end
end

def port_open?(port)
  Timeout::timeout(1) do
    begin
      s = TCPSocket.new('localhost', port)
      s.close
      return true
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::EADDRNOTAVAIL
      # try 127.0.0.1
    end
    begin
      s = TCPSocket.new('127.0.0.1', port)
      s.close
      return true
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
      return false
    end
  end
rescue Timeout::Error
  false
end

def app_bundle_install(name)
  with_clean_env do
    Open3.popen3(app_env(name), "bundle install", chdir: app_dir(name)) do |stdin, stdout, stderr, thread|
      stdin.close
      exit_status = thread.value

      puts stdout.read
      warn stderr.read
      raise "bundle install failed" unless exit_status.success?
    end
  end
end

def app_dir(name)
  File.join(working_directory, name)
end

def app_env(name)
  {"BUNDLE_GEMFILE" => File.join(app_dir(name), "Gemfile"), "RAILS_ENV" => "test"}
end

def working_directory
  $working_directory ||= Dir.mktmpdir("dsa_test")
end

def with_clean_env(&blk)
  if Bundler.respond_to?(:with_original_env)
    Bundler.with_original_env(&blk)
  else
    Bundler.with_clean_env(&blk)
  end
end
