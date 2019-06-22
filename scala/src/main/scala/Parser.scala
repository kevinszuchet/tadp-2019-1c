import scala.util.{Failure, Success, Try}

object ParsersTypes{
  //(parsedElement, notConsumed)
  type ParserOutput[T] = (T, String)
  type ParserResult[T] = Try[ParserOutput[T]]
}
import ParsersTypes._

class Parser[T](parseCriterion: String => ParserResult[T]) {
  def parseIfNotEmpty(input: String): ParserResult[T] =
    if (input.isEmpty) Failure(new EmptyStringException) else parseCriterion(input)

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

case object anyChar extends Parser[Char](
  input => Success(input.head, input.tail)
)

case class char(char: Char) extends Parser[Char](
  input  => anyChar(input).filter(_._1 == char)
    .orElse(Failure(new CharacterNotFoundException(char, input)))
)

case object void extends Parser[Unit](
  input => Success(((), input.tail))
)

case object letter extends Parser[Char](
  input => anyChar(input).filter(_._1.isLetter)
    .orElse(Failure(new NotALetterException(input)))
)

case object digit extends Parser[Char](
  input => anyChar(input).filter(_._1.isDigit)
    .orElse(Failure(new NotADigitException(input)))
)

case object alphaNum extends Parser[Char](
  input => (letter <|> digit)(input)
    .orElse(Failure(new NotAnAlphaNumException(input)))
)

case class string(headString: String) extends Parser[String](
  input =>
  if(input.startsWith(headString))
    Success(headString, input.slice(headString.length, input.length))
  else
    Failure(new NotTheRightStringException(headString, input))
)