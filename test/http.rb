require 'rubygems'
require 'bundler/setup'

require 'eventmachine'
require 'em-http-request'

require File.expand_path('../../lib/pool', __FILE__)

EM.run do
  pool = Pool.new { EM::HttpRequest.new('http://www.google.com') }
  done = 0
  20.times do |i|
    n = "%02d" % i
    pool.execute do |client|
      puts "queued query #{n}"

      client.get({ :path => '/', :keepalive => true }).tap do |request|
        request.callback do
          puts "result query #{n} -> done"
          done += 1
          EM.stop if done >= 20
        end
      end
    end
  end
end
