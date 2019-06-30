import Musica._

package object MusicParser {

  //Silencio
  case object silencioParser extends Parser[Silencio](input =>
    ( char('_') <|> char('-') <|> char('~') )
      .map{
        case '_' => Silencio(Blanca)
        case '-' => Silencio(Negra)
        case '~' => Silencio(Corchea)
      }(input)
      .orElse((throw new NotASilenceException(input)))
  )

  //TODO si el input esta vacio, creo que querriamos que tambien devuelva un NotANoteException y por ahora no lo hace
  //Sonido
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

  case object figuraParser extends Parser[Figura](input =>
    ( string("1/16") <|> string("1/2") <|> string("1/4")  <|> string("1/8") <|> string("1/1") )
      .map{
        case "1/1" => Redonda
        case "1/2" => Blanca
        case "1/4" => Negra
        case "1/8" => Corchea
        case "1/16" => SemiCorchea
      }(input)
    .orElse(throw new NotAFigureException(input))
  )

  case object sonidoParser extends Parser[Sonido](
    ( tonoParser <> figuraParser ).map{ case (tono, figura) => Sonido(tono, figura) }(_)
  )

  case object acordeExplicitoParser extends Parser[Acorde](
    (tonoParser.sepBy(char('+')) <> figuraParser).map{ case (tonos, figura) => Acorde(tonos, figura) }(_)
  )

  case object acordeMenorMayorParser extends Parser[Acorde](
    ( ( tonoParser <> ( char('m') <|> char('M') ) ) <> figuraParser )
      .map{
        case ((Tono(octava, nota), 'm'), figura) => nota.acordeMenor(octava, figura)
        case ((Tono(octava, nota), 'M'), figura) => nota.acordeMayor(octava, figura)
      }(_)
  )

  case object acordeParser extends Parser[Acorde]( (acordeExplicitoParser <|> acordeMenorMayorParser)(_) )

  //Tocable
  case object tocableParser extends Parser[Tocable]( (silencioParser <|> sonidoParser <|> acordeParser)(_) )

  //Melodia
  case object melodiaParser extends Parser[Melodia](tocableParser.sepBy(char(' '))(_))

}
