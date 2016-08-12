#!/usr/bin/env ruby
require 'json'

# aws ec2 describe-instances --region=us-east-1 > us-east-1_ec2.json
# aws rds describe-db-instances --region=us-east-1 > us-east-1_rds.json

def stringify_tags(array_hash)
  tags = array_hash.map { |x| x["Value"] }
  tags.join(' ')
end

def print_info(instances)
  @rds = true if instances["DBInstances"]
  if @rds
    instances["DBInstances"].each do |rds|
      puts "Type: #{rds["DBInstanceClass"]} AZ: #{rds["AvailabilityZone"]} ID: #{rds["DBInstanceIdentifier"]}"
    end
  else # assume EC2
    instances["Reservations"].each do |ec2|
      puts "Type: #{ec2["Instances"].first["InstanceType"]} AZ: #{ec2["Instances"].first["Placement"]["AvailabilityZone"]} Tags: #{stringify_tags(ec2["Instances"].first["Tags"])}"
    end
  end
end

file = ARGV[0]

if !File.exist?(file)
  puts "Unable to load file: #{file}"
  exit 1
end

list = JSON.parse(File.read(file))

print_info(list)
