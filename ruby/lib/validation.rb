class BeforeAfterMethod
  attr_accessor :proc

  def initialize(proc = proc{})
    @proc = proc
  end

  # Los BeforeAfterMethod siempre tienen que hacer la validacion
  def should_validate?(actual_method)
    true
  end

  # Para los BeforeAfterMethod no importa el metodo
  def for_method(destination_method)
    self
  end

  def validate_over(object, *args)
    #Uso *args porque pueden venir como no
    object.instance_exec &proc
  end

end

class InvariantValidation < BeforeAfterMethod
  attr_accessor :error

  def initialize(condition = proc{}, error = StandardError)
    self.proc = condition
    self.error = error
  end

  def validate_over(object, *args)
    #Uso *args porque puede venir un el result como no
    validation = object.instance_exec args[0], &proc
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