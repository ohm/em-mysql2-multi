require 'rubygems'
require 'bundler/setup'

require 'eventmachine'
require 'mysql2/em'

require File.expand_path('../../lib/pool', __FILE__)

EM.run do
  pool = Pool.new { Mysql2::EM::Client.new }

  done = 0
  20.times do |i|
    n = "%02d" % i
    pool.execute do |client|
      puts "queued query #{n}"
      sql = "select sleep(%d) as query_%s" % [ rand(5), n ]
      client.query(sql).tap do |query|
        query.callback do |result|
          puts "result query #{n} -> #{result.to_a.inspect}"
          done += 1
          EM.stop if done >= 20
        end
      end
    end
  end
end
