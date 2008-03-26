require "fogbugz_svnhook/base"
require "fogbugz_svnhook/parser" if File.exist?(File.join(File.dirname(__FILE__), "parser.rb"))
require "fogbugz_svnhook/listener"

module FogbugzSvnhook
  class PostCommit < FogbugzSvnhook::Base
    attr_reader :svnlook, :repository, :revision

    def initialize(options={})
      super
      @svnlook = options[:svnlook] || config[:svnlook] || "/usr/bin/svnlook"
      @repository = options[:repository] || config[:repository]
      @revision = Integer(options[:revision])
    end

    def run
      get_missing_options
      msg = get_commit_message
      cases_to_manage = parse(msg)
      committer = map_committer_to_token
      update_cases(committer, msg, cases_to_manage)
    end

    def config_file
      options[:config]
    end

    def config
      return @config if @config
      raise ArgumentError, "Cannot read config file: #{config_file}" unless File.file?(config_file) && File.readable?(config_file)
      @config = YAML::load(ERB.new(File.read(config_file)).result)
    end

    def get_missing_options
      say "Get missing options"
    end

    def get_commit_message
      msg = `#{svnlook} log --revision #{revision} #{repository}`
      return msg if $?.success?
      raise "Failed to get commit message, svnlook exited with status #{$?.exitstatus}"
    end

    def parse(msg)
      listener = FogbugzSvnhook::Listener.new
      FogbugzSvnhook::Parser.parse(msg, listener)
      listener.cases
    end

    def map_committer_to_token
      author = `#{svnlook} author --revision #{revision} #{repository}`
      raise "Failed to get commit message, svnlook exited with status #{$?.exitstatus}" unless $?.success?
      author.chomp!
      config["tokens"][author]
    end

    def update_cases(committer, msg, cases)
      connect
      cases.each do |bugid, actions|
        actions.each do |action|
          send(action, bugid, committer, msg)
        end
      end
    end

    def close(bugid, committer, msg)
      action_uri = api_uri.dup
      action_uri.query = {"cmd" => "close", "token" => committer,
                          "ixBug" => bugid,
                          "sEvent" => "Closed in r#{revision}:  #{msg}"}.to_query
      doc = read(action_uri)
      error = REXML::XPath.first(doc.root, "//response/error")
      raise "Could not close #{bugid}:\n#{doc}" if error
      puts "Closed #{bugid}"
    end

    def fix(bugid, committer, msg)
      action_uri = api_uri.dup
      action_uri.query = {"cmd" => "resolve", "token" => committer,
                          "ixBug" => bugid, "ixStatus" => STATES[:fixed],
                          "sEvent" => "Fixed in r#{revision}:  #{msg}"}.to_query
      doc = read(action_uri)
      error = REXML::XPath.first(doc.root, "//response/error")
      raise "Could not fix #{bugid}:\n#{doc}" if error
      puts "Fixed #{bugid}"
    end

    def implement(bugid, committer, msg)
      action_uri = api_uri.dup
      action_uri.query = {"cmd" => "resolve", "token" => committer,
                          "ixBug" => bugid, "ixStatus" => STATES[:implemented],
                          "sEvent" => "Implemented in r#{revision}:  #{msg}"}.to_query
      doc = read(action_uri)
      error = REXML::XPath.first(doc.root, "//response/error")
      raise "Could not implement #{bugid}:\n#{doc}" if error
      puts "Implemented #{bugid}"
    end

    def reopen(bugid, committer, msg)
      action_uri = api_uri.dup
      action_uri.query = {"cmd" => "reopen", "token" => committer,
                          "ixBug" => bugid,
                          "sEvent" => "Reopened in r#{revision}:  #{msg}"}.to_query
      doc = read(action_uri)
      error = REXML::XPath.first(doc.root, "//response/error")
      raise "Could not reopen #{bugid}:\n#{doc}" if error
      puts "Reopened #{bugid}"
    end

    def reactivate(bugid, committer, msg)
      action_uri = api_uri.dup
      action_uri.query = {"cmd" => "reactivate", "token" => committer,
                          "ixBug" => bugid,
                          "sEvent" => "Reactivated in r#{revision}:  #{msg}"}.to_query
      doc = read(action_uri)
      error = REXML::XPath.first(doc.root, "//response/error")
      raise "Could not reactivate #{bugid}:\n#{doc}" if error
      puts "Reactivated #{bugid}"
    end

    def reference(bugid, committer, msg)
      action_uri = api_uri.dup
      action_uri.query = {"cmd" => "edit", "token" => committer,
                          "ixBug" => bugid,
                          "sEvent" => "Referenced in r#{revision}:  #{msg}"}.to_query
      doc = read(action_uri)
      error = REXML::XPath.first(doc.root, "//response/error")
      raise "Could not reference #{bugid}:\n#{doc}" if error
      puts "Referenced #{bugid}"
    end

    STATES = {:fixed => 2, :completed => 15, :implemented => 8}
  end
end
