require "fogbugz_svnhook/base"

module FogbugzSvnhook
  class Commit < FogbugzSvnhook::Base
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
      update_cases(committer, cases_to_manage)
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
      returning(Hash.new {|h,k| h[k] = Array.new}) do |actions|
        msg.scan(/(?:(?:(?:re)?(?:opens?|activates?))|(?:implements?)|(?:fix(?:es)?)|(?:closes?)):?\s*#\d+(?:,\s*#\d+)*/i) do |section|
          case section
          when /close/i
            section.scan(/#\d+/) do |bugid|
              actions[bugid[1..-1].to_i] << :close
            end
          when /fix/i
            section.scan(/#\d+/) do |bugid|
              actions[bugid[1..-1].to_i] << :fix
            end
          when /implement/i
            section.scan(/#\d+/) do |bugid|
              actions[bugid[1..-1].to_i] << :implement
            end
          when /activate/i
            section.scan(/#\d+/) do |bugid|
              actions[bugid[1..-1].to_i] << :reactivate
            end
          when /open/i
            section.scan(/#\d+/) do |bugid|
              actions[bugid[1..-1].to_i] << :reopen
            end
          else
            raise "Unhandled section: #{section.inspect}"
          end
        end
      end
    end

    def map_committer_to_token
      author = `#{svnlook} author --revision #{revision} #{repository}`
      raise "Failed to get commit message, svnlook exited with status #{$?.exitstatus}" unless $?.success?
      author.chomp!
      config["tokens"][author]
    end

    def update_cases(committer, cases)
      connect
      cases.each do |bugid, actions|
        actions.each do |action|
          send(action, bugid, committer)
        end
      end
    end

    def close(bugid, committer)
      action_uri = api_uri.dup
      action_uri.query = {"cmd" => "close", "token" => committer,
                          "ixBug" => bugid,
                          "sEvent" => "Closed in r#{revision}."}.to_query
      doc = read(action_uri)
      error = REXML::XPath.first(doc.root, "//response/error")
      raise "Could not close #{bugid}:\n#{doc}" if error
      $stderr.puts "Closed #{bugid}"
    end

    def fix(bugid, committer)
      action_uri = api_uri.dup
      action_uri.query = {"cmd" => "resolve", "token" => committer,
                          "ixBug" => bugid, "ixStatus" => STATES[:fixed],
                          "sEvent" => "Fixed in r#{revision}."}.to_query
      doc = read(action_uri)
      error = REXML::XPath.first(doc.root, "//response/error")
      raise "Could not fix #{bugid}:\n#{doc}" if error
      $stderr.puts "Fixed #{bugid}"
    end

    def implement(bugid, committer)
      action_uri = api_uri.dup
      action_uri.query = {"cmd" => "resolve", "token" => committer,
                          "ixBug" => bugid, "ixStatus" => STATES[:implemented],
                          "sEvent" => "Implemented in r#{revision}."}.to_query
      doc = read(action_uri)
      error = REXML::XPath.first(doc.root, "//response/error")
      raise "Could not implement #{bugid}:\n#{doc}" if error
      $stderr.puts "Implemented #{bugid}"
    end

    def reopen(bugid, committer)
      action_uri = api_uri.dup
      action_uri.query = {"cmd" => "reopen", "token" => committer,
                          "ixBug" => bugid,
                          "sEvent" => "Reopened in r#{revision}."}.to_query
      doc = read(action_uri)
      error = REXML::XPath.first(doc.root, "//response/error")
      raise "Could not reopen #{bugid}:\n#{doc}" if error
      $stderr.puts "Reopened #{bugid}"
    end

    def reactivate(bugid, committer)
      action_uri = api_uri.dup
      action_uri.query = {"cmd" => "reactivate", "token" => committer,
                          "ixBug" => bugid,
                          "sEvent" => "Reactivated in r#{revision}."}.to_query
      doc = read(action_uri)
      error = REXML::XPath.first(doc.root, "//response/error")
      raise "Could not reactivate #{bugid}:\n#{doc}" if error
      $stderr.puts "Reactivated #{bugid}"
    end

    STATES = {:fixed => 2, :completed => 15, :implemented => 8}
  end
end
