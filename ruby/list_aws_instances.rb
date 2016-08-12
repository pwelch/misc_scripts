#!/usr/bin/env ruby
require 'json'
require 'csv'

# aws ec2 describe-instances --region=us-east-1 > us-east-1.json
# aws rds describe-db-instances --region=us-east-1 > us-east-1_rds.json

def stringify_tags(array_hash)
  tags = array_hash.map { |x| x["Value"] }
  tags.join(' ')
end

def print_info(instances)
  if instances["DBInstances"]
    instances["DBInstances"].each do |rds|
      puts "Type: rds Size: #{rds["DBInstanceClass"]} AZ: #{rds["AvailabilityZone"]} ID: #{rds["DBInstanceIdentifier"]}"
    end
  else # assume EC2
    instances["Reservations"].each do |ec2|
      puts "Type: ec2 Size: #{ec2["Instances"].first["InstanceType"]} AZ: #{ec2["Instances"].first["Placement"]["AvailabilityZone"]} Tags: #{stringify_tags(ec2["Instances"].first["Tags"])}"
    end
  end
end

def write_info(instances, file)
  CSV.open("file.csv", "a+") do |csv|
    if instances.has_key?("DBInstances")
      instances["DBInstances"].each do |rds|
        csv << [ 'RDS', rds["DBInstanceClass"], rds["AvailabilityZone"], rds["DBInstanceIdentifier"] ]
      end
    else # assume EC2
      instances["Reservations"].each do |ec2|
        csv << [ 'EC2', ec2["Instances"].first["InstanceType"], ec2["Instances"].first["Placement"]["AvailabilityZone"], stringify_tags(ec2["Instances"].first["Tags"]) ]
      end
    end
  end
end

#file = ARGV[0]
#
#if !File.exist?(file)
#  puts "Unable to load file: #{file}"
#  exit 1
#end

files = Dir.glob('*.json')
files.each do |file|
  list = JSON.parse(File.read(file))
#   print_info(list)
  write_info(list, file)
end

puts "Done."

