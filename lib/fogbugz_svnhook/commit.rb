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

    def config
      {}
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
      say "Parsing #{msg.inspect}"
    end

    def map_committer_to_token
      say "Mapping committer to token"
    end

    def update_cases(committer, cases)
      connect
      say "Updating cases"
    end
  end
end
