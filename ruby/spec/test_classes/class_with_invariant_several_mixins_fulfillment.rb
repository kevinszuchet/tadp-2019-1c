require_relative '../../lib/before_and_after'

module AMixinD
  def mixin_method
    "im a mixin"
  end
end

module AnotherMixin
  def mixin_method
    "im another mixin"
  end
end

class ClassWithInvariantAndSeveralMixinsFulfillment
  invariant { pp 'about to exec invariant'; 1 > 0 }

  include AMixinD
  include AnotherMixin

  def some_method

  end
end