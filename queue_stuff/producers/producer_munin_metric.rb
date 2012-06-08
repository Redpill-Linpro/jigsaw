#!/usr/bin/ruby

require 'rubygems'
require 'stomp'
require 'yaml'
require 'json/add/core'
require 'munin-ruby'

unless ARGV[0] then
  abort("Provide us with a config file") 
end

begin
  @chash  = File.open( ARGV[0], 'r') { |fo| YAML.load( fo ) }
  @munin  = Munin::Node.new(@chash['munin_host'], @chash['munin_port'], true)
  @stomp  = Stomp::Client.new(@chash['stomp_user'], @chash['stomp_pass'], @chash['stomp_host'], @chash['stomp_port'])

  @munin.nodes.each do |node|
    metrics = @munin.fetch(@munin.list(node)).to_json
    Timeout::timeout(2) do
      @stomp.publish("/queue/#{@chash['stomp_queue']}.metric", metrics, :host => Socket.gethostname)
    end
  end
  rescue Timeout::Error
    STDERR.puts "Failed to send metric within the 2 second timeout"
    exit 1
  @stomp.close
end

# vim:syntax=ruby ft=ruby ts=2 sw=2 et:
