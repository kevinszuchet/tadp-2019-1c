import ParsersTypes._

case class ParserException(intput:String = "") extends Exception

class EmptyStringException extends ParserException
class CharacterNotFoundException(char: Char, input: String) extends ParserException(input)//(s"The character '$char' was not found in $input")
class NotALetterException(input: String) extends ParserException(input)
class NotADigitException(input: String) extends ParserException(input)
class NotAnAlphaNumException(input: String) extends ParserException(input)
class NotTheRightStringException(expectedString : String, currentString: String) extends ParserException(currentString)// (s"Expected $expectedString... but got $currentString")
class NotSatisfiesException[T](condition: ParserCondition[T]) extends ParserException
