#!/usr/bin/env ruby
# vi:syntax=ruby
require 'minitest'
require 'optparse'
require 'yaml'

## Spiking a script to deploy to multiple chef environments

class DeployCommands
  def self.install_libraries
    Kernel.system <<-CMD
      echo "*** ChefDK Info:" && chef --version &&
      echo "*** Running bundle install..." &&
      /opt/chefdk/embedded/bin/bundle      &&
      echo "*** Running berks install..."  &&
      /opt/chefdk/embedded/bin/berks install
    CMD
  end
end
module ChefDeploy
  class Config
    def self.load(file_path)
      YAML.load_file(file_path)
    end
  end
end
# Tests - Run with -u
class ChefDeployTest < MiniTest::Test
  def test_deploy_commands_class
    assert DeployCommands
  end
end
# Options Parser
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: chef-deploy [options]"
  opts.on("-c", "--config /path/to/config", String, 'Config File') do |c|
    options[:config] = c || nil
    if !File.exist?(options[:config]) || options[:config].nil?
      puts "Unable to find file #{options[:confog]} \nFile should be in this format:"
      DATA.each_line {|l| puts l}; exit 1
    end
  end
  opts.on("-u", "--unit-tests", 'Run code unit tests for this program') do |u|
    Minitest.run == true ? (puts "Tests Passed!"; exit 0) : (puts "Tests Failed!"; exit 1)
  end
end.parse!(ARGV)
if ENV['PATH'].split(':')[0] != '/opt/chefdk/bin'
  raise StandardError::RuntimeError, 'ChefDK not first in PATH. Please run "eval "$(chef shell-init bash)"'
end
# Run
# DeployCommands.install_libraries
# Config File Example
__END__
---
env: ENVIRONMENT_NAME
chef_envs:
  - PATH_TO_CHEF_ENV_TO_UPLOAD
chef_roles:
  - PATH_TO_CHEF_ROLE_TO_UPLOAD
chef_data_bags:
  - PATH_TO_CHEF_DATA_BAG_TO_UPLOAD
