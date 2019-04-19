describe Prueba do
  let(:prueba) { Prueba.new }

  describe '#materia' do
    it 'debería pasar este test' do
      expect(prueba.materia).to be :tadp
    end

    it 'debería pasar este otro test' do
      expect(prueba.otraMateria).to be :pdep
    end

    it 'atest' do
      expect(false).to be false
    end
  end
end