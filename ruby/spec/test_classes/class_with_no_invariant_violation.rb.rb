require_relative '../../lib/before_and_after'

class ClassWithNoInvariantViolation
  invariant { pp 'about to exec first invariant'; 1 > 0 }
  invariant { pp 'about to exec second invariant'; }

  def some_method

  end

  def some_method_with_return
    10
  end
end