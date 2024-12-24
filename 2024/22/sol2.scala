object sol2 {
  def main(args: Array[String]) = {
    val contents = scala.io.Source.fromFile(args(0)).mkString
    println(contents.split("\n").reduce((x, y) => x + ", " + y))
    val sb = new StringBuilder()
    //println(((0 until 10).foldLeft(Array(123))((x, _) => x ++ Array(next_secret(x(x.length - 1))))).addString(sb, ", "))
    //println(next_secret(123))
    //println((0 until 10).reduce((x, y) => x + y))
    println(contents.split("\n").map(_.toInt).map(next_nth_secret(2000, _)).reduce(_+_))
    val histories_with_vals = contents.split("\n").map(_.toInt).
    //val histories_with_vals = Array("123").map(_.toInt).
      map(
        (0 to 2000).scanLeft(_)((x, _) => next_secret(x)).
        map(_ % 10).
        sliding(5).map((a) => (a(4), (0 until 4).map((x) => a(x+1) - a(x)))).toArray
      ).toArray
    val monkey_history_maps = histories_with_vals.map(
      _.reverse.map((x)=>(x._2,x._1)).toMap)
    //println(monkey_history_maps.map(_.get(Vector(-2, 1, -1, 3))).mkString)
    val monkey_sequence_scores = monkey_history_maps.reduce(
      (a, b) => a.foldLeft(b)((acc, kv) => acc.updated(kv._1, acc.getOrElse(kv._1, 0) + kv._2)))
    val best = monkey_sequence_scores.maxBy(_._2)
    //println(monkey_sequence_scores(Vector(-2, 1, -1, 3)))
    println("The answer is ", best)


    /*val histories_to_search = (for (
         a <- -9 until 10;
         b <- -9 until 10 if a + b < 10 && a + b > -10;
         c <- -9 until 10 if a + b + c < 10 && a + b + c > -10;
         d <- -8 until 10 if a + b + c + d < 10 && a + b + c + d > -10)
       yield Vector(-a, -b, -c, -d)).toArray*/
    val histories_to_search1 = Array(Vector(-2, 1, -1, 3))
    //val histories_to_search = histories_with_vals.map(_.map(_._2).toSet).reduce(_++_).toArray
    //println(histories_to_search.length)
    /*val answer = histories_to_search.map((x) => {
        println(x)
        histories_with_vals.map(
          _.filter(_._2 == x)
        ).filter(_.length > 0).map(_.head._1)
    }
    ).filter(_.length > 0).map(_.reduce((x: Int, y: Int) => x + y)).max*/
    //println(answer.map(_.mkString("  \n")).mkString("\n"))
    //println(answer)


      
    //println((0 until 10).scanLeft(123)((x, _) => next_secret(x)).addString(sb, ", "))
    println((0 until 10).sliding(4).map(_.reduce(_+_)).addString(sb, ","))
    println(null)
  }

  def next_secret(last_secret: Int) = {
    val postmul = (last_secret ^ (last_secret * 64)) % 16777216
    val postdiv = (postmul ^ (postmul / 32)) % 16777216
    val postmul2 = (postdiv ^ (postdiv * 2048)) % 16777216
    if (postmul2 > 0) { postmul2 } else { 16777216 + postmul2 }
  }

  def next_nth_secret(n: Int, last_secret: Int) = {
    (0 until n).foldLeft(last_secret)((x, _) => next_secret(x))
  }
}
