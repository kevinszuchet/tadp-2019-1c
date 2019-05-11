require_relative '../../lib/before_and_after'

module AMixin
  def mixin_method
    "im a mixin"
  end
end

module AnotherMixin
  def mixin_method
    "im another mixin"
  end
end

class ClassWithInvariantAndSeveralMixinsViolation
  invariant { pp 'about to exec invariant'; 1 < 0 }

  include AMixin
  include AnotherMixin

  def some_method

  end
end