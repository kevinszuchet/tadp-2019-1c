require_relative '../../lib/before_and_after'

module AMixin
  def mixin_method
    "im a mixin"
  end
end

class ClassWithInvariantAndMixinesOk
  invariant { pp 'about to exec invariant'; 1 > 0 }

  include AMixin

  def some_method

  end
end