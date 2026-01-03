# frozen_string_literal: true

require 'mkmf'
append_cflags(['-std=c99'])
create_makefile('jaro_winkler/jaro_winkler_ext')