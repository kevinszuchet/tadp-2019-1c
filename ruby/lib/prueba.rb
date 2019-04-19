class InvariantViolation < StandardError
  def initialize(msg = "The invariant condition is not being fullfilled")
    super
  end
end

# TODO chequear que los accessors sean para cada clase
# TODO chequear si no es mejor poner el before_and_after_each_call en Class. Queremos este comportamiento para los mixines? se linearizan...
class Module
  attr_accessor :before, :after

    def addAction(moment, action)
      if(!self.method(moment).call)
          self.method((moment.to_s + '=').to_sym).call(action)
      else
        old_action = self.method(moment).call
        self.method((moment.to_s + '=').to_sym).call(
          proc {
            self.instance_eval(&old_action)
            self.instance_eval(&action)
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

      # TODO este if no lo ta tomando. de todas formas: podemos evitar redefinir un metodo al pedo sin este if?
      # if !self.methods.include?(:method_added)
        def self.method_added(method_name)
          # pp 'defining method added'

          if !@updated_methods || !@updated_methods.include?(method_name)
            if !@updated_methods
              @updated_methods = []
            end

            @updated_methods.push(method_name)

            original_method = self.instance_method(method_name)

            # TODO agregar este comportamiento al new, para validar cuando se construye
            # TODO este metodo tiene que tener en su contexto los procs de before y after (de alguna forma mejor que esta)
            self.define_method(method_name) {
              self.instance_eval(&self.class.before)
              ret = original_method.bind(self).call
              self.instance_eval(&self.class.after)
              # self.class.after.call
              ret
            }
          end
        end
      # end
    end

  def invariant(&condition)
    # esto es medio paja: como estoy envolviendo el bloque procd_condition en este otro, y es este otro el que tiene a self como la instancia,
    # tengo que volver a hacer instance_eval para no perder la instnacia

    #TODO no estoy seguro de si hace falta el instance_eval en condition, porque no puedo ejecutar el bloque de otra forma (y sin envolverlo en un proc)
    condition_with_exception = proc {
      is_fullfilled = self.instance_eval(&condition)
      unless is_fullfilled
        raise InvariantViolation
      end
    }

    before_and_after_each_call(proc {}, condition_with_exception)
  end

end

class Prueba
  attr_accessor :vida

  def initialize
    self.vida = 10
  end

  invariant { 1 > 0 }
  invariant { 1 > 0 }
  invariant { vida > 20 }

  def materia
    :tadp
  end

  def otraMateria
    :pdep
  end
end
