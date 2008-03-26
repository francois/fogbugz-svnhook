require "lib/fogbugz_svnhook/parser"
listener = Object.new
raise "Missing text to match" unless ARGV[0]

class << listener
  def close
    @state = :close
  end

  def reference
    @state = :reference
  end

  def fix
    @state = :fix
  end

  def reopen
    @state = :reopen
  end

  def reactivate
    @state = :reactivate
  end

  def implement
    @state = :implement
  end

  def case(number)
    printf "%s %s\n", @state.to_s, number
  end
end

listener.reference
FogbugzSvnhook::Parser.parse(ARGV[0], listener)
