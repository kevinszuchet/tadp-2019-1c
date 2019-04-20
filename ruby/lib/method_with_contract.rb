class MethodWithContract
  attr_accessor :method_name, :action, :type
  def initialize(method_name, action, type)
    self.method_name = method_name
    self.action = action
    self.type = type
  end

  def method
    method_name
  end
end