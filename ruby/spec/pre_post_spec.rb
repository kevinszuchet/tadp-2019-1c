require 'require_all'
require_rel 'test_classes'

require_relative './spec_helpers/violation_checker'

describe 'Pre and post' do
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

  it 'should return as the method if there is no contract violation' do
    expect(an_instance.method_with_normal_return).to eq 8
  end

  it 'should not explode if the post is fulfilled' do
    expect_fulfillment {an_instance.method_with_post_ok}
  end

  it 'should not explode if both pre and post are fulfilled' do
    expect_fulfillment {an_instance.method_with_pre_and_post_ok}
  end

  it 'should not explode if the post with the method result is fulfilled' do
    expect_fulfillment {an_instance.method_with_pre_method_result}
  end

  it 'should not explode if the post is emptyd' do
    expect_fulfillment {an_instance.method_with_empty_post}
  end

  it 'should return the parameter if the method does that and the pre condition is fulfilled' do
    expect(an_instance.method_with_arg("hello")).to eq "hello"
    pp an_instance.respond_to?(:an_arg)
  end

  # TODO revisar este test. habria que hacer el assert adentro del test anterior porque cada test vuelve a definir an_instance
  it 'should not define methods for the getters and setters needed for the parameters access in the pre/post condition' do
    expect(an_instance.respond_to?(:an_arg)).to eq false
  end
end