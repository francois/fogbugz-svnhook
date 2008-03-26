require "fogbugz_svnhook/base"
require "fogbugz_svnhook/parser" if File.exist?(File.join(File.dirname(__FILE__), "parser.rb"))
require "fogbugz_svnhook/listener"

module FogbugzSvnhook
  class PreCommit < FogbugzSvnhook::PostCommit
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
