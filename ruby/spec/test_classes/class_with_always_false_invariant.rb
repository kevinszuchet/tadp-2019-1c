require_relative '../../lib/before_and_after'

class ClassWithAlwaysFalseInvariant
  invariant { pp "Invariant" ;1 > 2 }
end