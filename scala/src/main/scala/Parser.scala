import scala.util.{Failure, Success, Try}

class EmptyStringException extends Exception
class CharacterNotFoundException(char: Char, input: String)
      extends Exception(s"The character '$char' was not found in $input")
//class NotCorrectTypeException(input: String) extends Exception
//class NotALetterException(input: String) extends NotCorrectTypeException(input)
//class NotADigitException(input: String) extends NotCorrectTypeException(input)
class NotALetterException(input: String) extends Exception
class NotADigitException(input: String) extends Exception
class NotAnAlphaNumException(input: String) extends Exception
class NotTheRightStringException(expectedString : String, currentString: String)
      extends Exception (s"Expected $expectedString... but got $currentString")

case class ParserOutput[T](parsedElement: T, notConsumed: String)

//type Result[T] = (T, String)

sealed trait Parser[T] {
  def parseIfNotEmpty(input: String): Try[ParserOutput[T]] =
    if (input.isEmpty) Failure(new EmptyStringException) else parseCriterion(input)

  def apply(input: String): Try[ParserOutput[T]] = parseIfNotEmpty(input)

  def parseCriterion(input: String) : Try[ParserOutput[T]]

  def <|>(anotherParser: Parser[T]) : String => Try[ParserOutput[T]] = input =>
    this(input) match {
      case Success(parserResult) => Success(parserResult)
      case _ => anotherParser(input)
    }
}

case object anyChar extends Parser[Char] {
  def parseCriterion(input: String) : Try[ParserOutput[Char]] =
    Success(ParserOutput[Char](input.head, input.tail))
}

case class char(char: Char) extends Parser[Char] {
  def parseCriterion(input: String) : Try[ParserOutput[Char]] =
    anyChar(input).filter(_.parsedElement == char)
      .orElse(Failure(new CharacterNotFoundException(char, input)))
}

case object void extends Parser[Unit] {
  def parseCriterion(input: String) : Try[ParserOutput[Unit]] =
    Success(ParserOutput[Unit]((), input.tail))
}

// TODO generalizar letter y digit, hacen lo mismo
/*
case class TypeCheckerParser[ExceptionType <: NotCorrectTypeException](typeCheckerFunction: Char => Boolean) extends Parser[Char]{
  def parseCriterion(input: String): Try[ParserResult[Char]] =
    anyChar(input).filter(c => typeCheckerFunction(c))
      .orElse(Failure(new ExceptionType(input)))
}
object letter extends TypeCheckerParser[NotALetterException]((currentChar: Char) => currentChar.isLetter){}
object digit extends TypeCheckerParser[NotADigitException]((currentChar: Char) => currentChar.isDigit){}
*/
case object letter extends Parser[Char] {
  def parseCriterion(input: String): Try[ParserOutput[Char]] =
    anyChar(input).filter(_.parsedElement.isLetter)
      .orElse(Failure(new NotALetterException(input)))
}

case object digit extends Parser[Char] {
  def parseCriterion(input: String): Try[ParserOutput[Char]] =
    anyChar(input).filter(_.parsedElement.isDigit)
      .orElse(Failure(new NotADigitException(input)))
}

case object alphaNum extends Parser[Char] {
  def parseCriterion(input: String) : Try[ParserOutput[Char]] =
    (letter <|> digit)(input)
      .orElse(Failure(new NotAnAlphaNumException(input)))
}
//TODO Esta más lindo el código pero no usar char() cómo la anterior versión, debería usarlo?
case class string(headString: String) extends Parser[String] {
  def parseCriterion(input: String) : Try[ParserOutput[String]] = {
    if(input.startsWith(headString))
      Success(ParserOutput(headString, input.slice(headString.length, input.length)))
    else
      Failure(new NotTheRightStringException(headString, input))
  }
}