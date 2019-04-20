class ContractViolation < StandardError
  def initialize(contract_type)
    message = "The " + contract_type + " condition is not being fullfilled"
    super message
  end
end

# TODO chequear que los accessors sean para cada clase
# TODO chequear si no es mejor poner el before_and_after_each_call en Class. Queremos este comportamiento para los mixines? se linearizan...
class Module
  attr_accessor :before, :after, :pre_action, :post_action, :methods_actions

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

  def add_pre_or_post(method_name)
    if !self.methods_actions
      self.methods_actions = []
    end

    if self.pre_action && !self.methods_actions.any? { |mwb| mwb.method.equal?(method_name) }
      self.methods_actions.push(MethodWithBehaviour.new(method_name, self.pre_action))
      self.pre_action = nil
    end
  end

  def define_method_added()
    # TODO este if no lo esta tomando. de todas formas: podemos evitar redefinir un metodo al pedo sin este if?
    # if !self.methods.include?(:method_added)
    def self.method_added(method_name)
      if !@updated_methods || !@updated_methods.include?(method_name)
        if !@updated_methods
          @updated_methods = []
        end

        @updated_methods.push(method_name)

        add_pre_or_post(method_name)

        original_method = self.instance_method(method_name)

        # TODO agregar este comportamiento al new, para validar cuando se construye
        # TODO este metodo tiene que tener en su contexto los procs de before y after (de alguna forma mejor que esta)
        self.define_method(method_name) {
          self.instance_eval(&self.class.before) unless !self.class.before
          self.instance_eval(&self.class.methods_actions.detect { |mwb| mwb.method.equal?(method_name)}.action) unless !self.class.methods_actions.detect { |mwb| mwb.method == method_name }
          ret = original_method.bind(self).call
          self.instance_eval(&self.class.after) unless !self.class.after
          ret
        }

      end
    end
  end

  def before_and_after_each_call(_before, _after)
    # vamos a ir recolectando estas dos operaciones en bloques que las van a ir agregando al final:
    # uno para el before y otro para el after
    self.addAction(:before, _before)
    self.addAction(:after, _after)

    define_method_added
  end

  def invariant(&condition)
    # esto es medio paja: como estoy envolviendo el bloque procd_condition en este otro, y es este otro el que tiene a self como la instancia,
    # tengo que volver a hacer instance_eval para no perder la instnacia

    #TODO no estoy seguro de si hace falta el instance_eval en condition, porque no puedo ejecutar el bloque de otra forma (y sin envolverlo en un proc)
    condition_with_exception = proc {
      pp 'executing invariant'
      is_fullfilled = self.instance_eval(&condition)
      unless is_fullfilled
        raise ContractViolation, 'invariant'
      end
    }

    before_and_after_each_call(proc {}, condition_with_exception)
  end

  def pre(&condition)
    cond = proc &condition
    cond_with_exception = proc {
      pp 'executing pre'
      res = cond.call
      unless res
        raise ContractViolation, 'pre'
      end
    }
    self.pre_action = cond_with_exception
    define_method_added
  end

end

class MethodWithBehaviour
  attr_accessor :method_name, :action
  def initialize(method_name, action)
    self.method_name = method_name
    self.action = action
  end

  def method
    method_name
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

  pre { 1 > 10 }
  def materia
    :tadp
  end

  def otraMateria
    :pdep
  end
end
