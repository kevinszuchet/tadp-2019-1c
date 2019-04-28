require_relative 'exceptions'
require_relative 'method_with_contract'

# TODO chequear si no es mejor poner el before_and_after_each_call en Class. Queremos este comportamiento para los mixines? se linearizan...
class Module
  attr_accessor :before, :after, :pre_action, :post_action, :methods_actions

  def add_action(moment, action)
    if !method(moment).call
      method((moment.to_s + '=').to_sym).call(action)
    else
      old_action = method(moment).call
      method((moment.to_s + '=').to_sym).call(
        proc {
          instance_eval(&old_action)
          instance_eval(&action)
        }
      )
    end
  end

  def add_pre_or_post(method_name)
    self.methods_actions ||= { pre: {}, post: {} }

    if pre_action
      methods_actions[:pre][method_name] = pre_action
      self.pre_action = nil
    end

    if post_action
      methods_actions[:post][method_name] = pre_action
      self.post_action = nil
    end
  end

  def method_particular_condition(method_name, condition_type)
    condition = methods_actions[condition_type][method_name]
    condition || proc {}
  end

  def pre_validation(method_name)
    method_particular_condition(method_name, :pre)
  end

  def post_validation(method_name)
    method_particular_condition(method_name, :post)
  end

  def define_method_added
    def self.method_added(method_name)
      @updated_methods ||= []

      unless @updated_methods && @updated_methods.include?(method_name)
        @updated_methods.push(method_name)

        add_pre_or_post(method_name)

        original_method = instance_method(method_name)

        # TODO agregar este comportamiento al new, para validar cuando se construye
        # TODO este metodo tiene que tener en su contexto los procs de before y after (de alguna forma mejor que esta)
        define_method(method_name) { |*args|
          instance_eval(&self.class.before) if self.class.before

          instance_eval(&self.class.pre_validation(method_name))
          # TODO (terminar de) agregarle los parametros al call
          ret = original_method.bind(self).call(*args)

          instance_eval(&self.class.after) if self.class.after

          instance_exec(ret, &self.class.post_validation(method_name))
          ret
        }
      end
    end
  end

  def before_and_after_each_call(_before, _after)
    # vamos a ir recolectando estas dos operaciones en bloques que las van a ir agregando al final:
    # uno para el before y otro para el after
    add_action(:before, _before)
    add_action(:after, _after)

    define_method_added
  end

  def fulfillment_validation(contract_type)
    proc do |is_fulfilled|
      unless is_fulfilled.nil? || is_fulfilled
        raise ContractViolation, contract_type
      end
    end
  end

  def fulfillment_validation_without_parameters(contract_type, &condition)
    condition_with_validation = fulfillment_validation(contract_type)
    proc {
      condition_with_validation.call(instance_eval(&condition))
    }
  end

  def fulfillment_validation_with_parameters(contract_type, &condition)
    condition_with_validation = fulfillment_validation(contract_type)
    proc { |result|
      condition_with_validation.call(instance_exec(result, &condition))
    }
  end

  def invariant(&condition)
    before_and_after_each_call(proc {}, fulfillment_validation_without_parameters('invariant', &condition))
  end

  def pre(&condition)
    self.pre_action = fulfillment_validation_without_parameters('pre', &condition)
    define_method_added
  end

  def post(&condition)
    self.post_action = fulfillment_validation_with_parameters('post', &condition)
    define_method_added
  end

end