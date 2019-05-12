require_relative '../../lib/before_and_after'

module AMixinB
  def mixin_method(&block)
    block.call
  end
end

class ClassWithInvariantFulfilledAndMixinesBlockMethod
  invariant { pp 'about to exec invariant inside ClassWithInvariantFulfilledAndMixinesBlockMethod'; 1 > 0 }

  include AMixinB

  def some_method

  end
end