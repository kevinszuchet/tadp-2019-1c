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

    "Basic parsers" - {

      "anyChar" - {
        "deberia devolver un success de ParserResult(h, ola) cuando el string es hola" in {
          assertParserSucceededWithResult(anyChar("hola"), ('h', "ola"))
        }

        "deberia fallar cuando el string es vacio" in {
          assertEmptyString(anyChar("").get)
        }

        "deberia devolver un success cuando el input tiene un unico caracter" in {
          assertParserSucceededWithResult(anyChar("h"), ('h', ""))
        }
      }

      "char" - {
        "deberia devolver un success de ParserResult(c, hau) cuando el string es chau y el caracter es c" in {
          assertParserSucceededWithResult(char('c')("chau"), ('c', "hau"))
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
          assertParserSucceededWithResult(void("hola"), ((), "ola"))
        }

        "deberia fallar cuando el string es vacio" in {
          assertEmptyString(void("").get)
        }
      }

      "letter" - {
        "deberia devolver success con ParserResult(t, otal) cuando el string es total" in {
          assertParserSucceededWithResult(letter("total"), ('t', "otal"))
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
          assertParserSucceededWithResult(digit("123abc"), ('1', "23abc"))
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
          assertParserSucceededWithResult(alphaNum("total"), ('t', "otal"))
        }

        "deberia devolver success con ParserResult(1, 23abc) cuando el string es 123abc" in {
          assertParserSucceededWithResult(alphaNum("123abc"), ('1', "23abc"))
        }

        "deberia fallar cuando el string es (5 + 4)" in {
          assertNotAnAlphaNum(alphaNum("(5 + 4)").get)
        }

        "deberia fallar cuando el string es vacio" in {
          assertEmptyString(alphaNum("").get)
        }
      }

      "string" - {
        "deberia devolver success con ParserResult(hola, mundo!) cuando el string es hola mundo!" in {
          assertParserSucceededWithResult(string("hola")("hola mundo!"), ("hola", " mundo!"))
        }

        "deberia devolver success con ParserResult(hola, ) cuando el string es hola" in {
          assertParserSucceededWithResult(string("hola")("hola"), ("hola", ""))
        }

        "deberia fallar cuando el string es hol" in {
          assertNotTheRightStringException(string("hola")("hol").get)
        }

        "deberia fallar cuando el string es holgado" in {
          assertNotTheRightStringException(string("hola")("holgado").get)
        }
      }
    }

    "Combinators" - {

      "<|>" - {

        "con dos char parser's deberia devolver lo que el primero, si este puede parsear" in {
          assertParserSucceededWithResult((char('t') <|> char('c'))("test"), ('t', "est"))
        }

        "con dos char parser's deberia devolver lo que el segundo, si el primero no puede parsear" in {
          assertParserSucceededWithResult((char('c') <|> char('h'))("helado"), ('h', "elado"))
        }

        "se puede aplicar con dos parser's de distinto tipo" in {
          assertParserSucceededWithResult((anyChar <|> void)("input"), ('i', "nput"))
        }

        "Concatenación de <|>" - {

          "cuando se concatenan dos <|> con anyChar con input hola el resultado es (h, ola)" in {
            assertParserSucceededWithResult((anyChar <|> anyChar <|> anyChar) ("hola"), ('h', "ola"))
          }

          "al concatenar dos <|> con anycChar(c), digit y char(h) con input hola devuelve (h, ola)" in {
            assertParserSucceededWithResult((char('c') <|> digit <|> char('h')) ("hola"), ('h', "ola"))
          }

          "al concatenar dos <|> con un exito en el primero de los parsers, ese es el resultado (precedencia de izquiera a derecha)" in {
            assertParserSucceededWithResult((char('h') <|> digit <|> char('c')) ("hola"), ('h', "ola"))
          }

          "al concatenar dos <|> con tres parsers que no parsean el input hola falla" in {
            assertNotFoundCharacter((char('c') <|> digit <|> char('s')) ("hola").get)
          }
        }
      }
    }
  }
}
