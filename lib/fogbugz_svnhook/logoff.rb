require "active_support"
require "fogbugz_svnhook/base"

module FogbugzSvnhook
  class Logoff < FogbugzSvnhook::Base
    def initialize(options={})
      super
      @token = options[:token]
    end

    def run
      get_missing_options
      connect
      logoff
    end

    def logoff
      login_uri = api_uri.dup
      login_uri.query = {"cmd" => "logoff", "token" => @token}.to_query
      say "logoff from #{login_uri.to_s.sub(/password=.*(?=&|$)/, "password=[HIDDEN]")}"
      doc = read(login_uri)
      say doc.to_s
      token = REXML::XPath.first(doc.root, "//response/token/text()")
      say "Your have been logged out"
    end

    def get_missing_options
      @token = ask("What token do you want to logoff: ") if @token.blank?
    end
  end
end
