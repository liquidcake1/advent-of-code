val rec length : int list -> int = fn [] => 0 | _::xs => 1 + length xs

fun length ([]    : int list) : int = 0
  | length (_::xs : int list) : int = 1 + length xs

fun splitCommas ([#"\n"], a) = [implode (List.rev a)]
  | splitCommas (#","::l, a) = splitCommas (l, a)
  | splitCommas (#" "::l, a) = (implode (List.rev a))::splitCommas (l, [])
  | splitCommas (x::l, a) = splitCommas (l, x::a)

fun getAvailable () =
    let
        val SOME firstLine = TextIO.inputLine TextIO.stdIn
        val SOME _ = TextIO.inputLine TextIO.stdIn
      val _ = print firstLine
    in
        splitCommas (explode (firstLine), [])
    end

fun getWanted () =
    case TextIO.inputLine TextIO.stdIn of
        SOME l => l::getWanted()
        | NONE => []

fun removeNewLine s = implode(List.rev(tl(List.rev(explode(s)))))

fun readInput () =
    let val available = getAvailable ()
        val wanted = map removeNewLine (getWanted ())
    in
        (available, wanted)
    end

fun removePrefix (xs, ys) =
let fun removePrefix' (x::pre, y::from) =
  if x = y then removePrefix' (pre, from) else NONE
  | removePrefix' ([], from) = SOME from
  | removePrefix' (_, _) = NONE
in
  case removePrefix' (explode xs, explode ys) of
       SOME result => SOME (implode result)
     | NONE => NONE
end

fun removeAny available pattern =
let fun removeAny' (x::available, pattern) =
(case removePrefix (x, pattern) of
      SOME new => new::removeAny' (available, pattern)
    | NONE => removeAny' (available, pattern)
    )
    | removeAny' ([], _) = []
in removeAny' (available, pattern)
end

fun plus (l1, l2) =
let
  val l1' = List.rev l1
  val l2' = List.rev l2
  fun plus' (x::r1, y::r2) =
    (
    case x + y > 1000000 of
         true => ((x + y) mod 1000000)::plus'([1], plus'(r1, r2))
       | false => ((x+y)::plus'(r1,r2))
         )
       | plus' ([], r) = r
       | plus' (r, []) = r
in
  List.rev (plus' (l1', l2'))
end

fun sum l = List.reduce plus [0] l

fun bigIntToString l = String.concatWith ", " (List.map Int.toString l)

fun waysWanted ht available pattern =
let
  (*val _ = print pattern*)
  fun waysWanted' "" = [1]
    | waysWanted' rhs =
    (case HashTable.find ht rhs of
          SOME cached => cached
        | NONE =>
            let
              val ans = sum (List.map waysWanted' (removeAny available rhs))
              val _ = HashTable.insert ht (rhs, ans)
              (*val _ = print (rhs ^ " " ^ (bigIntToString ans) ^ "\n")*)
in ans
end)

            in waysWanted' pattern
            end

fun main () =
let val (available, wanted) = readInput ()
  val ht : (string, int list) HashTable.hash_table = HashTable.mkTable (HashString.hashString, (fn (x,y) => x = y)) (5, Fail("foo"))
in
  (*List.length (List.filter (fn x => x > 0) (List.map (waysWanted available)
  * wanted))*)
  (*available, wanted, (List.map (fn x => (x, (waysWanted ht available x)))
  * wanted)*)
  sum (List.map (fn x => (waysWanted ht available x)) wanted)
end
