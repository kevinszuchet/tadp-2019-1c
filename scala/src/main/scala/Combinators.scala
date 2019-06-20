import Parsers.char

import scala.util.Try

package object C {

  type Parser= String

  case class Combinators{
    def <|> : Parser => Parser => Parser = (parser1: Parser) => (parser2: Parser) => "parser3"

    def sabee(parser1: Combinators): Combinators => Parser = (parser2: Combinators) => "holaa"

    def a: Unit ={
      val aob =  "a" sabee "b"
      val a = <|>("a")("B")
    }
  }

}
