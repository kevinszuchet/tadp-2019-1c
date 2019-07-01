import ParserTypes._

class WithNoConsumed(val notConsumed: String) extends Exception

class EmptyStringException extends WithNoConsumed("")
class CharacterNotFoundException(char: Char, input: String) extends WithNoConsumed(input)//(s"The character '$char' was not found in $input")
class NotALetterException(input: String) extends WithNoConsumed(input)
class NotADigitException(input: String) extends WithNoConsumed(input)
class NotAnAlphaNumException(input: String) extends WithNoConsumed(input)
class NotTheRightStringException(expectedString : String, notConsumed: String) extends WithNoConsumed(expectedString)// (s"Expected $expectedString... but got $currentString")
class NotSatisfiesException[T](condition: ParserCondition[T], notConsumed: String) extends WithNoConsumed(notConsumed)
class NotAnIntegerException(input: String) extends WithNoConsumed(input)