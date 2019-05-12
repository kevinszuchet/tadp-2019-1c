require_relative '../../lib/before_and_after'

class ClassWithFalseInvariantThatHasAttr
  attr_accessor :x
  def x
    @x || 1
  end
  invariant { pp "Invariant" ;x > 2 }
end