describe Prueba do
  let(:prueba) { Prueba.new }

  describe '#materia' do
    it 'debería pasar este test' do
      expect(prueba.materia).to be :tadp
    end

    it 'debería pasar este otro test' do
      expect(prueba.otra_materia).to be :pdep
    end

    it 'atest' do
      expect(prueba.si_la_vida_es_10_sumar(8, 1)).to be 20
    end
  end
end