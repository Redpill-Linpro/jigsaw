#!/usr/bin/ruby

require 'rubygems'
require 'stomp'
require 'yaml'
require 'rest_client'

unless ARGV[0] then
  abort("Provide us with a config file")
end

@chash  = File.open( ARGV[0], 'r') { |fo| YAML.load( fo ) }
@stomp  = Stomp::Connection.new(@chash['stomp_user'], @chash['stomp_pass'], @chash['stomp_host'], @chash['stomp_port'])
@stomp.subscribe("/queue/#{@chash['stomp_queue']}.config")

loop do
  begin
    msg = @stomp.receive
  rescue
    STDERR.puts "Failed to receive from queue: #{$!}"
    sleep 1
    retry
  end
  data = msg.body
  host = msg.headers['host']

  # cut timestamp from message
  data = data.gsub /\d*$/, ''

  begin
    # push message to sinatra
    RestClient.put "#{@chash['sinatra_put_url']}?host=#{host}", data, {:content_type => :json}
  rescue
    STDERR.puts "Error on request: #{$!}"
  end
end

# vim:syntax=ruby ft=ruby ts=2 sw=2 et:
