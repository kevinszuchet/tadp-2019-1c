class BeforeAfterMethod
  attr_accessor :proc, :already_has_method

  def initialize(proc = proc{})
    @proc = proc
    @already_has_method = true
  end

  def validate_over(instance, method_name, method_result = nil)
    instance.instance_exec &proc
  end

  # Los BeforeAfterMethod siempre tienen que hacer la validacion
  def should_validate?(actual_method)
    true
  end

  def execute_on(object, *args)
    #Uso *args porque puede venir un el result como no
    object.instance_exec args[0], &proc
  end
end

class InvariantValidation
  attr_accessor :condition, :already_has_method

  def initialize(&condition)
    self.condition = condition
    self.already_has_method = true
  end

  # El invariant siempre tiene que hacer la validacion
  def should_validate?(actual_method)
    true
  end

  def validate_over(object, *args)
    #Uso *args porque puede venir un el result como no
    raise PreconditionError unless object.instance_exec args[0], &condition
  end
end

class PrePostValidation < InvariantValidation
  
  attr_accessor :destination_method

  def initialize(&condition)
    self.condition = condition
    self.already_has_method = false
  end

  def should_validate?(actual_method)
    actual_method == self.destination_method
  end

  def for_method(destination_method)
    self.destination_method = destination_method
    self.already_has_method = true
    self
  end

end