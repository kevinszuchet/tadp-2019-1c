class BeforeAfterMethod
  attr_accessor :proc, :already_has_method

  def initialize(proc = proc{})
    @proc = proc
    @already_has_method = true
  end

  # Este no setea ningun parametro, porque los BeforeAfterMethod no los usan
  def with_parameters(parameters_names, parameters_values)
    self
  end

  def validate_over(instance, method_name, method_result = nil)
    instance.instance_exec &proc
  end

  def should_validate?(actual_method)
    true
  end

  def for_method(destination_method)
    self
  end

  def execute_on(object, *args)
    #Uso *args porque puede venir un el result como no
    object.instance_exec args[0], &proc
  end
end

class InvariantValidation
  attr_accessor :condition, :already_has_method, :type, :destination_method, :parameters

  def initialize(type = nil, &condition)
    self.condition = condition
    self.type = type
    self.already_has_method = false
  end

  def parameters_accessor
    self.parameters ||= Hash.new
  end

  # Este agrega la validacion segun si corresponde o no
  def for_method(destination_method)
    self.destination_method = destination_method
    self.already_has_method = true
    self
  end

  # El invariant siempre tiene que hacer la validacion
  def should_validate?(actual_method)
    true
  end

  # Este no setea ningun parametro, porque los invariants no los usan
  def with_parameters(parameters_names, parameters_values)
    self
  end

  def validate(instance, method_result, condition)
    is_fulfilled = instance.instance_exec(method_result, &condition)
    unless is_fulfilled.nil? || is_fulfilled
      raise ContractViolation, self.type
    end
  end

  # Este agrega el comportamiento de agregar los metodos para los parametros a la singleton de la instancia (si no existen aun), ejecutar (validar) y despues sacarlos
  # Y en el caso del invariant, como no hay niguno, no agrega nada :)
  def add_parameters_methods_to(instance)
    parameters_accessor.each do |parameter_name, parameter_value|
      instance.define_singleton_method(parameter_name) {
        parameter_value
      }
    end
  end

  def remove_parameters_methods_to(instance)
    parameters_accessor.each do |parameter_name, parameter_value|
      instance.singleton_class.remove_method(parameter_name)
    end
  end

  def validate_over(instance, method_name, method_result = nil)
    # Tenemos que guardar la validation porque el codigo en el proc se ejecuta en el contexto de la instancia (self ahi adentro no va a ser la validation!)
    validation = self
    proc_with_validation = proc { |method, method_result|
        if validation.should_validate?(method)
          validation.add_parameters_methods_to(self)
          validation.validate(self, method_result, validation.condition)
          validation.remove_parameters_methods_to(self)
        end
      }

    instance.instance_exec(method_name, method_result, &proc_with_validation)
  end
end

class PrePostValidation < InvariantValidation
  def should_validate?(actual_method)
    actual_method == self.destination_method
  end

  def with_parameters(parameters_names, parameters_values)
    parameters_names.each_with_index do |paramArray, index|
      self.parameters_accessor[paramArray[1]] = parameters_values[index]
    end

    self
  end
end