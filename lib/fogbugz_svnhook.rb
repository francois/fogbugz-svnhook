$:.unshift File.dirname(__FILE__)

require "fogbugz_svnhook/login"
require "fogbugz_svnhook/logoff"

module FogbugzSvnhook
  class << self
    def login(options)
      FogbugzSvnhook::Login.new(options).run
    end

    def logoff(options)
      FogbugzSvnhook::Logoff.new(options).run
    end
  end 
end
