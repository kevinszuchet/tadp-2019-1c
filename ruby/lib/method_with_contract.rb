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

  def is_contract_for(method_name, condition_type)
    method == method_name && type == condition_type
  end
end