import scala.util.{Failure, Success, Try}
//ALTERNATIVA KEKO
case class Parser (input: String) {
  def anyChar: Try[ParserResult] = input.toList match {
    case List() => Failure (new EmptyStringException)
    case head :: tail => Success (new ParserResult (head.toString, tail.mkString))
  }

  def char(char: Char): Try[ParserResult] =
    if (input.startsWith(char.toString) || input.isEmpty) this.anyChar else Failure(new CharacterNotFoundException_(char, input))
}


class EmptyStringException extends Exception
class CharacterNotFoundException_(char: Char, input: String) extends Exception("The character '$char' does not found in $input")
case class ParserResult(parsedElement: String, notConsumed: String)

//OTRA ALTERNATIVA
class CharacterNotFoundException(char: String, input: String) extends Exception("The character '$char' does not found in $input")
case class BaseParser(parseLogic: (String, String) => Try[ParserResult] ) {
  def parse(input: String): Try[ParserResult] = input.toList match {
    case List() => Failure (new EmptyStringException)
    case head :: tail => parseLogic(head.toString, tail.mkString)
  }
}

class AnyChar() extends BaseParser (
    (parsedElement : String, notConsumed : String) =>
    Success(new ParserResult(parsedElement, notConsumed))
  ) {}

class CharParser(char: Char) extends BaseParser (    //Tuve que poner ese nombre por que claramente Char es
  (parsedElement : String, notConsumed : String) => // palabra reservada, se escuchan recomendaciones
    if(parsedElement == char)
      Success(new ParserResult(parsedElement, notConsumed))
    else
      Failure(new CharacterNotFoundException(parsedElement, parsedElement))
) {}