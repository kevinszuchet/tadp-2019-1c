require_relative '../../lib/before_and_after'

class ClassWithFalseInvariantWithInitialize
  attr_accessor :x
  invariant { pp "Invariant" ;x > 2 }
  def initialize
    self.x = 1
  end

end