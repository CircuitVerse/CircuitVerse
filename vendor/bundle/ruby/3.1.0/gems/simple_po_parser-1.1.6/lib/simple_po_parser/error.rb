# encoding: utf-8

module SimplePoParser
	class ParserError < StandardError
	end

	class PoSyntaxError < ParserError
		@msg = ""
		def initialize(msg="Invalid po syntax")
			@msg = msg
			super(msg)
		end

	end
end
