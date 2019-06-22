import scala.util.{Failure, Success, Try}

class EmptyStringException extends Exception
class CharacterNotFoundException(char: Char, input: String)
      extends Exception(s"The character '$char' was not found in $input")
class NotALetterException(input: String) extends Exception
class NotADigitException(input: String) extends Exception
class NotAnAlphaNumException(input: String) extends Exception
class NotTheRightStringException(expectedString : String, currentString: String)
      extends Exception (s"Expected $expectedString... but got $currentString")

case class ParserResult[T](parsedElement: T, notConsumed: String)

sealed trait Parser[T] {
  def parseIfNotEmpty(input: String): Try[ParserResult[T]] =
    input.toList match {
      case List() => Failure(new EmptyStringException)
      case _ => parseCriterion(input)
    }

  def apply(input: String): Try[ParserResult[T]] = parseIfNotEmpty(input)

  def parseCriterion(input: String) : Try[ParserResult[T]]

  def <|>(anotherParser: Parser[T]) : String => Try[ParserResult[T]] = input =>
    this(input) match {
      case Success(parserResult) => Success(parserResult)
      case _ => anotherParser(input)
    }
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
  def parseCriterion(input: String) : Try[ParserResult[Char]] =
    (letter <|> digit)(input)
      .orElse(Failure(new NotAnAlphaNumException(input)))
}
//TODO Funciona pero esta horrible el código, habría que pensar cómo plantearlo de alguna otra manera
case class string(headString: String) extends Parser[String] {
  def parseCriterion(input: String) : Try[ParserResult[String]] = {
    headString.toList.foldLeft(Try(ParserResult("", input))) {
      (previousResult, currentChar) =>  (previousResult, currentChar) match {
        case(Success(ParserResult(parsedElement, notConsumed)), _) =>
          makePartialResult(new char(currentChar).apply(notConsumed), parsedElement, input)
        case _ => previousResult
      }
    }
  }

  def makePartialResult(result : Try[ParserResult[Char]], previousParsedElement: String, input: String) :
    Try[ParserResult[String]] = {
      result match {
        case(Success(ParserResult(parsedElement, notConsumed))) => Success(ParserResult(previousParsedElement + parsedElement.toString, notConsumed))
        case _ => Failure(new NotTheRightStringException(headString, input))
      }
  }

}