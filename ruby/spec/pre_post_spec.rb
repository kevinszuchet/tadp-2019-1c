require 'require_all'
require_rel 'test_classes'

require_relative './spec_helpers/violation_checker'

describe 'Invariant' do
  include ViolationChecker

  let(:an_instance) { ClassWithPreAndPostConditions.new }

  it 'should not throw an exception if a method does not violate a pre condition' do
    expect_fulfillment {an_instance.some_method_with_pre}
  end

  it 'should not throw an exception if a pre condition is fulfilled with an accessor' do
    expect_fulfillment {an_instance.method_with_accessor_pre}
  end

  it 'should explode if the pre condition is not fulfilled' do
    expect_violation {an_instance.method_with_accessor_pre_violation}
  end
end