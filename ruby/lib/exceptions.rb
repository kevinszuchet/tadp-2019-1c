#Errors

class ValidationError < StandardError
  def initialize(msg)
    super("The " + msg + " condition was not fulfilled")
  end
end

class InvariantError < ValidationError
  def initialize(msg="invariant")
    super
  end
end

class PreConditionError < ValidationError
  def initialize(msg="pre")
    super
  end
end

class PostConditionError < ValidationError
  def initialize(msg="post")
    super
  end
end