object sol1 {
  def main(args: Array[String]) = {
    val contents = scala.io.Source.fromFile(args(0)).mkString
    println(contents.split("\n").reduce((x, y) => x + ", " + y))
    val sb = new StringBuilder()
    //println(((0 until 10).foldLeft(Array(123))((x, _) => x ++ Array(next_secret(x(x.length - 1))))).addString(sb, ", "))
    //println(next_secret(123))
    //println((0 until 10).reduce((x, y) => x + y))
    println(contents.split("\n").map(_.toLong).map(next_nth_secret(2000, _)).reduce(_+_))
  }

  def next_secret(last_secret: Long) = {
    val postmul = (last_secret ^ (last_secret * 64)) % 16777216
    val postdiv = (postmul ^ (postmul / 32)) % 16777216
    val postmul2 = (postdiv ^ (postdiv * 2048)) % 16777216
    if (postmul2 > 0) { postmul2 } else { 16777216 + postmul2 }
  }

  def next_nth_secret(n: Int, last_secret: Long) = {
    (0 until n).foldLeft(last_secret)((x, _) => next_secret(x))
  }
}
