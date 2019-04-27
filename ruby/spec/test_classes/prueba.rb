require_relative '../../lib/before_and_after'

class Prueba
  attr_accessor :vida

  def initialize
    self.vida = 10
  end

  invariant { 1 > 0 }
  invariant { 1 > 0 }
  invariant { vida > 50 }

  pre { vida > 50 }
  post { vida > 20 }
  def materia
    :tadp
  end

  pre {}
  def otra_materia
    :pdep
  end

  pre { vida == 10 }
  post { vida == 19 }
  def si_la_vida_es_10_sumar(una_vida, otra_vida)
    self.vida += (una_vida + otra_vida)
    self.vida
  end
end
