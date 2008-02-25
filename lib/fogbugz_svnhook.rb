$:.unshift File.dirname(__FILE__)

require "net/http"
require "net/https"
require "open-uri"

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

      api_url = @url.merge("api.xml")
      puts "Connecting to #{api_url}..."
      puts open(api_url).string
    end
  end 
end
