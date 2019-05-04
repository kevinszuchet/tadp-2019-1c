require_relative 'exceptions'
require_relative 'validation'

# TODO chequear si no es mejor poner el before_and_after_each_call en Class. Queremos este comportamiento para los mixines? se linearizan...
class Module
  attr_accessor :before, :after, :pre_action, :post_action, :methods_actions, :before_validations, :after_validations

  def add_before_validation(validation)
    self.before_validations ||= []
    self.before_validations.push(validation)
  end

  def add_after_validation(validation)
    self.after_validations ||= []
    self.after_validations.push(validation)
  end

  # TODO evaluar composicion de Validations, para aprovechar esta logica de alguna manera
  # def add_action(moment, action)
  #   if !self.method(moment).call
  #     self.method((moment.to_s + '=').to_sym).call(action)
  #   else
  #     old_action = self.method(moment).call
  #     # TODO revisa. esto necesita un validationbuilder pero esta recibiendo un proc
  #     self.method((moment.to_s + '=').to_sym).call(
  #         proc {
  #           self.instance_eval(&old_action)
  #           self.instance_eval(&action)
  #         }
  #     )
  #   end
  # end

  # def add_pre_or_post(method_name)
  #   self.methods_actions ||= { :pre => Hash.new, :post => Hash.new }
  #
  #   if self.pre_action
  #     methods_actions[:pre][method_name] = pre_action
  #     self.pre_action = nil
  #   end
  #
  #   if self.post_action
  #     methods_actions[:post][method_name] = post_action
  #     self.post_action = nil
  #   end
  # end
  #
  # def method_particular_condition(method_name, condition_type)
  #   condition = methods_actions[condition_type][method_name]
  #   condition || proc {}
  # end
  #
  # def pre_validation(method_name)
  #   method_particular_condition(method_name, :pre)
  # end
  #
  # def post_validation(method_name)
  #   method_particular_condition(method_name, :post)
  # end

  # def clone_and_add_parameters_getters(parameters)
  #   self_clone = self.clone
  #
  #   parameters.each_with_index do |paramArray, index|
  #     self_clone.define_singleton_method(paramArray[1]) {
  #       args[index]
  #     }
  #   end
  #
  #   self_clone
  # end

  def define_method_added
    # TODO este if no lo esta tomando. de todas formas: podemos evitar redefinir un metodo al pedo sin este if?
    # if !self.methods.include?(:method_added)
    def self.method_added(method_name)
      @updated_methods ||= []

      unless @updated_methods && @updated_methods.include?(method_name)
        @updated_methods.push(method_name)

        original_method = self.instance_method(method_name)

        # self.before.set_particular_method(method_name) unless !self.before
        # self.after.set_particular_method(method_name) unless !self.after
        self.before_validations.filter { |validation| !validation.for_method }
          .each {|validation| validation.set_particular_method(method_name) }

        self.after_validations[-1]&.set_particular_method(method_name)

        # TODO agregar este comportamiento al new, para validar cuando se construye
        # TODO este metodo tiene que tener en su contexto los procs de before y after (de alguna forma mejor que esta)
        self.define_method(method_name) { |*args|
          # if self.class.before
          #   self.instance_eval(&self.class.before.build(method_name))
          # end

          original_method.parameters.each_with_index do |paramArray, index|
            self.define_singleton_method(paramArray[1]) {
              args[index]
            }
          end

          self.class.before_validations.each { |validation|
            self.instance_eval(&validation.build(method_name, original_method.parameters))
          }

          # self_clone = self.class.clone_and_add_parameters_getters(original_method.parameters)


          # self.instance_eval(&self.class.pre_validation(method_name))

          # TODO (terminar de) agregarle los parametros al call
          ret = original_method.bind(self).call(*args)

          # if self.class.after
          #   self.instance_eval(&self.class.after.build(method_name))
          # end

          self.class.after_validations.each { |validation|
            self.instance_exec(ret, &validation.build(method_name, original_method.parameters))
          }

          # self_clone2 = self.class.clone_and_add_parameters_getters(original_method.parameters)

          # self.instance_exec(ret, &self.class.post_validation(method_name))

          original_method.parameters.each do |paramArray|
            self.singleton_class.remove_method(paramArray[1])
          end

          ret
        }
      end
    end
  end

  def before_and_after_each_call(_before, _after)
    # vamos a ir recolectando estas dos operaciones en bloques que las van a ir agregando al final:
    # uno para el before y otro para el after
    # self.add_action(:before, _before)
    # self.add_action(:after, _after)

    self.add_before_validation(_before)
    self.add_after_validation(_after)

    define_method_added
  end

  def invariant(&condition)
    cond_with_exception = ValidationBuilder.new(&condition)

    before_and_after_each_call(ValidationBuilder.new(&{}), cond_with_exception)
  end

  # TODO rename condition_with_validation por validate fulfillment
  def pre(&condition)
    cond_with_exception = ValidationBuilder.new(&condition).for_particular_method.with_scoped_parameters

    # self.pre_action = cond_with_exception
    before_and_after_each_call(cond_with_exception, ValidationBuilder.new(&{}))
  end

  def post(&condition)
    cond_with_exception = ValidationBuilder.new(&condition).for_particular_method.with_scoped_parameters

    # self.post_action = cond_with_exception
    before_and_after_each_call(ValidationBuilder.new(&{}), cond_with_exception)
  end
end