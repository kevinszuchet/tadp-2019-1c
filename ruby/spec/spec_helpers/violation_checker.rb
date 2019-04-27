module ViolationChecker
  def expect_violation(&block)
    (expect &block).to raise_error(ContractViolation)
  end

  def expect_fulfillment(&block)
    (expect &block).to_not raise_error
  end
end