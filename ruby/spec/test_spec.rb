describe Prueba do
  let(:prueba) { Prueba.new }

  describe '#materia' do
    it 'debería pasar este test' do
      # prueba.define_singleton_method(:materia) do
      #   self.singleton_class.superclass.before.call
      #   ret = super()
      #   self.singleton_class.superclass.after.call
      #   ret
      # end
      expect(prueba.materia).to be :tadp
    end
  end
end