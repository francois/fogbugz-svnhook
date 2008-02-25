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
        msg.scan(/closes?:?\s*#\d+(?:,\s*#\d+)*/i) do |section|
          case section
          when /close/i
            section.scan(/#\d+/) do |bugid|
              actions[bugid[1..-1].to_i] << :close
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
      say "Updating cases, as touched by #{committer}"
      say cases.inspect
    end
  end
end
