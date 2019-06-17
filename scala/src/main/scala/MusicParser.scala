import java.io.{PushbackReader, StringReader}
import Musica._

case class Note(name: String)

class MusicParser(input: String) {
  protected val inputStream = new PushbackReader(new StringReader(input))

  protected def parseChar(): Char = {
    val parsed = inputStream.read()
    if (parsed == -1) throw new EOIParserException
    return parsed.toChar
  }
  protected def parseNote(): Melodia = {
    var next: Char = ' '
    do next = parseChar() while (next == ' ')

    if (next.isDigit) {
      var times: Int = 0
      do {
        times = (times * 10) + next.asDigit
        next = parseChar()
        if (!next.isDigit && next != 'x') throw new NotAValidPatternException(next)
      } while (next.toLower != 'x')

      next = parseChar()
      if (next != '(') throw new NotAValidPatternException(next)

      val pattern = this.parse()
      return List.fill(times)(pattern).flatten
    }

    if (next == ')') {
      throw new EOIParserException()
    }

    List[Nota](Nota.notas.find(_.toString == next.toString()).getOrElse(throw new NotANoteException(next)))
  }

  def parse(): Melodia = {
    var result: Melodia = List()
    try while (true) {
      val notas: Melodia = parseNote()
      result = result ::: notas
    }
    catch {
      case _: EOIParserException =>
    }
    return result
  }
}

class ParserException(reason: String) extends Exception(reason)
class EOIParserException extends ParserException("reached end of input")
class NotANoteException(val read: Char) extends ParserException(s"Expected [A|B|C|D|E|F|G] but got $read")
class NotAValidPatternException(val read: Char) extends ParserException(s"Expected NUMx([A|B|C|D|E|F|G]+) but got $read")