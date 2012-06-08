#!/usr/bin/ruby

require 'rubygems'
require 'stomp'
require 'yaml'
require 'json/add/core'

unless ARGV[0] then
  abort("Provide us with a config file")
end

@chash  = File.open( ARGV[0], 'r') { |fo| YAML.load( fo ) }

@graphite = TCPSocket.open(@chash['graphite_host'], @chash['graphite_port'])

@stomp  = Stomp::Connection.new(@chash['stomp_user'], @chash['stomp_pass'], @chash['stomp_host'], @chash['stomp_port'])

@stomp.subscribe("/queue/#{@chash['stomp_queue']}.metric")

loop do
  begin
    msg = @stomp.receive
    metrics = JSON.restore(msg.body)

    # reverse the metric key for graphite
    metrics_host = msg.headers.fetch('host').split('.')
    metrics_host = metrics_host.reverse.join('.')

    metrics_timestamp = msg.headers.fetch('timestamp') 

    metrics.each do |k,v|
      v.each do |w,x|
        m = "%s.%s.%s.%s %s %d" % ['munin', metrics_host, k, w, x, Time.now.utc.to_i]
        puts m
        @graphite.puts m
      end
    end

  rescue
    STDERR.puts "Failed to receive from queue: #{$!}"
    sleep 1
    retry
  end
end

# vim:syntax=ruby ft=ruby ts=2 sw=2 et:
