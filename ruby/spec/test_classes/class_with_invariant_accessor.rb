require_relative '../../lib/before_and_after'

class ClassWithInvariantAccessor

  attr_accessor :some_accessor

  def initialize
    self.some_accessor = 10
  end

  invariant { some_accessor > 20 }

  def some_method()

  end
end