require_relative 'exceptions'
require_relative 'validation'

# TODO chequear si no es mejor poner el before_and_after_each_call en Class. Queremos este comportamiento para los mixines? se linearizan...
class Module
  attr_accessor :before_validations, :after_validations, :included_mixin, :was_redefined

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

  # El included nos avisa cuando un mixin es incluido en la clase (que se pasa por parametro)
  # Entonces, lo que hacemos es agregarle otro mixin a la clase, con los mismos metodos que el mixin original pero tuneados con los invariants de la clase
  def included(class_including_me)
    # Este unless es para que solo redefina los mixins de clases que tienen un after (al menos un invariant)
    unless class_including_me.afters.empty?
      mixin_clone = self.clone

      # Este unless es para que no entrar en un loop: aca adentro estamos incluyendo un mixin (send :include)!
      unless class_including_me.included_mixin
        mixin_clone.define_method_added
        # Como el mixin original va a seguir estando en la clase, este puede hacer super en cada metodo
        self.instance_methods.each do |mixin_method|
          mixin_clone.define_method(mixin_method) do |*args, &block|
            super(*args, &block)
          end
        end

        # Esto es lo que se usa en el if para evitar el loop
        class_including_me.included_mixin = true
        # Aca incluyo el mixin tuneado
        class_including_me.send(:include, mixin_clone)
        class_including_me.included_mixin = false
      end
    end
  end

  def set_validations_for_defined_method(validations, method_name)
    # TODO revisar el filter: alguna forma mejor de hacerlo?
    validations.filter { |validation| !validation.already_has_method }
        .map {|validation| validation.for_method(method_name) }
  end

  def set_parameters_and_validate(instance, validations, parameters, args, method_name, method_result = nil)
    validations.map { |validation|
      validation.with_parameters(parameters, args)
    }.each { |validation|
      validation.validate_over(instance, method_name, method_result)
    }
  end

  def define_method_added
    # TODO este if no lo esta tomando. de todas formas: podemos evitar redefinir un metodo al pedo, sin este if?
    # if !self.methods.include?(:method_added)
    def self.method_added(method_name)

      self.was_redefined ||= false

      unless self.was_redefined

        self.was_redefined = true
        original_method = self.instance_method(method_name)

        self.set_validations_for_defined_method(self.befores, method_name)
        self.set_validations_for_defined_method(self.afters, method_name)

        self.define_method(method_name) { |*args, &block|
          self.class.set_parameters_and_validate(self, self.class.befores, original_method.parameters, args, method_name)

          ret = original_method.bind(self).call(*args, &block)

          self.class.set_parameters_and_validate(self, self.class.afters, original_method.parameters, args, method_name, ret)

          ret
        }

        self.was_redefined = false
      end
    end
  end

  def define_initialize
    self.define_method(:initialize) do |*args, &block|
      pp 'instantiating class'
      super(*args, &block)
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
    define_initialize
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