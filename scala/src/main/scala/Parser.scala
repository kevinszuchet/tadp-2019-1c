import scala.util.{Failure, Success, Try}

class EmptyStringException extends Exception
class CharacterNotFoundException(char: Char, input: String) extends Exception("The character '$char' was not found in $input")
class NotALetterException(input: String) extends Exception
class NotADigitException(input: String) extends Exception

case class ParserResult[T](parsedElement: T, notConsumed: String)

sealed trait Parser[T] {
  def parseIfNotEmpty(input: String): Try[ParserResult[T]] =
    input.toList match {
      case List() => Failure(new EmptyStringException)
      case _ => parseCriterion(input)
    }

  def apply(input: String): Try[ParserResult[T]] = parseIfNotEmpty(input)

  def parseCriterion(input: String) : Try[ParserResult[T]]

  /*type Parser[T] = String => Try[ParserResult[T]]

  def <|>(anotherParser: Parser[???]) : Parser[???] = input =>
    this(input) match {
      case Success(parserResult) => Success(parserResult)
      case _ => anotherParser(input)
    }*/
}

case object anyChar extends Parser[Char] {
  def parseCriterion(input: String) : Try[ParserResult[Char]] =
    Success(ParserResult[Char](input.head, input.tail))
}

case class char(char: Char) extends Parser[Char] {
  def parseCriterion(input: String) : Try[ParserResult[Char]] =
    anyChar(input).filter(_.parsedElement == char)
      .orElse(Failure(new CharacterNotFoundException(char, input)))
}

case object void extends Parser[Unit] {
  def parseCriterion(input: String) : Try[ParserResult[Unit]] =
    Success(ParserResult[Unit]((), input.tail))
}

// TODO generalizar letter y digit, hacen lo mismo
case object letter extends Parser[Char] {
  def parseCriterion(input: String): Try[ParserResult[Char]] =
    anyChar(input).filter(_.parsedElement.isLetter)
      .orElse(Failure(new NotALetterException(input)))
}

case object digit extends Parser[Char] {
  def parseCriterion(input: String): Try[ParserResult[Char]] =
    anyChar(input).filter(_.parsedElement.isDigit)
      .orElse(Failure(new NotADigitException(input)))
}

case object alphaNum extends Parser[Char] {
  def parseCriterion(input: String) : Try[ParserResult[Char]] = ???
}

case class string(headSring: String) extends Parser[String] {
  def parseCriterion(input: String) : Try[ParserResult[String]] = ???
}