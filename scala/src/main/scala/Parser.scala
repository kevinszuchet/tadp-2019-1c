import scala.util.{Failure, Success, Try}

case class Parser (input: String) {
  def anyChar: Try[ParserResult] = input.toList match {
    case List () => Failure (new EmptyStringException)
    case head :: tail => Success (new ParserResult (head.toString, tail.mkString) )
  }
}


class EmptyStringException() extends Exception()
case class ParserResult(parsedElement: String, notConsumed: String)