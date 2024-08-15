#!/usr/bin/env ruby

$: << '.'
$: << File.join(File.dirname(__FILE__), "../lib")
$: << File.join(File.dirname(__FILE__), "../ext")

require "oj"
require "socket"
require 'io/nonblock'

=begin
#pid = spawn("nc -d 0.1 -l 5000", out: "/dev/null")
pid = spawn("nc -i 1 -l 7777", out: "/dev/null")
at_exit { Process.kill 9, pid }
sleep 0.2
s = Socket.tcp("localhost", 7777)
#s.nonblock = false
1_000_000.times do |x|
  Oj.to_stream(s, { x: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]})
end
=end

=begin
IO.pipe do |r, w|
  if fork
    r.close
    #w.nonblock = false
    1_000_000.times do |i|
      begin
	Oj.to_stream(w, { x: i})
      rescue IOError => e
	puts "*** #{i} raised #{e.class}: #{e}"
	IO.select(nil, [w])
	retry
      end
      w.puts
    end
  else
    w.close
    sleep(0.1)
    r.each_line { |b|
      #print b
    }
    r.close
    Process.exit(0)
  end
end
=end

IO.pipe do |r, w|
  if fork
    r.close
    #w.nonblock = false
    a = []
    10_000.times do |i|
      a << i
    end
    begin
      Oj.to_stream(w, a, indent: 2)
    rescue IOError => e
      puts "*** raised #{e.class}: #{e}"
      puts "*** fileno: #{w.fileno}"
      puts "*** is an IO?: #{w.kind_of?(IO)}"
      IO.select(nil, [w])
      retry
    end
    w.puts
  else
    w.close
    sleep(0.5)
    r.each_line { |b|
      #print b
    }
    r.close
    Process.exit(0)
  end
end
