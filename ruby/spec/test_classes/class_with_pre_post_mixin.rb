require_relative '../../lib/before_and_after'

module SomeMixin
  pre { pp 'about to exec pre some_method_with_pre'; 1 > 0 }
  def some_method_with_pre
  end
end

class ClassWithPreAndPostConditions

  include SomeMixin

  attr_accessor :some_accessor

  def initialize
    self.some_accessor = 10
  end

  pre { pp 'about to exec pre some_method_with_pre'; 1 > 0 }
  def some_method_with_pre
  end
end