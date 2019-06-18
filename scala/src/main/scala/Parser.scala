import scala.util.{Failure, Success, Try}

case class Parser (input: String) {
  def anyChar: Try[ParserResult] = input.toList match {
    case List() => Failure (new EmptyStringException)
    case head :: tail => Success (new ParserResult (head.toString, tail.mkString))
  }

  def char(char: Char): Try[ParserResult] =
    if (input.startsWith(char.toString) || input.isEmpty) this.anyChar else Failure(new CharacterNotFoundException(char, input))
}


class EmptyStringException extends Exception
class CharacterNotFoundException(char: Char, input: String) extends Exception("The character '$char' does not found in $input")
case class ParserResult(parsedElement: String, notConsumed: String)