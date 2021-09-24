# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'new_relic/language_support'

module NewRelic
  # A singleton for shared generic helper methods
  module Helper
    extend self

    # Confirm a string is correctly encoded,
    # If not force the encoding to ASCII-8BIT (binary)
    def correctly_encoded(string)
      return string unless string.is_a? String
      # The .dup here is intentional, since force_encoding mutates the target,
      # and we don't know who is going to use this string downstream of us.
      string.valid_encoding? ? string : string.dup.force_encoding(Encoding::ASCII_8BIT)
    end

    def instance_method_visibility(klass, method_name)
      if klass.private_instance_methods.map{|s|s.to_sym}.include? method_name.to_sym
        :private
      elsif klass.protected_instance_methods.map{|s|s.to_sym}.include? method_name.to_sym
        :protected
      else
        :public
      end
    end

    def instance_methods_include?(klass, method_name)
      method_name_sym = method_name.to_sym
      (
        klass.instance_methods.map{ |s| s.to_sym }.include?(method_name_sym)          ||
        klass.protected_instance_methods.map{ |s|s.to_sym }.include?(method_name_sym) ||
        klass.private_instance_methods.map{ |s|s.to_sym }.include?(method_name_sym)
      )
    end

    def time_to_millis(time)
      (time.to_f * 1000).round
    end
  end
end
