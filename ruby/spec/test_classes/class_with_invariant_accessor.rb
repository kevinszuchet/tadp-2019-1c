require_relative '../../lib/before_and_after'

class ClassWithInvariantAccessor

  attr_accessor :some_accessor
  invariant { pp 'executing invariant'; some_accessor > 20 }

  def initialize
    self.some_accessor = 10
  end

  def some_method

  end
end