#!/usr/bin/ruby
 
require 'rubygems'
require 'stomp'
require 'json/add/core'
require 'yaml'
require 'munin-ruby'
require 'pp'

unless ARGV[0] then
  abort("Provide us with a config file")
end

@config = Hash.new

begin
  @chash  = File.open( ARGV[0], 'r') { |fo| YAML.load( fo ) }
  @munin  = Munin::Node.new(@chash['munin_host'], @chash['munin_port'], true)
  @stomp  = Stomp::Client.new(@chash['stomp_user'], @chash['stomp_pass'], @chash['stomp_host'], @chash['stomp_port'])

  @munin.nodes.each do |node|
    @config[node] = @munin.config(@munin.list(node)).to_hash
  end

  @config_json = JSON.pretty_generate(@config)

  @msg = "%s %d" % [@config_json, Time.now.utc.to_i]

  Timeout::timeout(2) do
    @stomp.publish("/queue/#{@chash['stomp_queue']}.config", @msg, :host => Socket.gethostname)
  end
  
  puts @msg

  @stomp.close
end

# vim:syntax=ruby ft=ruby ts=2 sw=2 et:
