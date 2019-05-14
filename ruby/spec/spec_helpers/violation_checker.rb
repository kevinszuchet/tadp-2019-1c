module ViolationChecker
  def expect_violation(&block)
    (expect &block).to raise_error(ContractViolation)
  end

  def expected_invariant_error(&block)
    (expect &block).to raise_error(InvariantError)
  end

  def expected_pre_condition_error(&block)
    (expect &block).to raise_error(PreconditionError)
  end

  def expected_post_condition_error(&block)
    (expect &block).to raise_error(PreconditionError)
  end

  def expect_fulfillment(&block)
    (expect &block).to_not raise_error
  end
end