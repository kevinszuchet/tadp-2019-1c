class NotASilenceException(val input: String) extends Exception
class NotANoteException(val read: Char) extends Exception(s"Expected [A|B|C|D|E|F|G] but got $read")
class NotAFigureException(val input: String) extends Exception
