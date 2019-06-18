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
        assertParserSucceededWithResult(new Parser("hola").anyChar, new ParserResult("h", "ola"))
      }

      "deberia fallar cuando el string es vacio" in {
        assertEmptyString(new Parser("").anyChar.get)
      }
    }

    "char" - {
      "deberia devolver un success de ParserResult(c, hau) cuando el string es chau y el caracter es c" in {
        assertParserSucceededWithResult(new Parser("chau").char('c'), new ParserResult("c", "hau"))
      }

      "deberia fallar cuando el string es hola y el caracter es c" in {
        assertNotFoundCharacter(new Parser("hola").char('c').get)
      }

      "deberia fallar cuando el string es vacio" in {
        assertEmptyString(new Parser("").char('c').get)
      }
    }
  }

}
