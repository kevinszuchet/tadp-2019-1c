import scala.util.{Failure, Success, Try}

object ParsersTypes {
  //(parsedElement, notConsumed)
  type ParserOutput[T] = (T, String)
  type ParserResult[T] = Try[ParserOutput[T]]
  type ParserCondition[T] = T => Boolean
}
import ParsersTypes._

class Parser[T](criterion: String => ParserResult[T]) {
  def parseIfNotEmpty(input: String): ParserResult[T] =
    if (input.isEmpty) Failure(new EmptyStringException) else criterion(input)

  def apply(input: String): ParserResult[T] = parseIfNotEmpty(input)

  def <|>(anotherParser: Parser[T]): Parser[T] = new Parser[T](input => this(input).orElse(anotherParser(input)))

  def <>[U](anotherParser: Parser[U]): Parser[(T, U)] = new Parser[(T,U)](
    this(_) match {
        case Success((parsedElement, notConsumed))
          => anotherParser(notConsumed).map(parserOutput => ((parsedElement, parserOutput._1), parserOutput._2))
        case Failure(exception) => Failure(exception)
      }
  )

  def ~>(anotherParser: Parser[T]): Parser[T] = new Parser[T](
    this(_) match {
      case Success((_, notConsumed)) => anotherParser(notConsumed)
      case Failure(exception) => Failure(exception)
    }
  )

  def <~(anotherParser: Parser[T]): Parser[T] = new Parser[T](
    this(_) match {
      case Success((parsedElement, notConsumed)) =>
        anotherParser(notConsumed).map(parserOutput => (parsedElement, parserOutput._2))
      case Failure(exception) => Failure(exception)
    }
  )

  def satisfies(condition: ParserCondition[T]) = new Parser[T](input =>
    this(input).filter(parserOutput => condition(parserOutput._1)).orElse(Failure(new NotSatisfiesException(condition, input)))
  )

  def opt: Parser[Option[T]] = new Parser[Option[T]](
    input => this(input).map{ case (parsedElement, notConsumed) => (Some(parsedElement), notConsumed) }.orElse(Try(None, input))
  )

  def * : Parser[List[T]] = new Parser[List[T]]( input =>
    this(input) match {
      case Success((parsedElement, "")) => Success(List(parsedElement), "")
      case Success((parsedElement, notConsumed))
        => this.*(notConsumed).map { case (parsed, stillNotConsumed) => (parsedElement :: parsed, stillNotConsumed) }
      case Failure(_) => Success(List(), input)
    }
  )

  def + = new Parser[List[T]](
    this(_) match {
      case Success((parsedElement, notConsumed)) => this.*(notConsumed).map { case (parsed, stillNotConsumed) => (parsedElement :: parsed, stillNotConsumed) }
      case Failure(exception) => Failure(exception)
    }
  )
}

case object anyChar extends Parser[Char](input => Success(input.head, input.tail))

class anyCharWithCondition(condition: ParserCondition[Char], exception: String => Throwable) extends Parser[Char](input =>
  anyChar.satisfies(condition)(input)
    .orElse(Failure(exception(input))))

case class char(char: Char) extends anyCharWithCondition(parsed => parsed == char, new CharacterNotFoundException(char, _))

case object void extends Parser[Unit](input => Success((), input.tail))

case object letter extends anyCharWithCondition(_.isLetter, new NotALetterException(_))

case object digit extends anyCharWithCondition(_.isDigit, new NotADigitException(_))

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
