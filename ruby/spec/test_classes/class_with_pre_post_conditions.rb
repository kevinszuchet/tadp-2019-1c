require_relative '../../lib/before_and_after'

class ClassWithPreAndPostConditions

  attr_accessor :some_accessor

  def initialize
    self.some_accessor = 10
  end

  pre { 1 > 0 }
  def some_method_with_pre
  end

  pre { some_accessor > 0 }
  def method_with_accessor_pre
  end

  pre { some_accessor < 0 }
  def method_with_accessor_pre_violation
  end

  pre { some_accessor > 5 }
  def method_with_normal_return
    8
  end

  post { |result| result == 11 }
  def method_with_post_ok
    11
  end

  pre { some_accessor == 10 }
  post { some_accessor == 11 }
  def method_with_pre_and_post_ok
    self.some_accessor+= 1
  end
end