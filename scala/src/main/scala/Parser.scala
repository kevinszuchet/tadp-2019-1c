import scala.util.{Failure, Success, Try}

class EmptyStringException extends Exception
class CharacterNotFoundException(char: Char, input: String) extends Exception(s"The character '$char' was not found in $input")
class NotALetterException(input: String) extends Exception
class NotADigitException(input: String) extends Exception
class NotAnAlphaNumException(input: String) extends Exception
class NotTheRightStringException(expectedString : String, currentString: String) extends Exception (s"Expected $expectedString... but got $currentString")

object ParsersTypes {
  //(parsedElement, notConsumed)
  type ParserOutput[T] = (T, String)
  type ParserResult[T] = Try[ParserOutput[T]]
}
import ParsersTypes._

class Parser[T](criterion: String => ParserResult[T]) {
  def parseIfNotEmpty(input: String): ParserResult[T] =
    if (input.isEmpty) Failure(new EmptyStringException) else criterion(input)

  def apply(input: String): ParserResult[T] = parseIfNotEmpty(input)

  def <|>(anotherParser: Parser[T]) : Parser[T] =
    new Parser[T](
      input =>
        this(input) match {
          case Success(parserResult) => Success(parserResult)
          case _ => anotherParser(input)
        }
    )
}

// TODO refactor para dejar todos inline (excepto string que no calienta). Todos haces casi lo mismo (ver transform)

case object anyChar extends Parser[Char](input => Success((input.head, input.tail))) {}

case class char(char: Char) extends Parser[Char](
    input => anyChar(input).filter(_._1 == char)
      .orElse(Failure(new CharacterNotFoundException(char, input)))
) {}

case object void extends Parser[Unit](input => Success(((), input.tail))) {}

case object letter extends Parser[Char](
  input => anyChar(input).filter(_._1.isLetter)
    .orElse(Failure(new NotALetterException(input)))
) {}

case object digit extends Parser[Char](
  input => anyChar(input).filter(_._1.isDigit)
    .orElse(Failure(new NotADigitException(input)))
) {}

case object alphaNum extends Parser[Char](
  input => (letter <|> digit)(input)
    .orElse(Failure(new NotAnAlphaNumException(input)))
) {}

case class string(string: String) extends Parser[String](
  input =>
    if (input.startsWith(string))
      Success(string, input.slice(string.length, input.length))
    else
      Failure(new NotTheRightStringException(string, input))
) {}