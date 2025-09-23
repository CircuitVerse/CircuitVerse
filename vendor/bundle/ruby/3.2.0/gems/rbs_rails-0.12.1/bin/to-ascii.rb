#!ruby

ARGV.each do |p|
  File.write p, File.read(p).gsub(/[^[:ascii:]]+/, '(trim non-ascii characters)')
end
