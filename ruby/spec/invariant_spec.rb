require 'require_all'
require_rel 'test_classes'

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

  it 'should validate the invariants in the instantiation of the class' do
    expect_violation {ClassWithInvariantAccessor.new}
  end

  it 'should validate the invariant if the method is in a mixin' do
    expect_violation {ClassWithInvariantAndMixines.new.mixin_method}
  end
end