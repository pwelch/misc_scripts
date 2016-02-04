require 'resolv'
require 'colorize'

# Checks a list of domains resolve to an expected IP
class DnsIsProbablyFine
  attr_accessor :resolv, :failed_domains
  attr_reader :domains, :expected_ips

  def initialize(domains, expected_ips)
    @resolv         = Resolv::DNS.new(:nameserver => ['8.8.8.8', '8.8.4.4'])
    @domains        = domains
    @expected_ips   = expected_ips.sort
    @failed_domains = Array.new
  end

  def check_ip(domain)
    # resolv.getaddress(domain).to_s
    %x{dig +short #{domain} @8.8.8.8}.split("\n").sort
  end

  def summary
    puts "\nFailed Domains: \n\t#{failed_domains.join("\n\t")}".colorize(:white) if failed_domains.count > 0

    puts "\nTotal: #{domains.count}".colorize(:white) +
      "\tPassed: #{domains.count - failed_domains.count}".colorize(:green) +
      "\tFailed: #{failed_domains.count}".colorize(:red)
  end

  def run
    Kernel.abort('Domains must be an Array') if !domains.is_a?(Array)
    Kernel.abort('Expected IPs must be an Array') if !expected_ips.is_a?(Array)

    domains.each do |domain|
      result = check_ip(domain)
      if result.include? expected_ips.sample
        puts "[PASS]".colorize(:green) + " #{domain} \n\tExpected: #{expected_ips.join(", ")}  Resolved: #{result.join(", ")}".colorize(:white)
      else
        failed_domains << domain
        puts "[FAIL]".colorize(:red)   + " #{domain} \n\tExpected: #{expected_ips.join(", ")}  Resolved: #{result.join(", ")}".colorize(:white)
      end
    end

    summary
  end
end

require 'yaml'
yaml_file = ARGV[0]
Kernel.abort("Path to YAML file required with the following format:\n\n#{DATA.read}") if ARGV[0].nil?
env = YAML.load_file(yaml_file)
dns_test = DnsIsProbablyFine.new(env[:domains], env[:expected_ips])
dns_test.run

__END__
---
:env: ENVIRONMENT
:expected_ips:
- IP_ADDRESS_OR_CNAME
:domains:
- domain-name1.com
- domain-name2.net
