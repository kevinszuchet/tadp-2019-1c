import Parsers.char

import scala.util.Try

package object C {

  type Parser= String

  object Combinators {
    def <|> : Parser => Parser => Parser = (parser1: Parser) => (parser2: Parser) => "parser3"
  }

}
