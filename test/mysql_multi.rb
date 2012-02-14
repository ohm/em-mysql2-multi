require 'rubygems'
require 'bundler/setup'

require 'eventmachine'
require 'mysql2/em'

require File.expand_path('../../lib/pool',  __FILE__)
require File.expand_path('../../lib/multi', __FILE__)

EM.run do
  mq = Multi.new(Pool.new { Mysql2::EM::Client.new })

  mq.callback do |result|
    puts "succeeded: #{result.inspect}"
    EM.stop
  end

  mq.execute({
    :test => 'select 1 as foo',
    :bar  => 'select sleep(1)',
    :baz  => 'select md5(\'test\')'
  })
end
