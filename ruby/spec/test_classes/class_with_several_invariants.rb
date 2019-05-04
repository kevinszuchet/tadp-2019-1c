require_relative '../../lib/before_and_after'

class ClassWithSeveralInvariantsOneViolation
  invariant { pp 'executing first invariant'; 20 > 0 }
  invariant { pp 'executing second invariant'; -3 < -2 }
  invariant { pp 'executing third invariant'; 20 == 0 }

  def some_method
  end
end