import scala.util.{Failure, Success, Try}

object ParserTypes {
  //(parsedElement, notConsumed)
  type ParserOutput[+T] = (T, String)
  type ParserResult[T] = Try[ParserOutput[T]]
  type ParserType[T] = String => ParserResult[T]
  type ParserCondition[T] = T => Boolean
}
import ParserTypes._

class Parser[+T](criterion: ParserType[T]) {
  def parseIfNotEmpty(input: String): ParserResult[T] =
    if (input.isEmpty) Failure(new EmptyStringException) else criterion(input)

  def apply(input: String): ParserResult[T] = parseIfNotEmpty(input)
  
  def <|>[U >: T](anotherParser: Parser[U]) : Parser[U] = new Parser[U](input => this(input).orElse(anotherParser(input)))

  def <>[U](anotherParser: Parser[U]): Parser[(T, U)] = new Parser[(T,U)](
    this(_) match {
        case Success((parsedElement, notConsumed))
          => anotherParser(notConsumed).map(parserOutput => ( (parsedElement, parserOutput._1), parserOutput._2))
        case Failure(exception) => Failure(exception)
      }
  )

  def ~>[U](anotherParser: Parser[U]): Parser[U] = new Parser[U](
    this(_) match {
      case Success((_, notConsumed)) => anotherParser(notConsumed)
      case Failure(exception) => Failure(exception)
    }
  )

  def <~[U](anotherParser: Parser[U]): Parser[T] = new Parser[T](
    this(_) match {
      case Success((parsedElement, notConsumed))
        => anotherParser(notConsumed).map(parserOutput => (parsedElement, parserOutput._2))
      case Failure(exception) => Failure(exception)
    }
  )

  def satisfies(condition: ParserCondition[T]) = new Parser[T](
    this(_).filter(parserOutput => condition(parserOutput._1)).orElse(Failure(new NotSatisfiesException(condition)))
  )

  def opt = new Parser[Option[T]](
    input => this(input).map{ case (parsedElement, notConsumed) => (Some(parsedElement), notConsumed) }.orElse(Try(None, input))
  )
}

case object anyChar extends Parser[Char](input => Success(input.head, input.tail))

case class char(char: Char) extends Parser[Char](
  input => anyChar(input).filter(_._1 == char)
    .orElse(Failure(new CharacterNotFoundException(char, input)))
)

case object void extends Parser[Unit](input => Success((), input.tail))

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

case class string(string: String) extends Parser[String](
  input =>
    if (input.startsWith(string))
      Success(string, input.slice(string.length, input.length))
    else
      Failure(new NotTheRightStringException(string, input))
)