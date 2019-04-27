require_relative './test_classes/prueba'

describe 'Prueba' do
  let(:prueba) { Prueba.new }

  describe '#materia' do
    it 'no deberia romper al instanciar una clase sin invariants' do
      expect(prueba.materia).to be :tadp
    end

    it 'debería pasar este otro test' do
      expect(prueba.otra_materia).to be :pdep
    end

    it 'atest' do
      expect(prueba.si_la_vida_es_10_sumar(8, 1)).to be 19
    end

    it 'tt' do
      1 > 0
    end
  end
end