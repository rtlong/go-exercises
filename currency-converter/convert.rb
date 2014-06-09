#!/usr/bin/env ruby

require 'json'

RATES = JSON.parse(File.read('rates.json'))

value, from_curr, to_curr = ARGV
unless value && from_curr && to_curr
  warn "Please supply a value, its currency, and a target currency"
end
value = value.to_f

def rate(from_curr, to_curr)
  if RATES.key?(from_curr) and RATES.fetch(from_curr).key?(to_curr)
    return RATES.fetch(from_curr).fetch(to_curr)
  elsif RATES.key?(to_curr) and RATES.fetch(to_curr).key?(from_curr)
    return 1.0 / RATES.fetch(to_curr).fetch(from_curr)
  else
    raise "No rate found for conversion from #{from_curr} to #{to_curr}"
  end
end

new_value = value * rate(from_curr, to_curr)

puts '%0.2f %s' % [new_value, to_curr]
