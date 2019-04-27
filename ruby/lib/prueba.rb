require_relative 'exceptions'
require_relative 'method_with_contract'

# TODO chequear que los accessors sean para cada clase
# TODO chequear si no es mejor poner el before_and_after_each_call en Class. Queremos este comportamiento para los mixines? se linearizan...
class Module
  attr_accessor :before, :after, :pre_action, :post_action, :methods_actions

  def add_action(moment, action)
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

  def add_pre_or_post(method_name)
    unless self.methods_actions
      self.methods_actions = []
    end

    if self.pre_action
      methods_actions.push(MethodWithContract.new(method_name, pre_action, :pre))
      self.pre_action = nil
    end

    if self.post_action
      methods_actions.push(MethodWithContract.new(method_name, post_action, :post))
      self.post_action = nil
    end
  end

  def method_particular_condition(method_name, condition_type)
    condition = methods_actions.detect { |mwc| mwc.is_contract_for(method_name, condition_type) }
    condition && condition.action || proc {}
  end

  def pre_validation(method_name)
    method_particular_condition(method_name, :pre)
  end

  def post_validation(method_name)
    method_particular_condition(method_name, :post)
  end

  def define_method_added()
    # TODO este if no lo esta tomando. de todas formas: podemos evitar redefinir un metodo al pedo sin este if?
    # if !self.methods.include?(:method_added)
    def self.method_added(method_name)
      @updated_methods ||= []

      unless @updated_methods && @updated_methods.include?(method_name)
        @updated_methods.push(method_name)

        add_pre_or_post(method_name)

        original_method = self.instance_method(method_name)

        # TODO agregar este comportamiento al new, para validar cuando se construye
        # TODO este metodo tiene que tener en su contexto los procs de before y after (de alguna forma mejor que esta)
        self.define_method(method_name) { |*args|
          self.instance_eval(&self.class.before) unless !self.class.before
          self.instance_eval(&self.class.pre_validation(method_name))
          # TODO agregarle los parametros al call
          ret = original_method.bind(self).call(*args)
          self.instance_eval(&self.class.after) unless !self.class.after
          self.instance_eval(&self.class.post_validation(method_name))
          ret
        }

      end
    end
  end

  def before_and_after_each_call(_before, _after)
    # vamos a ir recolectando estas dos operaciones en bloques que las van a ir agregando al final:
    # uno para el before y otro para el after
    self.add_action(:before, _before)
    self.add_action(:after, _after)

    define_method_added
  end

  def before_and_after_each_call2(_before, _after, type)
    # TODO se podria transformar en un objeto y usarlos polimorficamente
    if(type == :invariant)
      # # vamos a ir recolectando estas dos operaciones en bloques que las van a ir agregando al final:
      # # uno para el before y otro para el after
      # self.addAction(:before, _before)
      # self.addAction(:after, _after)

      # agregar methodwithcontract a lista para invariants (restricciones para todos los metodos)
    else
      #agregar a lista para metodo siguiente (a pre's o post's)
    end

    # si es invariant, agregar un objeto a la lista de invariants
    # sino, agregar uno que se va a procesar para el siguiente metodo

    define_method_added
  end

  def condition_with_validation(contract_type, &condition)
    # esto es medio paja: como estoy envolviendo el bloque procd_condition en este otro, y es este otro el que tiene a self como la instancia,
    # tengo que volver a hacer instance_eval para no perderla

    #TODO no estoy seguro de si hace falta el instance_eval en condition, porque no puedo ejecutar el bloque de otra forma (y sin envolverlo en un proc)
    proc {
      is_fullfilled = self.instance_exec &condition
      unless is_fullfilled.nil? || is_fullfilled
        raise ContractViolation, contract_type
      end
    }
  end

  def invariant(&condition)
    cond_with_exception = condition_with_validation('invariant', &condition)

    before_and_after_each_call(proc {}, cond_with_exception)
  end

  def pre(&condition)
    cond_with_exception = condition_with_validation('pre', &condition)

    self.pre_action = cond_with_exception
    # before_and_after_each_call(cond_with_exception, proc {})
    define_method_added
  end

  def post(&condition)
    cond_with_exception = condition_with_validation('post', &condition)

    self.post_action = cond_with_exception
    define_method_added
  end

end

class Prueba
  attr_accessor :vida

  def initialize
    self.vida = 10
  end

  invariant { 1 > 0 }
  invariant { 1 > 0 }
  invariant { vida > 0 }

  pre { vida > 50 }
  post { vida > 20 }
  def materia
    :tadp
  end

  pre {}
  def otra_materia
    :pdep
  end

  pre { vida == 10 }
  post { vida == 19 }
  def si_la_vida_es_10_sumar(una_vida, otra_vida)
    self.vida += (una_vida + otra_vida)
    self.vida
  end
end
