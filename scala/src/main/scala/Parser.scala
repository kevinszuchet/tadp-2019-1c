import scala.util.{Failure, Success, Try}

case object Parser {
  def anyChar(input: String): Try[ParserResult] = input.toList match {
    case List() => Failure (new EmptyStringException)
    case head :: tail => Success (new ParserResult (head.toString, tail.mkString))
  }

  def char(input: String, char: Char): Try[ParserResult] =
    this.anyChar(input).filter(aChar => aChar == char).orElse(Failure(new EmptyStringException))
}


class EmptyStringException extends Exception
class CharacterNotFoundException(char: Char, input: String) extends Exception("The character '$char' does not found in $input")
case class ParserResult(parsedElement: String, notConsumed: String)