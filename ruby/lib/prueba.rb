# TODO chequear que los accessors sean para cada clase
# TODO chequear si no es mejor poner el before_and_after_each_call en Class. queremos este comportamiento para los mixines? se linearizan...
class Module
  attr_accessor :before, :after

  def before_and_after_each_call(_before, _after)
    self.before = _before
    self.after = _after

    # def self.method_added(method_name)
    #   # pp 'self: ', self
    #   pp 'hi. we ve got a new method: ' + method_name.to_s
    #   if !@updated_methods || !@updated_methods.include?(method_name)
    #     if !@updated_methods
    #       @updated_methods = []
    #     end
    #
    #     @updated_methods.push(method_name)
    #
    #     # TODO me gustaria ejecutar el method con este nombre, pero si lo saco de self, es Unbound!
    #     # y si lo hago dentro de define method, el metodo ya se piso y no lo puedo ejecutar!
    #
    #     # self.define_method(method_name) {
    #     #   pp 'simil antes'
    #     #   ret = self.method(method_name).call
    #     #   pp 'simil despues'
    #     #   # ret
    #     # }
    #   end
    # end
  end

  # TODO esto no se esta llamando
  # def new
  #   pp 'hola'
  # end

  # def initialize
  #   pp 'initializatin object'
  #   pp self
  #   super
  # end

end

class Class
  # def initialize
  #   pp 'self in class', self
  # end

  # def new(*args, &block)
  #   super
  #   pp "new constructor defined"
  # end
end

class Prueba

  before_and_after_each_call(
    proc { puts 'Antes del metodo' },
    proc { puts 'Despues del metodo' }
  )

  def initialize
    # TODO esto hay que hacerlo dinamico: en el initialize de c/objecto, buscar sus metodos y por cada uno:
    self.define_singleton_method(:materia) do
      self.singleton_class.superclass.before.call
      ret = super()
      self.singleton_class.superclass.after.call
      ret
    end
  end

  def materia
    # Prueba.before.call
    :tadp
  end
end
