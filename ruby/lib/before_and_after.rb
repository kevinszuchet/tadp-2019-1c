require_relative 'exceptions'

# TODO chequear si no es mejor poner el before_and_after_each_call en Class. Queremos este comportamiento para los mixines? se linearizan...
class Module
  attr_accessor :before, :after, :pre_action, :post_action, :methods_actions

  def add_action(moment, action)
    if !self.method(moment).call
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
    self.methods_actions ||= { :pre => Hash.new, :post => Hash.new }

    # pp self, methods_actions

    if self.pre_action
      methods_actions[:pre][method_name] = pre_action
      self.pre_action = nil
    end

    if self.post_action
      methods_actions[:post][method_name] = post_action
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
          if self.class.before
            self.instance_eval(&self.class.before)
          end

          self_clone = self.clone

          original_method.parameters.each_with_index do |paramArray, index|
            self_clone.define_singleton_method(paramArray[1]) {
              args[index]
            }
          end


          self_clone.instance_eval(&self.class.pre_validation(method_name))

          # TODO (terminar de) agregarle los parametros al call
          ret = original_method.bind(self).call(*args)

          if self.class.after
            self.instance_eval(&self.class.after)
          end

          self_clone2 = self.clone

          original_method.parameters.each_with_index do |paramArray, index|
            self_clone2.define_singleton_method(paramArray[1]) {
              args[index]
            }
          end

          self_clone2.instance_exec(ret, &self.class.post_validation(method_name))
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
      condition_with_validation.call(self.instance_eval(&condition))
    }
  end

  def fulfillment_validation_with_parameters(contract_type, &condition)
    condition_with_validation = fulfillment_validation(contract_type)
    proc { |result|
      condition_with_validation.call(self.instance_exec(result, &condition))
    }
  end

  def invariant(&condition)
    cond_with_exception = fulfillment_validation_without_parameters('invariant', &condition)

    before_and_after_each_call(proc {}, cond_with_exception)
  end

  # TODO rename condition_with_validation por validate fulfillment
  def pre(&condition)
    cond_with_exception = fulfillment_validation_without_parameters('pre', &condition)

    self.pre_action = cond_with_exception
    # before_and_after_each_call(cond_with_exception, proc {})
    define_method_added
  end

  def post(&condition)
    cond_with_exception = fulfillment_validation_with_parameters('post', &condition)

    self.post_action = cond_with_exception
    define_method_added
  end

end