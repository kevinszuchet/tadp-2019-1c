# TODO chequear que los accessors sean para cada clase
# TODO chequear si no es mejor poner el before_and_after_each_call en Class. queremos este comportamiento para los mixines? se linearizan...
class Module
  attr_accessor :before, :after

  def before_and_after_each_call(_before, _after)
    self.before = _before
    self.after = _after

    # TODO sacar esta anidacion!
    def self.method_added(method_name)
      pp 'hi. we ve got a new method: ' + method_name.to_s
      if !@updated_methods || !@updated_methods.include?(method_name)
        if !@updated_methods
          @updated_methods = []
        end

        @updated_methods.push(method_name)

        old_method = self.instance_method(method_name)

        # TODO este metodo tiene que tener en su contexto los procs de before y after (de alguna forma mejor que esta)
        self.define_method(method_name) {
          self.class.before.call
          ret = old_method.bind(self).call
          self.class.after.call
          ret
        }
      end
    end
  end
end

class Prueba

  before_and_after_each_call(
    proc { puts 'Antes del metodo' },
    proc { puts 'Despues del metodo' }
  )

  def materia
    :tadp
  end
end
