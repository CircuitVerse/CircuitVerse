require 'mkmf'

$CXXFLAGS += " -std=c++11 "
$CXXFLAGS += " -g -O1 -ggdb "
$CFLAGS += " -g -O1 -ggdb "

if ENV['DEBUG']
  $CXXFLAGS += "  -DDEBUG "
  $CFLAGS += "  -DDEBUG "
end

create_makefile('html_tokenizer_ext')
