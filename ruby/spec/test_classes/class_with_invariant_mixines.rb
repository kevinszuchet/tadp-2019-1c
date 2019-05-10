require_relative '../../lib/before_and_after'

module AMixin
  def mixin_method
    pp "im a mixin"
  end
end

class ClassWithInvariantAndMixines
  invariant { pp 'about to exec invariant'; 1 < 0 }

  include AMixin

  def some_method

  end
end