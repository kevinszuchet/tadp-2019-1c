require_relative '../../lib/before_and_after'

class ClassWithInvariantMethodParameter

  attr_accessor :some_accessor
  invariant { pp 'executing invariant'; some_accessor > 20 }

  def initialize
    self.some_accessor = 70
  end

  def some_method(an_arg)
    10
  end
end