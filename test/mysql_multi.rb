require 'rubygems'
require 'bundler/setup'
require 'eventmachine'
require 'mysql2/em'

require File.expand_path('../../lib/pool',  __FILE__)
require File.expand_path('../../lib/multi', __FILE__)

EM.run do
  multi = Multi.new

  multi.callback do |result|
    puts "succeeded: #{result.inspect}"
    EM.stop
  end

  multi.execute({
    :a => 'select sleep(0.8)',
    :b => 'select 1 as foo',
    :c => 'select md5(\'test\')',
    :d => 'select rand()',
    :e => 'select sleep(0.3)'
  })
end
