import scala.util.{Failure, Success, Try}

class EmptyStringException extends Exception
class CharacterNotFoundException(char: Char, input: String) extends Exception("The character '$char' was not found in $input")
case class ParserResult(parsedElement: String, notConsumed: String)

sealed trait ParserMixin {
  //TODO me esta dejando tiparlo como parser, aunque no es exactamente uno!
  def parseIfNotEmpty(input: String): Try[ParserResult] =
    input.toList match {
      case List() => Failure(new EmptyStringException)
      case _ => parseCriterion(input)
    }

  def apply(input: String): Try[ParserResult] = parseIfNotEmpty(input)

  def parseCriterion(input: String) : Try [ParserResult]
}

case object anyChar extends ParserMixin {
  def parseCriterion(input: String) : Try[ParserResult] =
    Success(ParserResult(input.head.toString, input.tail))
}

case class char(char: Char) extends ParserMixin {
  def parseCriterion(input: String) : Try[ParserResult] =
    anyChar(input).filter(result => result.parsedElement == char.toString)
      .orElse(Failure(new CharacterNotFoundException(char, input)))
}

/*case object void extends ParserInterface {
  def parseCriterion(input: String) : Try[ParserResult] =

}*/

/*case object letter extends ParserInterface {
  override def inputIsValid= (input: String) => super.inputIsValid(input).filter(_.head.isLetter)
  def parseCriterion: String => Char = anyChar.parseCriterion
}

case object digit extends ParserInterface {
  override def inputIsValid= (input: String) => super.inputIsValid(input).filter(_.head.isDigit)
  def parseCriterion: String => Char = anyChar.parseCriterion
}

case object alphaNum extends ParserInterface {
  override def inputIsValid= (input: String) => super.inputIsValid(input).filter(_.head.isLetterOrDigit)
  def parseCriterion: String => Char = anyChar.parseCriterion
}

case class string(headSring: String) extends ParserInterface {
  override def inputIsValid= (input: String) => super.inputIsValid(input).filter(_.contains(headSring))
  def parseCriterion: String => String = (input:String) => headSring
}*/