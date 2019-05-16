class BeforeAfterMethod
  attr_accessor :condition

  def initialize(condition = condition { })
    self.condition = condition
  end

  # Los BeforeAfterMethod siempre tienen que hacer la validacion
  def should_validate?(actual_method)
    true
  end

  # Para los BeforeAfterMethod no importa el metodo
  def for_method(destination_method)
    self
  end

  def validate_over(object, method_result)
    #Uso method_result porque puede venir como no
    object.instance_eval &condition
  end

end

class InvariantValidation < BeforeAfterMethod
  attr_accessor :error

  def initialize(condition = condition{}, error = InvariantError)
    super(condition)
    self.error = error
  end

  def validate_over(object, method_result)
    validation = object.instance_exec method_result, &condition
    raise self.error unless validation || validation.nil?
  end
end

class PrePostValidation < InvariantValidation
  attr_accessor :destination_method, :already_has_method

  def should_validate?(actual_method)
    actual_method == self.destination_method
  end

  def for_method(destination_method)
    self.destination_method = destination_method unless already_has_method
    self.already_has_method = true
    self
  end

end