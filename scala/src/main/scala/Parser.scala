import scala.util.{Failure, Success, Try}

class EmptyStringException extends Exception
class CharacterNotFoundException(char: Char, input: String)
      extends Exception(s"The character '$char' was not found in $input")
class NotALetterException(input: String) extends Exception
class NotADigitException(input: String) extends Exception
class NotAnAlphaNumException(input: String) extends Exception
class NotTheRightStringException(expectedString : String, currentString: String)
      extends Exception (s"Expected $expectedString... but got $currentString")

case class ParserOutput[T](parsedElement: T, notConsumed: String)
//type ParserResult[T] = Try[ParserOutput[T]]

class Parser[T](parseCriterion: String => Try[ParserOutput[T]]) {
  def parseIfNotEmpty(input: String): Try[ParserOutput[T]] =
    if (input.isEmpty) Failure(new EmptyStringException) else parseCriterion(input)

  def apply(input: String): Try[ParserOutput[T]] = parseIfNotEmpty(input)

  def <|>(anotherParser: Parser[T]) : Parser[T] =
    new Parser[T](
      input =>
        this(input) match {
          case Success(parserResult) => Success(parserResult)
          case _ => anotherParser(input)
        }
    )
}
case object anyChar extends Parser[Char](
    input => Success(ParserOutput[Char](input.head, input.tail))
) {}

case class char(char: Char) extends Parser[Char](
    input  => anyChar(input).filter(_.parsedElement == char)
      .orElse(Failure(new CharacterNotFoundException(char, input)))
) {}

case object void extends Parser[Unit](
  input => Success(ParserOutput[Unit]((), input.tail))
) {}

case object letter extends Parser[Char](
  input => anyChar(input).filter(_.parsedElement.isLetter)
    .orElse(Failure(new NotALetterException(input)))
) {}

case object digit extends Parser[Char](
  input => anyChar(input).filter(_.parsedElement.isDigit)
    .orElse(Failure(new NotADigitException(input)))
) {}

case object alphaNum extends Parser[Char](
  input => (letter <|> digit)(input)
    .orElse(Failure(new NotAnAlphaNumException(input)))
) {}


case class string(headString: String) extends Parser[String](
  input =>
  if(input.startsWith(headString))
    Success(ParserOutput(headString, input.slice(headString.length, input.length)))
  else
    Failure(new NotTheRightStringException(headString, input))
) {}