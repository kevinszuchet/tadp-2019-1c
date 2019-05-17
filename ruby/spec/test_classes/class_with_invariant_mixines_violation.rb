require_relative '../../lib/before_and_after'

module AMixinC
  def mixin_method
    self.some_accessor = 0
  end
end

class ClassWithInvariantViolationAndMixines
  attr_accessor :some_accessor
  invariant { pp 'about to exec invariant'; some_accessor > 0 }

  include AMixinC

  def initialize
    self.some_accessor = 1
  end

  def some_method

  end
end