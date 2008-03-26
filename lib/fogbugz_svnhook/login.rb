require "active_support"
require "fogbugz_svnhook/base"

module FogbugzSvnhook
  class Login < FogbugzSvnhook::Base
    def initialize(options={})
      super
      @email = options[:email]
      @password = options[:password]
      @username = options[:username]
    end

    def run
      get_missing_options
      connect
      login
    end

    def login
      login_uri = api_uri.dup
      login_uri.query = {"cmd" => "logon", "email" => @email, "password" => @password}.to_query
      say "Logon to #{login_uri.to_s.sub(/password=.*(?=&|$)/, "password=[HIDDEN]")}"
      doc = read(login_uri)
      token = REXML::XPath.first(doc.root, "//response/token/text()")
      say "Contact your administrator and send him this YAML fragment:"
      say({"tokens" => {@username => token.to_s}}.to_yaml)
    end

    def get_missing_options
      @email = ask("Type the E-Mail address you use on FogBugz: ") if @email.blank?
      @password = ask("Type the password you use on FogBugz: ") {|q| q.echo = false} if @password.blank?
      @username = ask("Type your Subversion username: ") if @username.blank?
    end
  end
end
