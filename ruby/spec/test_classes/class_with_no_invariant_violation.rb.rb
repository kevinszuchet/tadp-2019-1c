require_relative '../../lib/before_and_after'

class ClassWithNoInvariantViolation
  invariant { 1 > 0 }
  invariant { }

  def some_method()

  end
end