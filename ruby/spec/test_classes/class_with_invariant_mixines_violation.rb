require_relative '../../lib/before_and_after'

module AMixinC
  def mixin_method
    "im a mixin"
  end
end

class ClassWithInvariantViolationAndMixines
  invariant { pp 'about to exec invariant'; 1 < 0 }

  include AMixinC

  def some_method

  end
end