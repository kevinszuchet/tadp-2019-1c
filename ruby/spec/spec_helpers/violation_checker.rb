module ViolationChecker
  def expect_validation_error(error, &block)
    (expect &block).to raise_error(error)
  end

  def expect_invariant_error(&block)
    expect_validation_error(InvariantError, &block)
  end

  def expect_pre_condition_error(&block)
    expect_validation_error(PreConditionError, &block)
  end

  def expect_post_condition_error(&block)
    expect_validation_error(PostConditionError, &block)
  end

  def expect_fulfillment(&block)
    (expect &block).to_not raise_error
  end
end