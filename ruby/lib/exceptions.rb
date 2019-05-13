class ContractViolation < StandardError
  def initialize(contract_type)
    message = "The " + contract_type + " condition is not being fullfilled"
    super message
  end
end

class PreconditionError < StandardError

  def initialize(msg="Failed to meet precondition")
    super
  end

end