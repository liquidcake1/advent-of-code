REM OPEN "inputtest2.txt" FOR INPUT AS #2
LET a$ = ""
10 LINE INPUT #2, a$
PRINT len(a$)

LET sumsum = 0

20 LET x = INSTR(a$, ",")
IF x = 0 THEN LET t$ = a$ ELSE LET t$ = LEFT$(a$, x - 1)
PRINT t$, LEFT$(a$, 20)

LET i = 0
LET sum = 0
50 LET i = i + 1
IF i > LEN(t$) THEN GOTO 100
LET sum = sum + ASC(MID$(t$, i, 1))
LET sum = sum * 17
LET sum = sum MOD 256
GOTO 50

100 IF x = 0 THEN GOTO 101
GOTO 102

101 LINE INPUT #2, a$
LET x = INSTR(a$, ",")
IF a$ = "a$" THEN GOTO 102
IF x = 0 THEN LET t$ = a$ ELSE LET t$ = LEFT$(a$, x - 1)
LET i = 0
PRINT "Ate some more", t$, LEFT$(a$, 10)
GOTO 50

102 PRINT "The new checksum is", sum
LET sumsum = sumsum + sum
PRINT "The new sum of sums is", sumsum
IF x = 0 THEN STOP
LET a$ = MID$(a$, x + 1)
GOTO 20
