class MethodWithContract
  attr_accessor :method_name, :action
  def initialize(method_name, action)
    self.method_name = method_name
    self.action = action
  end

  def method
    method_name
  end
end