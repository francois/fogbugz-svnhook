module FogbugzSvnhook
  class Listener
    attr_reader :cases, :state

    def initialize
      @cases = Hash.new {|h,k| h[k] = Array.new}
      set_default_state
    end

    def set_default_state
      self.reference
    end

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
      @cases[number.to_i] << @state
    end
  end
end
