import scala.util.{Failure, Success, Try}

package object Parsers {

  sealed trait Parser{
    def parseText[A](input: String, parser: String => A): Try[A] ={
      inputIsValid(input).map(input => parser(input))
      /*inputIsValid(input) match{
        case Success(value) => Try(parser(value))
        case Failure(exception) => Failure(exception)
        //case default => Try(default)
      }*/
    }

    def inputIsValid: String => Try[String] = (input: String) => Try(if (input.isEmpty) input else throw ParseException())
  }

  case object anyChar extends Parser {
    def parseCriterion: String => Char = (input:String) => input.head
    def apply(input: String): Try[Char] = parseText(input, parseCriterion)
  }

  case class char(headChar: Char) extends Parser {
    override def inputIsValid= (input: String) => super.inputIsValid(input).filter(_.head.equals(headChar))
    def parseCriterion: String => Char = anyChar.parseCriterion
    def apply(input: String): Try[Char] = parseText(input, parseCriterion)
  }

  case object void extends Parser {
    def parseCriterion: String => Unit = (input:String) => Unit
    def apply(input: String): Try[Unit] = parseText(input, parseCriterion)
  }

  case object letter extends Parser {
    override def inputIsValid= (input: String) => super.inputIsValid(input).filter(_.head.isLetter)
    def parseCriterion: String => Char = anyChar.parseCriterion
    def apply(input: String): Try[Char] = parseText(input, parseCriterion)
  }

  case object digit extends Parser {
    override def inputIsValid= (input: String) => super.inputIsValid(input).filter(_.head.isDigit)
    def parseCriterion: String => Char = anyChar.parseCriterion
    def apply(input: String): Try[Char] = parseText(input, parseCriterion)
  }

  case object alphaNum extends Parser {
    override def inputIsValid= (input: String) => super.inputIsValid(input).filter(_.head.isLetterOrDigit)
    def parseCriterion: String => Char = anyChar.parseCriterion
    def apply(input: String): Try[Char] = parseText(input, parseCriterion)
  }

  case class string(headSring: String) extends Parser {
    override def inputIsValid= (input: String) => super.inputIsValid(input).filter(_.contains(headSring))
    def parseCriterion: String => String = (input:String) => headSring
    def apply(input: String): Try[String] = parseText(input, parseCriterion)
  }






}
