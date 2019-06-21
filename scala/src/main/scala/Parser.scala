import scala.util.{Failure, Success, Try}

case object Parsers {
  type Parser = String => Try[ParserResult]
  def parseIfNotEmpty(parser: Parser): Parser = input =>
    input.toList match {
      case List() => Failure(new EmptyStringException)
      case _ => parser(input)
    }

  def anyChar: Parser =
    parseIfNotEmpty(input =>
      input.toList match {
        case List() => Failure (new EmptyStringException)
        case head :: tail => Success (new ParserResult (head.toString, tail.mkString))
      }
    )

  def char(char: Char) : Parser =
    parseIfNotEmpty(input =>
      this.anyChar(input).filter(result => result.parsedElement == char.toString)
      .orElse(Failure(new CharacterNotFoundException(char, input)))
    )
}

class EmptyStringException extends Exception
class CharacterNotFoundException(char: Char, input: String) extends Exception("The character '$char' does not found in $input")
case class ParserResult(parsedElement: String, notConsumed: String)