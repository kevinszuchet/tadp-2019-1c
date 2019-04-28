class ValidationBuilder
  attr_accessor :condition, :has_scoped_parameters, :has_result_parameter, :is_for_particular_method, :for_method

  def initialize(&condition)
    self.condition = condition
    self.has_scoped_parameters = false
    self.has_result_parameter = false
    self.is_for_particular_method = false
  end

  def with_scoped_parameters
    self.has_scoped_parameters = true
    self
  end

  def with_result_parameter
    self.has_result_parameter = true
    self
  end

  def for_particular_method
    self.is_for_particular_method = true
    self
  end

  def set_args
    self
  end

  def set_particular_method(method_name)
    self.for_method = method_name
    self
  end

  # TODO devuelve un proc que bindea la instancia (ya esta en self) a la condition original
  def build(method_name)
    validation_condition = self.condition
    for_particular_method = self.is_for_particular_method
    for_method = self.for_method

    proc do
      if for_particular_method
        if for_method == method_name
          is_fulfilled = self.instance_eval(&validation_condition)
          unless is_fulfilled.nil? || is_fulfilled
            raise ContractViolation, 'pre or post'
          end
        end
      else
        is_fulfilled = self.instance_eval(&validation_condition)
        unless is_fulfilled.nil? || is_fulfilled
          raise ContractViolation, 'invariant'
        end
      end
    end
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