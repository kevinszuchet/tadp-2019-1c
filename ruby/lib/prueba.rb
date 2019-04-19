# TODO chequear que los accessors sean para cada clase
# TODO chequear si no es mejor poner el before_and_after_each_call en Class. queremos este comportamiento para los mixines? se linearizan...
class Module
  attr_accessor :before, :after

    def addAction(moment, action)
      if(!self.method(moment).call)
          self.method((moment.to_s + '=').to_sym).call(action)
      else
        old_action = self.method(moment).call
        self.method((moment.to_s + '=').to_sym).call(
        proc {
          old_action.call
          action.call
        })
      end
    end

    # TODO meter una lista con before y afters, o al momento de redefinir el metodo, bindear los procs (para que esten disponibles cuando se ejecuta)
    # esto lo podemos hacer con un define_method mandando un proc con bindeo previo
    def before_and_after_each_call(_before, _after)
      # vamos a ir recolectando estas dos operaciones en bloques que las van a ir agregando al final:
      # uno para el before y otro para el after

      self.addAction(:before, _before)
      self.addAction(:after, _after)

      # pp self.methods.include?(:method_added)
      #
      # # TODO este if no lo ta tomando. de todas formas: podemos evitar redefinir un metodo al pedo, mejor?
      # if !self.methods.include?(:method_added)
      #   def self.method_added(method_name)
      #     pp 'defining method added'
      #
      #     if !@updated_methods || !@updated_methods.include?(method_name)
      #       if !@updated_methods
      #         @updated_methods = []
      #       end
      #
      #       @updated_methods.push(method_name)
      #
      #       original_method = self.instance_method(method_name)
      #
      #       # TODO este metodo tiene que tener en su contexto los procs de before y after (de alguna forma mejor que esta)
      #       self.define_method(method_name) {
      #         self.class.before.call
      #         ret = original_method.bind(self).call
      #         self.class.after.call
      #         ret
      #       }
      #     end
      #   end
      # end
  end

end

class Prueba

  before_and_after_each_call(
    proc { puts 'Antes del metodo1' },
    proc { puts 'Despues del metodo1' }
  )

  before_and_after_each_call(
      proc { puts 'Antes del metodo2' },
      proc { puts 'Despues del metodo2' }
  )

  before_and_after_each_call(
      proc { puts 'Antes del metodo3' },
      proc { puts 'Despues del metodo3' }
  )

  def materia
    :tadp
  end
end
