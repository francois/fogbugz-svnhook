$:.unshift File.dirname(__FILE__)

require "fogbugz_svnhook/login"

module FogbugzSvnhook
  class << self
    def login(options)
      FogbugzSvnhook::Login.new(options).run
    end

    def logout(options)
      FogbugzSvnhook::Logout.new(options).run
    end
  end 
end
