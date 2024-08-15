
# -*- ruby -*-
# frozen_string_literal: true

# The top-level PG namespace.
module PG

	# Is this file part of a fat binary gem with bundled libpq?
	bundled_libpq_path = File.join(__dir__, RUBY_PLATFORM.gsub(/^i386-/, "x86-"))
	if File.exist?(bundled_libpq_path)
		POSTGRESQL_LIB_PATH = bundled_libpq_path
	else
		bundled_libpq_path = nil
		# Try to load libpq path as found by extconf.rb
		begin
			require "pg/postgresql_lib_path"
		rescue LoadError
			# rake-compiler doesn't use regular "make install", but uses it's own install tasks.
			# It therefore doesn't copy pg/postgresql_lib_path.rb in case of "rake compile".
			POSTGRESQL_LIB_PATH = false
		end
	end

	add_dll_path = proc do |path, &block|
		if RUBY_PLATFORM =~/(mswin|mingw)/i && path && File.exist?(path)
			begin
				require 'ruby_installer/runtime'
				RubyInstaller::Runtime.add_dll_directory(path, &block)
			rescue LoadError
				old_path = ENV['PATH']
				ENV['PATH'] = "#{path};#{old_path}"
				block.call
				ENV['PATH'] = old_path
			end
		else
			# No need to set a load path manually - it's set as library rpath.
			block.call
		end
	end

	# Add a load path to the one retrieved from pg_config
	add_dll_path.call(POSTGRESQL_LIB_PATH) do
		if bundled_libpq_path
			# It's a Windows binary gem, try the <major>.<minor> subdirectory
			major_minor = RUBY_VERSION[ /^(\d+\.\d+)/ ] or
				raise "Oops, can't extract the major/minor version from #{RUBY_VERSION.dump}"
			require "#{major_minor}/pg_ext"
		else
			require 'pg_ext'
		end
	end


	class NotAllCopyDataRetrieved < PG::Error
	end
	class NotInBlockingMode < PG::Error
	end

	# Get the PG library version.
	#
	# +include_buildnum+ is no longer used and any value passed will be ignored.
	def self.version_string( include_buildnum=nil )
		"%s %s" % [ self.name, VERSION ]
	end


	### Convenience alias for PG::Connection.new.
	def self.connect( *args, &block )
		Connection.new( *args, &block )
	end


	require 'pg/exceptions'
	require 'pg/constants'
	require 'pg/coder'
	require 'pg/binary_decoder'
	require 'pg/text_encoder'
	require 'pg/text_decoder'
	require 'pg/basic_type_registry'
	require 'pg/basic_type_map_based_on_result'
	require 'pg/basic_type_map_for_queries'
	require 'pg/basic_type_map_for_results'
	require 'pg/type_map_by_column'
	require 'pg/connection'
	require 'pg/result'
	require 'pg/tuple'
	require 'pg/version'

end # module PG
