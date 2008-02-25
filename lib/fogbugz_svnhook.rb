$:.unshift File.dirname(__FILE__)

require "net/http"
require "net/https"
require "open-uri"
require "rexml/document"
require "rexml/xpath"
require "active_support"

module FogbugzSvnhook
  class << self
    def login(options)
      @url = options[:url]
      @email = options[:email]
      @password = options[:password]

      if @email.nil? || @email.strip.empty? then
        print "Type the E-Mail address you use on FogBugz: "
        @email = gets.chomp
      end

      if @password.nil? || @password.strip.empty? then
        print "Type the password you use on FogBugz: "
        @password = gets.chomp
      end

      api_uri = @url.merge("api.xml")
      puts "Connecting to #{api_uri}..."
      doc = REXML::Document.new(open(api_uri))
      api_url = REXML::XPath.first(doc.root, "//response/url/text()")
      api_uri = api_uri.merge(api_url.to_s)
      puts api_uri

      login_uri = api_uri.dup
      login_uri.query = {"cmd" => "logon", "email" => @email, "password" => @password}.to_query
      puts "Login on to #{login_uri}"
      doc = REXML::Document.new(open(login_uri))
      token = REXML::XPath.first(doc.root, "//response/token/text()")
      puts "Your logon token:\n#{token}"
    end
  end 
end
