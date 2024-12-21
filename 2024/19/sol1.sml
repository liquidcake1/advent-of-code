val rec length : int list -> int = fn [] => 0 | _::xs => 1 + length xs

fun length ([]    : int list) : int = 0
  | length (_::xs : int list) : int = 1 + length xs

fun splitCommas ([], a) = []
  | splitCommas (#","::l, a) = splitCommas (l, a)
  | splitCommas (#" "::l, a) = (implode (List.rev a))::splitCommas (l, [])
  | splitCommas (x::l, a) = splitCommas (l, x::a)

fun getAvailable () =
    let
        val SOME firstLine = TextIO.inputLine TextIO.stdIn
        val SOME _ = TextIO.inputLine TextIO.stdIn
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
let fun removeAny' (x::available, (pattern, deriv)) =
(case removePrefix (x, pattern) of
      SOME new => (new, x::deriv)::removeAny' (available, (pattern, deriv))
    | NONE => removeAny' (available, (pattern, deriv)))
    | removeAny' ([], _) = []
    in removeAny' (available, pattern)
    end

fun removeAnyNoDeriv available pattern =
       List.map (fn (pat, _) => pat)
         (removeAny available (pattern, []))

fun firstEmpty (first::rest) = 
  (case first of
       ("", deriv) => SOME deriv
     | _ => firstEmpty rest)
  | firstEmpty [] = NONE

fun hasEmpty (first::rest) = 
  (case first of
       "" => SOME ""
     | _ => hasEmpty rest)
  | hasEmpty [] = NONE

fun waysWanted available pattern =
let
  fun waysWanted' available [] = NONE
    | waysWanted' available patterns =
    case hasEmpty patterns of
         SOME deriv => SOME deriv
       | NONE =>
         waysWanted' available (ListMergeSort.uniqueSort String.compare
         (List.concat (List.map (removeAnyNoDeriv available) patterns)))

in waysWanted' available [pattern]
end

fun main () =
let val (available, wanted) = readInput ()
in
  List.length (List.filter (fn SOME x => true | NONE => false) (List.map (waysWanted available) wanted))
end
