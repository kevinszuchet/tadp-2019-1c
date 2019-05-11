require_relative '../../lib/before_and_after'

class ClassWithPreAndPostConditions

  attr_accessor :some_accessor

  def initialize
    self.some_accessor = 10
  end

  pre { pp 'about to exec pre some_method_with_pre'; 1 > 0 }
  def some_method_with_pre
  end

  pre { pp 'about to exec pre method_with_accessor_pre'; some_accessor > 0 }
  def method_with_accessor_pre
  end

  pre { pp 'about to exec pre method_with_accessor_pre_violation'; some_accessor < 0 }
  def method_with_accessor_pre_violation
  end

  pre { some_accessor > 5 }
  def method_with_normal_return
    8
  end

  post { pp 'about to exec post method_with_post_ok'; 1 > 0 }
  def method_with_post_ok
    11
  end

  pre { pp 'executing pre'; some_accessor == 10 }
  post { pp 'executing post'; some_accessor == 11 }
  def method_with_pre_and_post_ok
    self.some_accessor+= 1
  end

  post { |result| pp result; result == 11 }
  def method_with_post_method_result
    11
  end

  post {}
  def method_with_empty_post
  end

  pre { pp 'an_arg is', an_arg; false != true && an_arg == "hello" }
  post { |result| pp 'executing post'; result == an_arg }
  def method_with_arg(an_arg)
    an_arg
  end

  pre { 1 < 0 }
  post { |result| result == 1 }
  def method_with_pre_violation
    1
  end

  pre { some_accessor == 10 }
  post { some_accessor == 11 }
  def method_with_block(&block)
    block.call
  end
end