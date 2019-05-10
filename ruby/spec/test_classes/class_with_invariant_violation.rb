require_relative '../../lib/before_and_after'

class ClassWithInvariantViolation
  invariant { pp 'about to exec invariant'; 1 < 0 }

  def some_method()

  end
end