require_relative '../../lib/before_and_after'

module AMixinE
  def mixin_method
    "im a mixin"
  end
end

module AnotherMixinB
  def mixin_method
    "im another mixin"
  end
end

class ClassWithInvariantAndSeveralMixinsViolation
  invariant { pp 'about to exec invariant'; 1 < 0 }

  include AMixinE
  include AnotherMixinB

  def some_method

  end
end