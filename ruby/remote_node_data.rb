#! /usr/bin/env ruby
# Fetch Node Data from Serverless Chef or Puppet nodes
require 'bundler/inline'
require 'fileutils'

gemfile true do
  source 'https://rubygems.org'
  gem 'sshkit'
end
require 'sshkit/dsl'

class ProfilerData
  attr_accessor :hosts, :username
  attr_reader   :config, :log_level

  def initialize(hosts, username, log_level=nil)
    @hosts     = hosts
    @username  = username
    @config    = configure
    @log_level = log_level
  end

  def configure
    SSHKit.config.output_verbosity = log_level if log_level
    SSHKit::Backend::Netssh.configure do |ssh|
      ssh.connection_timeout = 30
      ssh.ssh_options = {
         user:         username,
         auth_methods: ['publickey']
      }
    end
  end

  def run
    raise 'Provide a list of hosts' if hosts.nil?
    FileUtils::mkdir_p 'nodes' if !Dir.exists?('nodes')

    on hosts do |host|
      node_data = Hash.new

      if test('which ohai')
         node_data = capture(:ohai).strip
      elsif test('which facter')
        node_data = capture(:facter, '--json').strip
      else
        node_data = Hash.new
      end

      puts "Creating node data for #{host}"
      File.open("nodes/#{host}.json","w") { |f| f.write(node_data) }
    end
  end
end

HOSTS         = []
DEFAULT_USER = ENV['USER']

profiler = ProfilerData.new(HOSTS, DEFAULT_USER)
profiler.run
