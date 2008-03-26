require "fogbugz_svnhook/base"
require "fogbugz_svnhook/post_commit"

module FogbugzSvnhook
  class PreCommit < FogbugzSvnhook::PostCommit
    def initialize(options={})
      super(options.merge(:revision => 0))
      @revision = options[:revision] # We don't want to parse revision as an Integer, since we're using a transaction in the pre-commit hook
    end

    def svnlook_option_name
      :transaction
    end

    def close(bugid, committer, msg)
      $stderr.puts "Closing \##{bugid}"
    end

    def fix(bugid, committer, msg)
      $stderr.puts "Fixing \##{bugid}"
    end

    def implement(bugid, committer, msg)
      $stderr.puts "Implementing \##{bugid}"
    end

    def reopen(bugid, committer, msg)
      $stderr.puts "Reopening \##{bugid}"
    end

    def reactivate(bugid, committer, msg)
      $stderr.puts "Reactivating \##{bugid}"
    end

    def reference(bugid, committer, msg)
      $stderr.puts "Referencing \##{bugid}"
    end
  end
end
