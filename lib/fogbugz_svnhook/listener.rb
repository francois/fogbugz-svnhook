module FogbugzSvnhook
  class Listener
    attr_reader :cases

    def initialize
      @cases = Hash.new {|h,k| h[k] = Array.new}
    end

    def method_missing(selector, *args)
      super if args.size != 1
      @cases[args.first] << selector.to_sym
    end
  end
end
