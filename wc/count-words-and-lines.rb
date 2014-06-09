#!/usr/bin/env ruby

input = STDIN.read

lines = input.chomp.split("\n", -1).count
words = input.split.count

def pluralize(count, word)
  word += 's' unless count == 1
  '%i %s' % [count, word]
end

puts '%s in %s' % [pluralize(words, 'word'), pluralize(lines, 'line')]
