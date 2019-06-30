import Musica._

package object MusicParser {

  case object silencioParser extends Parser[Silencio](
    ( char('_') <|> char('-') <|> char('~') )
      .map{
        case '_' => Silencio(Blanca)
        case '-' => Silencio(Negra)
        case '~' => Silencio(Corchea)
      }(_)
  )

  case object notaParser extends Parser[Nota](
    anyChar
      .map( charNota => Nota.notas.find(_.toString == charNota.toString).getOrElse(throw new NotANoteException(charNota)))
      .<>( (char('#') <|> char('b')).opt )
      .map{
        case (nota, Some('#')) => nota.sostenido
        case (nota, Some('b')) => nota.bemol
        case (nota, None) => nota
      }
    (_)
  )

  case object tonoParser extends Parser[Tono](
    (integer <> notaParser).map{ case (octava, nota) => Tono(octava, nota) }(_)
  )

  case object figuraParser extends Parser[Figura](
    ( string("1/16") <|> string("1/2") <|> string("1/4")  <|> string("1/8") <|> string("1/1") )
      .map{
        case "1/1" => Redonda
        case "1/2" => Blanca
        case "1/4" => Negra
        case "1/8" => Corchea
        case "1/16" => SemiCorchea
      }(_)
  )

  case object sonidoParser extends Parser[Sonido](
    ( tonoParser <> figuraParser ).map{ case (tono, figura) => Sonido(tono, figura) }(_)
  )

  case object tocableParser extends Parser[Tocable](
    (silencioParser <|> sonidoParser)(_)
  )

  case object melodiaParser extends Parser[Melodia](
    tocableParser.+(_)
  )
}
