class EveryMethodValidation
  attr_accessor :condition, :already_has_method

  def initialize(&condition)
    self.condition = condition
    self.already_has_method = false
  end

  # Este no hace nada
  def for_method(method_name)
  end

  # Este tampoco hace nada
  def with_parameters(parameters_names, parameters_values)
    self
  end

  def build
    validation = self
    old_condition = self.condition
    proc { |method, method_result|
      validation.validate(self, nil, old_condition)
    }
  end

  def validate(instance, method_result, condition)
    is_fulfilled = instance.instance_exec(method_result, &condition)
    unless is_fulfilled.nil? || is_fulfilled
      raise ContractViolation, 'TODO'
    end
  end

  # Aca va la logica para ejecutar y que si no se cumple, rompa
  # Ademas, esto nos permite usarlo de forma mucho mas transparente en el method_added
  # def validate
  #   self.condition.call
  # end
end

class ParticularMethodValidation < EveryMethodValidation
  # Este agrega el if para ver si se tiene que ejecutar o no
  def for_method(destination_method)
    validation = self
    self.already_has_method = true
    old_condition = self.condition
    self.condition = proc { |method, method_result|
      if method == destination_method
        validation.validate(self, method_result, old_condition)
      end
    }
    self
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

  def build
    self.condition
  end

  # def validate(method, method_result)
  #   instance_exec(method, method_result, self.condition)
  # end

  # def build
  #   self.condition
  # end

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