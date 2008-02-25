require "net/http"
require "net/https"
require "uri"
require "open-uri"
require "rexml/document"
require "rexml/xpath"
require "highline"
require "active_support"

module FogbugzSvnhook
  class Base
    attr_reader :highline, :options, :api_uri
    delegate :ask, :say, :choose, :to => :highline

    def initialize(options={})
      @options = options
      @api_uri = @options[:uri] || URI.parse(@options[:url])
      @highline = HighLine.new
    end

    def connect
      api_uri.merge!("api.xml")
      say "Connecting to #{api_uri}..."

      doc = read(api_uri)
      api_url = REXML::XPath.first(doc.root, "//response/url/text()")
      api_uri.merge!(api_url.to_s)
    end

    def read(uri)
      content = open(uri)
      begin
        REXML::Document.new(content)
      rescue Exception, Object
        say $!.message
        say content.inspect
        raise
      end
    end
  end
end
