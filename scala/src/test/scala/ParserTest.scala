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

  def assertNotALetter[T](actualResult: ⇒ T): Unit = {
    assertThrows[NotALetterException](actualResult)
  }

  def assertNotADigit[T](actualResult: ⇒ T): Unit = {
    assertThrows[NotADigitException](actualResult)
  }

  def assertNotAnAlphaNum[T](actualResult: ⇒ T): Unit = {
    assertThrows[NotAnAlphaNumException](actualResult)
  }
  def assertNotTheRightStringException[T](actualResult: ⇒ T): Unit = {
    assertThrows[NotTheRightStringException](actualResult)
  }

  "Parsers" - {

    "anyChar" - {
      "deberia devolver un success de ParserResult(h, ola) cuando el string es hola" in {
        assertParserSucceededWithResult(anyChar("hola"), new ParserResult('h', "ola"))
      }

      "deberia fallar cuando el string es vacio" in {
        assertEmptyString(anyChar("").get)
      }
    }

    "char" - {
      "deberia devolver un success de ParserResult(c, hau) cuando el string es chau y el caracter es c" in {
        assertParserSucceededWithResult(char('c')("chau"), new ParserResult('c', "hau"))
      }

      "deberia fallar cuando el string es hola y el caracter es c" in {
        assertNotFoundCharacter(char('c')("hola").get)
      }

      "deberia fallar cuando el string es vacio" in {
        assertEmptyString(char('c')("").get)
      }
    }

    "void" - {
      "deberia devolver success con ParserResult(null, ola) cuando el string es hola" in {
        assertParserSucceededWithResult(void("hola"), new ParserResult((), "ola"))
      }

      "deberia fallar cuando el string es vacio" in {
        assertEmptyString(void("").get)
      }
    }

    "letter" - {
      "deberia devolver success con ParserResult(t, otal) cuando el string es total" in {
        assertParserSucceededWithResult(letter("total"), new ParserResult('t', "otal"))
      }

      "deberia fallar cuando el string abc123" in {
        assertNotALetter(letter("123abc").get)
      }

      "deberia fallar cuando el string es vacio" in {
        assertEmptyString(letter("").get)
      }
    }

    "digit" - {
      "deberia devolver success con ParserResult(1, 23abc) cuando el string es 123abc" in {
        assertParserSucceededWithResult(digit("123abc"), new ParserResult('1', "23abc"))
      }

      "deberia fallar cuando el string abc123" in {
        assertNotADigit(digit("abc123").get)
      }

      "deberia fallar cuando el string es vacio" in {
        assertEmptyString(digit("").get)
      }
    }

    "alphaNum" - {
      "deberia devolver success con ParserResult(t, otal) cuando el string es total" in {
        assertParserSucceededWithResult(alphaNum("total"), new ParserResult('t', "otal"))
      }

      "deberia devolver success con ParserResult(1, 23abc) cuando el string es 123abc" in {
        assertParserSucceededWithResult(alphaNum("123abc"), new ParserResult('1', "23abc"))
      }

      "deberia fallar cuando el string es (5 + 4)" in {
        assertNotAnAlphaNum(alphaNum("(5 + 4)").get)
      }

      "deberia fallar cuando el string es vacio" in {
        assertEmptyString(alphaNum("").get)
      }
    }

    "string con hola como string cabecera" - {
      "deberia devolver success con ParserResult(hola, mundo!) cuando el string es hola mundo!" in {
        assertParserSucceededWithResult(string("hola")("hola mundo!"), new ParserResult("hola", " mundo!"))
      }

      "deberia devolver success con ParserResult(hola, ) cuando el string es hola" in {
        assertParserSucceededWithResult(string("hola")("hola"), new ParserResult("hola", ""))
      }

      "deberia fallar cuando el string es hol" in {
        assertNotTheRightStringException(string("hola")("hol").get)
      }

      "deberia fallar cuando el string es holgado" in {
        assertNotTheRightStringException(string("hola")("holgado").get)
      }

    }
  }
}
