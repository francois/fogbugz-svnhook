$:.unshift File.dirname(__FILE__)

require "fogbugz_svnhook/login"
require "fogbugz_svnhook/logoff"
require "fogbugz_svnhook/pre_commit"
require "fogbugz_svnhook/post_commit"

module FogbugzSvnhook
  class << self
    def login(options)
      FogbugzSvnhook::Login.new(options).run
    end

    def logoff(options)
      FogbugzSvnhook::Logoff.new(options).run
    end

    def pre_commit(options)
      FogbugzSvnhook::PreCommit.new(options).run
    end

    def post_commit(options)
      FogbugzSvnhook::PostCommit.new(options).run
    end
  end 
end
