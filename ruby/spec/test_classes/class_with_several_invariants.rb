require_relative '../../lib/before_and_after'

class ClassWithSeveralInvariantsOneViolation
  invariant { 20 > 0 }
  invariant { -3 < -2 }
  invariant { 20 == 0 }

  def some_method()

  end
end