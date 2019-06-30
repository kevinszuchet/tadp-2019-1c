class NotASilenceException(val input: String) extends Exception
class NotANoteException(val read: Char) extends Exception(s"Expected [A|B|C|D|E|F|G] but got $read")
class NotAToneException(val input: String) extends Exception
class NotAFigureException(val input: String) extends Exception
class NotASoundException(val input: String) extends Exception