require 'require_all'
require_rel 'test_classes'

# require_relative './test_classes/class_with_invariant_several_mixins'

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
    expect_violation {ClassWithInvariantViolationAndMixines.new.mixin_method}
  end

  it 'should validate the invariant if the method is in the last mixin, and there are several mixins' do
    expect_violation {ClassWithInvariantAndSeveralMixinsViolation.new.mixin_method}
  end

  it 'should return as the mixin method if there is no invariant violation' do
    class_with_mixin_instance = ClassWithInvariantFulfilledAndMixines.new
    expect(class_with_mixin_instance.mixin_method).to eq "im a mixin"
  end

  it 'should return as the second mixin method if there is no invariant violation, and there are several mixins' do
    class_with_several_mixins_instance = ClassWithInvariantAndSeveralMixinsFulfillment.new
    expect(class_with_several_mixins_instance.mixin_method).to eq "im another mixin"
  end
end