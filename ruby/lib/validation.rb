class InvariantValidation
  attr_accessor :condition, :already_has_method, :type

  def initialize(type = nil, &condition)
    self.condition = condition
    self.type = type
    self.already_has_method = false
  end

  # Este agrega la validacion segun si corresponde o no
  def for_method(destination_method)
    validation = self
    self.already_has_method = true
    old_condition = self.condition
    self.condition = proc { |method, method_result|
      if validation.should_validate(destination_method, method)
        validation.validate(self, method_result, old_condition)
      end
    }
    self
  end

  # El invariant siempre tiene que hacer la validacion
  def should_validate(destination_method, actual_method)
    true
  end

  # Este tampoco hace nada
  def with_parameters(parameters_names, parameters_values)
    self
  end

  def validate(instance, method_result, condition)
    is_fulfilled = instance.instance_exec(method_result, &condition)
    unless is_fulfilled.nil? || is_fulfilled
      raise ContractViolation, self.type
    end
  end

  def validate_over(instance, method_name, method_result = nil)
    instance.instance_exec(method_name, method_result, &self.condition)
  end
end

class PrePostValidation < InvariantValidation
  def should_validate(destination_method, actual_method)
    actual_method == destination_method
  end

  # Este agrega el comportamiento de agregar los metodos para los parametros a la singleton de la instancia (si no existen aun), ejecutar y despues sacarlos
  def with_parameters(parameters_names, parameters_values)
    old_condition = self.condition
    self.condition = proc { |method, method_result|
      parameters_names.each_with_index do |paramArray, index|
        self.define_singleton_method(paramArray[1]) {
          parameters_values[index]
        }
      end

      # TODO se estan agregando y sacando metodos al pedo, cuando puede ser que la validacion ni se tenga que hacer (no es para X metodo)
      self.instance_exec(method, method_result, &old_condition)

      parameters_names.each do |paramArray|
        self.singleton_class.remove_method(paramArray[1])
      end
    }
    self
  end
end

# class Module
#   def fulfillment_validation(contract_type)
#     proc do |is_fulfilled|
#       unless is_fulfilled.nil? || is_fulfilled
#         raise ContractViolation, contract_type
#       end
#     end
#   end
#
#   def fulfillment_validation_without_parameters(contract_type, &condition)
#     condition_with_validation = fulfillment_validation(contract_type)
#     proc {
#       condition_with_validation.call(self.instance_eval(&condition))
#     }
#   end
#
#   def fulfillment_validation_with_parameters(contract_type, &condition)
#     condition_with_validation = fulfillment_validation(contract_type)
#     proc { |result|
#       condition_with_validation.call(self.instance_exec(result, &condition))
#     }
#   end
# end