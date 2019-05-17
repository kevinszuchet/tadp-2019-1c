class BeforeAfterMethod
  attr_accessor :condition

  def initialize(condition)
    self.condition = condition
  end

  # Los BeforeAfterMethod siempre tienen que ejecutarse (para todos los metodos)
  def should_execute?(actual_method)
    true
  end

  # Para los BeforeAfterMethod e InvariantValidation no setean el metodo porque no lo necesitan
  def for_method(destination_method) end

  def execute_over(instance, method_name, method_result)
    #Uso method_result porque puede venir como no
    instance.instance_eval &condition
  end
end

class InvariantValidation < BeforeAfterMethod
  attr_accessor :error

  def initialize(condition = condition{}, error = InvariantError)
    super(condition)
    self.error = error
  end

  def execute_over(instance, method_name, method_result)
    if should_execute?(method_name)
      validation = instance.instance_exec method_result, &condition
      raise self.error unless validation || validation.nil?
    end
  end
end

class PrePostValidation < InvariantValidation
  attr_accessor :destination_method, :already_has_method

  def should_execute?(actual_method)
    actual_method == self.destination_method
  end

  def for_method(destination_method)
    self.destination_method = destination_method unless already_has_method
    self.already_has_method = true
  end
end