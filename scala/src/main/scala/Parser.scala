import scala.util.{Failure, Success, Try}


case object Parsers {
  type Parser = String => Try[ParserResult]

  def anyChar: Parser = input =>
    input.toList match {
      case List() => Failure (new EmptyStringException)
      case head :: tail => Success (new ParserResult (head.toString, tail.mkString))
  }

  def char(char: Char) : Parser = input =>
    this.anyChar(input).filter(result => result.parsedElement == char.toString).orElse(Failure(new CharacterNotFoundException(char, input)))

  def <|>(firstParser: Parser, secondParser: Parser): Parser = input =>
    (firstParser(input), secondParser(input)) match {
      case (Success(result), _) => Success(result)
      case (_, Success(result)) => Success(result)
      case (failure, _)=> failure
    }

}

class EmptyStringException extends Exception
class CharacterNotFoundException(char: Char, input: String) extends Exception("The character '$char' does not found in $input")
case class ParserResult(parsedElement: String, notConsumed: String)