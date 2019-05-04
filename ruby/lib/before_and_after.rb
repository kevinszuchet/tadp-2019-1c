require_relative 'exceptions'
require_relative 'validation'

# TODO chequear si no es mejor poner el before_and_after_each_call en Class. Queremos este comportamiento para los mixines? se linearizan...
class Module
  attr_accessor :before_validations, :after_validations

  def add_before_validation(validation)
    self.before_validations ||= []
    self.before_validations.push(validation)
  end

  def add_after_validation(validation)
    self.after_validations ||= []
    self.after_validations.push(validation)
  end

  def define_method_added
    # TODO este if no lo esta tomando. de todas formas: podemos evitar redefinir un metodo al pedo sin este if?
    # if !self.methods.include?(:method_added)
    def self.method_added(method_name)
      @updated_methods ||= []

      unless @updated_methods && @updated_methods.include?(method_name)
        @updated_methods.push(method_name)

        original_method = self.instance_method(method_name)

        # TODO revisar el filter
        self.before_validations.filter { |validation| !validation.already_has_method }
            .map {|validation| validation.for_method(method_name) }

        self.after_validations.filter { |validation| !validation.already_has_method }
            .map {|validation| validation.for_method(method_name) }

        # TODO agregar este comportamiento al new, para validar cuando se construye
        # TODO este metodo tiene que tener en su contexto los procs de before y after (de alguna forma mejor que esta)
        self.define_method(method_name) { |*args|
          self.class.before_validations.map { |validation|
            validation.with_parameters(original_method.parameters, args) }

          self.class.before_validations.each { |validation|
            instance_exec(method_name, &validation.condition)
          }

          ret = original_method.bind(self).call(*args)

          self.class.after_validations.map { |validation|
            validation.with_parameters(original_method.parameters, args) }

          self.class.after_validations.each { |validation|
            self.instance_exec(method_name, ret, &validation.condition)
          }

          ret
        }
      end
    end
  end

  def before_and_after_each_call(_before, _after)
    self.add_before_validation(_before)
    self.add_after_validation(_after)

    define_method_added
  end

  def invariant(&condition)
    cond_with_exception = EveryMethodValidation.new(&condition)

    before_and_after_each_call(EveryMethodValidation.new(&{}), cond_with_exception)
  end

  # TODO rename condition_with_validation por validate fulfillment
  def pre(&condition)
    cond_with_exception = ParticularMethodValidation.new(&condition)

    before_and_after_each_call(cond_with_exception, ParticularMethodValidation.new(&{}))
  end

  def post(&condition)
    cond_with_exception = ParticularMethodValidation.new(&condition)

    before_and_after_each_call(ParticularMethodValidation.new(&{}), cond_with_exception)
  end
end