require 'require_all'
require_rel 'test_classes'

# require_relative './test_classes/class_without_invariants'
# require_relative './test_classes/class_with_invariant_violation'

require_relative './spec_helpers/violation_checker'

describe 'Invariant' do
  include ViolationChecker

  it 'should not throw an exception if a class has no invariants' do
    expect_fulfillment {ClassWithoutInvariants.new.some_method}
  end

  it 'should throw invariant violation if a class breaks the contract' do
    expect_violation {ClassWithInvariantViolation.new.some_method}
  end

  it 'should not explode if the invariant is fulfilled or empty' do
    expect_fulfillment {ClassWithNoInvariantViolation.new.some_method}
  end

  it 'should explode if invariant condition has an accessor and is violated' do
    expect_violation {ClassWithInvariantAccessor.new.some_method}
  end

  it 'should explode if a class has several invariants and one is a contract violation' do
    expect_violation{ClassWithSeveralInvariantsOneViolation.new.some_method}
  end

  it 'should return the method result if the invariant is fulfilled' do
    expect(ClassWithNoInvariantViolation.new.some_method_with_return).to eq 10
  end

  it 'if a class inherits from another that has invariants, they should be checked' do
    expect_violation {ClassWithInheritance.new.a_method}
  end
end

class ClassWithInheritance < ClassWithPreAndPostConditions
  def a_method
    pp 'im a method'
  end
end