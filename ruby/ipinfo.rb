# ipinfo.rb
require 'rack'
require 'rack/server'

class IPInfo
  def self.call(env)
    [ 200, {}, [env['REMOTE_ADDR']] ]
  end
end

Rack::Server.start :app => IPInfo

# http://localhost:8080
