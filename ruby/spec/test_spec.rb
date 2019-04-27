require 'require_all'
require_rel 'test_classes'

require_relative '../lib/exceptions'

require_relative '../lib/before_and_after'

describe 'Invariant' do
  let(:prueba) { Prueba.new }

  describe '#materia' do
    it 'should not throw an exception if a class has no invariants' do
      expect{ClassWithoutInvariants.new.some_method}.to_not raise_error()
    end

    it 'should throw invariant violation if a class breaks the contract' do
      expect{ClassWithInvariantViolation.new.some_method}.to raise_error(ContractViolation)
    end

    it 'atest' do
      expect(prueba.si_la_vida_es_10_sumar(8, 1)).to be 19
    end

    it 'tt' do
      1 > 0
    end
  end
end