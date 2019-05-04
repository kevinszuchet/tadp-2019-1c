require_relative 'exceptions'
require_relative 'validation'

# TODO chequear si no es mejor poner el before_and_after_each_call en Class. Queremos este comportamiento para los mixines? se linearizan...
class Module
  attr_accessor :before_validations, :after_validations

  def befores
    self.before_validations ||= []
  end

  def afters
    self.after_validations ||= []
  end

  def add_before_validation(validation)
    befores.push(validation)
  end

  def add_after_validation(validation)
    afters.push(validation)
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
        self.befores.filter { |validation| !validation.already_has_method }
            .map {|validation| validation.for_method(method_name) }

        self.afters.filter { |validation| !validation.already_has_method }
            .map {|validation| validation.for_method(method_name) }

        # TODO agregar este comportamiento al new, para validar cuando se construye
        self.define_method(method_name) { |*args|
          self.class.befores.map { |validation|
            validation.with_parameters(original_method.parameters, args)
          }.each { |validation|
            validation.validate_over(self, method_name)
          }

          ret = original_method.bind(self).call(*args)

          self.class.afters.map { |validation|
            validation.with_parameters(original_method.parameters, args)
          }.each { |validation|
            validation.validate_over(self, method_name, ret)
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
    cond_with_exception = InvariantValidation.new('invariant', &condition)

    before_and_after_each_call(InvariantValidation.new(&{}), cond_with_exception)
  end

  # TODO rename condition_with_validation por validate fulfillment
  def pre(&condition)
    cond_with_exception = PrePostValidation.new('pre', &condition)

    before_and_after_each_call(cond_with_exception, PrePostValidation.new(&{}))
  end

  def post(&condition)
    cond_with_exception = PrePostValidation.new('post', &condition)

    before_and_after_each_call(PrePostValidation.new(&{}), cond_with_exception)
  end
end