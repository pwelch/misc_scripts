require 'net/https'

def check_cert(url)
  uri  = URI.parse(url)
  http = Net::HTTP.new(uri.host,uri.port)
  http.use_ssl     = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  http.start { |h| @cert = h.peer_cert }

puts <<EOD
  Subject: #{@cert.subject}
  Issuer:  #{@cert.issuer}
  Serial:  #{@cert.serial}
  Issued:  #{@cert.not_before}
  Expires: #{@cert.not_after}

EOD
end

%w{
  https://www.example.com
}.each do |host|
  check_cert(host)
end
