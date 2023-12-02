perl -pe 'chomp; print "$_ "; s/(.)/ord($1)." "/egs;s/$/\n/' <<END
Game
blue
red
green
: 
; 
, 
END

perl -pe 's/(.)/ord($1)." "/egs' | dc -e '
?
[
Sa
z0!=x
]dsxx   # push the full stack onto the stack of register a



[larsasa]sK # K: kill the top stack item

[
  0
  [
  1 + r
  ls x
  z 1 !=x
  ]Sx
  lx x
  Lx lK x
  Ls x # Clear s and push length
]Sx
[SL]Ss 71 97 109 101 32    lxx # L: "Game "
[SB]Ss 98 108 117 101      lxx # B: blue
[SR]Ss 114 101 100         lxx # R: red
[SG]Ss 103 114 101 101 110 lxx # G: green
[S,]Ss 44 32               lxx # ,: ", "
[S;]Ss 59 32               lxx # ;: "; "
[red]1:#
[green]2:#
[blue]3:#
LxlKx

[n10anf[End stack]n10an[Next char: ]nlan10an]SF     # F: debug

[
  # Input: reader, writer
  Sr Sw
  []Su # u: undo
  [
    Sa # Put bad char back
    Lt lw x # Put test char back
    [d Sa]su
    2Q
  ]Se  # e: exit
  0
  lr x d St # Get length
  [
    # Stack is: remain, matched from test str
    La d
    lr x d St # Get next expected char, store in t
    !=e # Unwind if not equal [ stack: badchar, remain, eaten ]
    d-- # Drop the char if they match
    1 - r 1 + r # Update counters
    d 0 !=l # Recurse if more to do
  ]dSlx
  r
  #[About to unwind]lFx
  # Stack is: matched from test str, unmatched from test str
  [
    # Move t back to test register, and maybe back to input
    Lt lu x lw x
    1 -
    d 0 !=l
  ]sl
  d0!=l
  Lt lw x # Put the length back
  + # Drop the 0
  LrlKx
  LwlKx
  LulKx
  LelKx
  LllKx
  # Stack is #unmatched chars
]SS                           # S: string equality

[Should be empty]n10an f 10an
  
  

#[Should be empty: ]nf[Yep.]n10an

[
  0
  [Sa -1si 2Q]St # t: terminate false (-1)
  [Lad--2Q]Sr    # r: terminate success (n)
  [
    1r
    [rd-r]St # t: set false
    d48>t
    d57<t
    LtlKx # Cleanup macro
    lKx   # Cleanup char
  ]Sn            # n: test numeric. (1)
  [
    la lnx 0=t # Exit if next char is not numeric.
    #[eat]n10anf[endeatn]n10an
    La48-r10*+
    la lnx 1=g # Recurse if next char is numeric.
  ]sg            # g: recurse
  lgx
  # Cleanup
  LtlKx
  LrlKx
  LnlKx
  LglKx
]sN
[[Exiting!]lFx10000Q]sQ

# N: read a number
# K: Kill top stack element
# S: read an exact string
[
  [Stack has bad elements at start of line] z 1 !=Q lKx
  # Read Game
  [SL] [LL] lS x
  [Expected Game] r 0!=Q lKx
  [Game ]n
  # Read game number
  lN x
  dn
  0 1:C
  0 2:C
  0 3:C
  # Read colon-space
  [Expected :] La 58 !=Q lKx
  [Expected space] La 32 !=Q lKx
  [: ]S?
  [Stack has bad elements after colour] z 2 !=Q lKx
  [
    l?n
    # Read number
    lN x
    dn
    [Expected space] La 32 !=Q lKx
    [ ]n
    0Sy
    [
      #[want to write]lFx
      1sy
      d;#n # Output colour name
      [lKx d;C]So
      #[Input: colnum count]lFx
      d;C
      #[Stack: oldcount colnum count]lFx
      3R
      #[Stack: count oldcount colnum]lFx
      d
      0 3-R
      #[Stack: count oldcount count colnum]lFx
      !>o
      #[Stack: newmax colnum]lFx
      d3R
      #[Stack: column newmax newmax]lFx
      d4Rr
      #[Stack: column newmax column newmax]lFx
      :C
      Lo lKx
    ]Ss

    #[Are we red?]lFx
    d
    [SR] [LR] lS x
    1 r 0=s
    lKx lKx

    #[Are we green?]lFx
    d
    [SG] [LG] lS x
    2 r 0=s
    lKx lKx

    #[Are we blue?]lFx
    d
    [SB] [LB] lS x
    3 r 0=s
    lKx lKx

    [No colour matched!] ly 0=Q lKx
    Ly lKx # Erase flag
    lKx # Erase count
    #[Terminal checks]lFx
    [Stack has bad elements after colour] z 2 !=Q lKx
    # Read comma?
    [, ]s? [S,] [L,] lS x
    0=l
    # Read comma?
    [; ]s? [S;] [L;] lS x
    0=l
  ]dSlx
  L? lKx
  [Stack has bad elements at end of loop] z 2 !=Q lKx
  [Expected newline] La 10 !=Q lKx
  1Sy
  [0sy]sb
  [; Total RED ]n1;Cn
  [; Total GREEN ]n2;Cn
  [; Total BLUE ]n3;Cn
  12 1;C >b
  13 2;C >b
  14 3;C >b
  [Stack has bad elements before test] z 2 !=Q lKx
  [dlX+sX]sI
  ly 1 =I
  [Stack has bad elements after test] z 2 !=Q lKx
  [; Possible? ]n lyn
  [; Sum: ]n lXn
  10an
  [Stack has bad elements at end of game] z 2 !=Q lKx
  100 !<M
]d SM x
'
