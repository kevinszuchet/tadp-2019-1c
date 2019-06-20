import org.scalatest.{FreeSpec, Matchers}

import scala.util.{Failure, Success}

class ParserTest extends FreeSpec with Matchers {

  def assertParserSucceededWithResult[T](actualResult: T, expectedResult: T): Unit = {
    actualResult shouldBe Success(expectedResult)
  }

  // TODO ver de pasar la excepcion por parametro
  def assertEmptyString[T](actualResult: ⇒ T): Unit = {
    assertThrows[EmptyStringException](actualResult)
  }

  def assertNotFoundCharacter[T](actualResult: ⇒ T): Unit = {
    assertThrows[CharacterNotFoundException](actualResult)
  }

  "Parsers" - {

    "anyChar" - {
      "deberia devolver un success de ParserResult(h, ola) cuando el string es hola" in {
        assertParserSucceededWithResult(Parser.anyChar("hola"), new ParserResult("h", "ola"))
      }

      "deberia fallar cuando el string es vacio" in {
        assertEmptyString(Parser.anyChar("").get)
      }
    }

    "char" - {
      "deberia devolver un success de ParserResult(c, hau) cuando el string es chau y el caracter es c" in {
        assertParserSucceededWithResult(Parser.char("chau", 'c'), new ParserResult("c", "hau"))
      }

      "deberia fallar cuando el string es hola y el caracter es c" in {
        //assertNotFoundCharacter(Parser.char("hola", 'c').get)
        throw new EmptyStringException
      }

      "deberia fallar cuando el string es vacio" in {
        assertEmptyString(Parser.char("", 'c').get)
      }
    }
  }

}
