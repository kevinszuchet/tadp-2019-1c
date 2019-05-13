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

  def define_method_added
    # TODO este if no lo esta tomando. de todas formas: podemos evitar redefinir un metodo al pedo, sin este if?
    # if !self.methods.include?(:method_added)
    def self.method_added(method_name)
      #No es necesario self.was_redefined ||= false
      unless self.was_redefined
        #Disable was_redefined para cortar la recursividad
        self.was_redefined = true
        #Get UnboundMethod
        original_method = instance_method(method_name)
        #Redefine method
        redefine_method(original_method)
        #Enable was_redefined para poder seguir redefiniendo metodos
        self.was_redefined = false
      end
    end
  end

  def redefine_method(method)
    #Bindeo los pre y post con el metodo
    set_validations_for_defined_method(self.befores, method.name)
    set_validations_for_defined_method(self.afters, method.name)
    
    self.define_method(method.name) { |*args, &block|
      #Clono el objeto para no tener que reestablecer los metodos luego
      self_clone = self.class.add_method_args_as_methods(self.clone, method, args)

      #Execute befores
      self_clone.class.validate(self_clone, self_clone.class.befores, method.name)

      #Execute method in clone because it could have effect and get result
      result = method.bind(self_clone).call(*args, &block)

      #Execute afters
      self_clone.class.validate(self_clone, self_clone.class.afters, method.name, result)

      #Execute method and return result
      method.bind(self).call(*args, &block)
    }
  end

  def set_validations_for_defined_method(validations, method_name)
    # TODO revisar el filter: alguna forma mejor de hacerlo?
    validations.select { |validation| !validation.already_has_method }
        .map {|validation| validation.for_method(method_name) }
  end

  def add_method_args_as_methods(object, method, args)
    #Agrego los parametros del metodo como metodos al objeto
    method.parameters.map { |arg| arg[1] }
      .zip(args).each { |param|
        object.define_singleton_method(param[0]) { param[1] }
      }
    #Retorno el objeto
    return object
  end

  def validate(instance, validations, method_name, method_result = nil)
    validations.select { |validation| validation.should_validate? method_name }
      .each { |validation| validation.validate_over(instance, method_result) }
  end

  def define_initialize
    self.define_method(:initialize) do
    end
  end

  def before_and_after_each_call(_before, _after)
    befores.push(BeforeAfterMethod.new(_before))
    afters.push(BeforeAfterMethod.new(_after))
    define_method_added
  end

  def invariant(&condition)
    afters.push(InvariantValidation.new(&condition))
    define_initialize
    define_method_added
  end

  # TODO rename condition_with_validation por validate fulfillment
  def pre(&condition)
    befores.push(PrePostValidation.new(&condition))
    define_method_added
  end

  def post(&condition)
    afters.push(PrePostValidation.new(&condition))
    define_method_added
  end
end