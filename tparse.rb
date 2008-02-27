require "lib/fogbugz_svnhook/parser"
listener = Object.new
raise "Missing text to match" unless ARGV[0]

class << listener
  def fix(bugid)
    puts "Fixing #{bugid}"
  end

  def close(bugid)
    puts "Closing #{bugid}"
  end

  def implement(bugid)
    puts "Implementing #{bugid}"
  end

  def reopen(bugid)
    puts "Reopens #{bugid}"
  end

  def reactivate(bugid)
    puts "Reactivates #{bugid}"
  end

  def reference(bugid)
    puts "References #{bugid}"
  end

  def assign(name)
    puts "Assigned to #{name.inspect}"
  end
end

FogbugzSvnhook::Parser.parse(ARGV[0], listener)
