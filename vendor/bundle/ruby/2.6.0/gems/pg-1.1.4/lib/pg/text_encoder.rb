# -*- ruby -*-

require 'json'
require 'ipaddr'

module PG
	module TextEncoder
		class Date < SimpleEncoder
			STRFTIME_ISO_DATE = "%Y-%m-%d".freeze
			def encode(value)
				value.respond_to?(:strftime) ? value.strftime(STRFTIME_ISO_DATE) : value
			end
		end

		class TimestampWithoutTimeZone < SimpleEncoder
			STRFTIME_ISO_DATETIME_WITHOUT_TIMEZONE = "%Y-%m-%d %H:%M:%S.%N".freeze
			def encode(value)
				value.respond_to?(:strftime) ? value.strftime(STRFTIME_ISO_DATETIME_WITHOUT_TIMEZONE) : value
			end
		end

		class TimestampUtc < SimpleEncoder
			STRFTIME_ISO_DATETIME_WITHOUT_TIMEZONE_UTC = "%Y-%m-%d %H:%M:%S.%N".freeze
			def encode(value)
				value.respond_to?(:utc) ? value.utc.strftime(STRFTIME_ISO_DATETIME_WITHOUT_TIMEZONE_UTC) : value
			end
		end

		class TimestampWithTimeZone < SimpleEncoder
			STRFTIME_ISO_DATETIME_WITH_TIMEZONE = "%Y-%m-%d %H:%M:%S.%N %:z".freeze
			def encode(value)
				value.respond_to?(:strftime) ? value.strftime(STRFTIME_ISO_DATETIME_WITH_TIMEZONE) : value
			end
		end

		class Numeric < SimpleEncoder
			def encode(value)
				value.is_a?(BigDecimal) ? value.to_s('F') : value
			end
		end

		class JSON < SimpleEncoder
			def encode(value)
				::JSON.generate(value, quirks_mode: true)
			end
		end

		class Inet < SimpleEncoder
			def encode(value)
				case value
				when IPAddr
					default_prefix = (value.family == Socket::AF_INET ? 32 : 128)
					s = value.to_s
                                        if value.respond_to?(:prefix)
						prefix = value.prefix
                                        else
						range = value.to_range
						prefix  = default_prefix - Math.log(((range.end.to_i - range.begin.to_i) + 1), 2).to_i
                                        end
					s << "/" << prefix.to_s if prefix != default_prefix
					s
				else
					value
				end
			end
		end
	end
end # module PG

