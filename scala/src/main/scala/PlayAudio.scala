import com.sun.net.httpserver.Authenticator.Success

import scala.util.Try

object PlayAudio extends App {
  val a: String = "holaaa"
  val b: String = "4adads"

  //val e = for (x <- a if x == 'c') yield x
  val e = Try(a.filter(c => c == 'c').head)

  var f = Try(a.head.charValue())
  var g = Try(a.head.isDigit)
  var h = Try(a.head.isLetter)

  var q = Option("")

  //var q = char2('b')
  //System.out.println(q)
  //System.out.println(q("holaaa"))


  System.out.println("aaa")
  System.out.println(q)
  System.out.println(q.get)
  System.out.println("aaa")

  System.out.println(f)
  System.out.println(g)
  System.out.println(h)
  System.out.println("gatoo")
  System.out.println(a.contains('c'))
  System.out.println(a.head)
  System.out.println(Try(a.head.toString))
  System.out.println(Try(b.head.toString))


  //val synfonicDeMusicaLigera = "20x(4x(B) 5x(G) 4x(D) 8x(A))"

  //AudioPlayer.reproducir(synfonicDeMusicaLigera)
}
