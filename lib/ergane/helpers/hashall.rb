module Ergane
  class Hashall < Hash
    def initialize(*args)
      super()
      self.default_proc = -> (h, k) { h[k] = self.class.new(*args) }
    end
  end
end
