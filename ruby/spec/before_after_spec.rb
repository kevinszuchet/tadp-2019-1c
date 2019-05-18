require_relative './spec_helpers/violation_checker'
require_relative './test_classes/class_with_before_and_after'

describe 'Pre and post' do
  include ViolationChecker

  it 'should execute the before proc in the initialize method' do
    expect_fulfillment {ClassWithBeforeAndAfter.new}
  end
end