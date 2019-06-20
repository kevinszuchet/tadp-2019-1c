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
        assertParserSucceededWithResult(new AnyChar().parse("hola"), new ParserResult('h', "ola"))
      }

      "deberia fallar cuando el string es vacio" in {
        assertEmptyString(new AnyChar().parse("").get)
      }
    }

    "char" - {
      "deberia devolver un success de ParserResult(c, hau) cuando el string es chau y el caracter es c" in {
        assertParserSucceededWithResult(new CharParser('c').parse("chau"), new ParserResult('c', "hau"))
      }

      "deberia fallar cuando el string es hola y el caracter es c" in {
        assertNotFoundCharacter(new CharParser('c').parse("hola").get)
      }

      "deberia fallar cuando el string es vacio" in {
        assertEmptyString(new CharParser('c').parse("").get)
      }
    }
  }

}
