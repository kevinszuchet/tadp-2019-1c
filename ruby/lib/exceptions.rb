#Errors

class InvariantError < StandardError
  def initialize(msg="No se cumplio con una invariante")
    super
  end
end

class PreconditionError < StandardError
  def initialize(msg="Failed to meet precondition")
    super
  end
end

class PostconditionError < StandardError
  def initialize(msg="Failed to meet postcondition")
    super
  end
end