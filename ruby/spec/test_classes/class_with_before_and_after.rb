require_relative '../../lib/before_and_after'

class ClassWithBeforeAndAfter
  attr_accessor :some_accessor
  before_and_after_each_call(proc { if !some_accessor.nil? && some_accessor > 10
                                      raise StandardError
                                    end },
                             proc { })

  def initialize
    self.some_accessor = 1
  end

  def a_method
    some_accessor
  end
end