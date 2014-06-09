#!/usr/bin/env ruby

input = ARGV[0]

unless input and input.match(/\A-?\d+\z/)
  raise ArgumentError, 'give one integer'
end

input = input.to_i
if input < 0 then
  raise ArgumentError, 'must be positive'
end

puts 1 if input == 0
puts 1.upto(input).inject(:*)
