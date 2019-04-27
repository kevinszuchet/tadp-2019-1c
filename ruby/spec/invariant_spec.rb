require 'require_all'
require_rel 'test_classes'

require_relative '../lib/exceptions'

describe 'Invariant' do
  it 'should not throw an exception if a class has no invariants' do
    expect{ClassWithoutInvariants.new.some_method}.to_not raise_error
  end

  it 'should throw invariant violation if a class breaks the contract' do
    expect{ClassWithInvariantViolation.new.some_method}.to raise_error(ContractViolation)
  end

  it 'should not explode if the invariant is fullfilled or empty' do
    expect{ClassWithNoInvariantViolation.new.some_method}.to_not raise_error
  end

  it 'should explode if invariant condition has an accessor and is violated' do
    expect{ClassWithInvariantAccessor.new.some_method}.to raise_error(ContractViolation)
  end

  it 'should explode if a class has several invariants and one is a contract violation' do
    expect{ClassWithSeveralInvariantsOneViolation.new.some_method}.to raise_error(ContractViolation)
  end
end