require_relative 'exceptions'
require_relative 'validation'

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

      # Este unless es para que no entrar en un loop: aca adentro estamos incluyendo un mixin, send(:include, mixin_clone)
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
      unless self.was_redefined
        #Para evitar un loop
        self.was_redefined = true
        #Obtiene el unbound method
        original_method = instance_method(method_name)
        redefine_method(original_method)
        #Para poder seguir agregando metodos luego
        self.was_redefined = false
      end
    end
  end

  def redefine_method(method)
    #Seteo las nuevas validaciones para el ultimo metodo que se agrego
    set_validations_for_defined_method(self.befores, method.name)
    set_validations_for_defined_method(self.afters, method.name)
    
    self.define_method(method.name) { |*args, &block|
      #Clono el objeto para no tener el problema que conllevaba poner y sacar los metodos (pudiendo sacar metodos que no queremos)
      self_clone = self.clone

      #Seteo los parametros como metodos para que las validaciones puedan usarlos
      self.class.add_method_args_as_methods(self_clone, method, args)

      #Ejecuta los befores
      self_clone.class.validate(self_clone, self_clone.class.befores, method.name)

      #Ejecuta el metodo en el clone porque podria tener efecto
      result = method.bind(self_clone).call(*args, &block)

      #Ejecuta los afters
      self_clone.class.validate(self_clone, self_clone.class.afters, method.name, result)

      #Si llego hasta aca es porque paso todas las validaciones => ejecuta el metodo (solo el cachito original) sobre la instancia original
      method.bind(self).call(*args, &block)
    }
  end

  def set_validations_for_defined_method(validations, method_name)
    validations.each {|validation| validation.for_method(method_name) }
  end

  def add_method_args_as_methods(instance, method, args)
    #Agrego los parametros del metodo como metodos al objeto
    method.parameters.map { |arg| arg[1] }
      .zip(args).each { |param|
        instance.define_singleton_method(param[0]) { param[1] }
      }
  end

  def validate(instance, validations, method_name, method_result = nil)
    validations.each { |validation| validation.execute_over(instance, method_name, method_result) }
  end

  def define_initialize
    self.define_method(:initialize) do
    end
  end

  def add_validation(validation, where)
    where.push(validation)
    define_method_added
  end

  def before_and_after_each_call(_before, _after)
    add_validation(BeforeAfterMethod.new(_before), self.befores)
    add_validation(BeforeAfterMethod.new(_after), self.afters)
  end

  def invariant(&condition)
    add_validation(InvariantValidation.new(condition), self.afters)
    define_initialize
  end

  def pre(&condition)
    add_validation(PrePostValidation.new(condition, PreConditionError), self.befores)
  end

  def post(&condition)
    add_validation(PrePostValidation.new(condition, PostConditionError), self.afters)
  end
end