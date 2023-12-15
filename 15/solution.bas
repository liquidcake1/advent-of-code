REM OPEN "inputtest2.txt" FOR INPUT AS #2
DIM lengths(256, 1000)
DIM labels$(256, 1000)
LET a$ = ""
10 LINE INPUT #2, a$
PRINT len(a$)

LET sumsum = 0

20 LET x = INSTR(a$, ",")
IF x = 0 THEN LET t$ = a$ ELSE LET t$ = LEFT$(a$, x - 1)
PRINT t$, LEFT$(a$, 20)

LET i = 0
LET sum = 0
LET operator = 0
50 LET i = i + 1
51 IF i > LEN(t$) THEN GOTO 100
LET c = ASC(MID$(t$, i, 1))
IF c = ASC("=") THEN LET operator = sum + 1
IF c = ASC("-") THEN LET operator = -sum - 1
LET sum = sum + c
LET sum = sum * 17
LET sum = sum MOD 256
GOTO 50

100 IF x = 0 THEN GOTO 101
GOTO 102

101 LINE INPUT #2, a$
LET x = INSTR(a$, ",")
IF a$ = "a$" THEN GOTO 102
IF x = 0 THEN LET t2$ = a$ ELSE LET t2$ = LEFT$(a$, x - 1)
LET t$ = t$ + t2$
PRINT "Ate some more", t$, LEFT$(a$, 10)
GOTO 51

102 PRINT "The new checksum is", sum
IF operator > 0 THEN GOTO 200
IF operator < 0 THEN GOTO 300
PRINT "There was no mode"
STOP
103 LET sumsum = sumsum + sum
PRINT "The new sum of sums is", sumsum
IF x = 0 THEN GOTO 400
LET a$ = MID$(a$, x + 1)
GOTO 20

200 REM add
LET box = operator - 1
PRINT "The box to add to is", box
LET label$ = LEFT$(t$, LEN(t$) - 2)
PRINT "The label is", label$
LET length = ASC(RIGHT$(t$, 1)) - ASC("0")
PRINT "The new focal length is", length
LET i = 0
201 REM loop
IF labels$(box, i) = label$ THEN GOTO 210
IF labels$(box, i) = "" THEN GOTO 210
LET i = i + 1
GOTO 201

210 PRINT "Adding to position", i
LET labels$(box, i) = label$
LET lengths(box, i) = length
REM GOSUB 500
GOTO 103

300 REM remove
LET box = -operator - 1
PRINT "The box to delete from is", box
LET label$ = LEFT$(t$, LEN(t$) - 1)
PRINT "The label is", label$
LET i = 0
301 REM loop
PRINT "Box at", i, "label", labels$(box, i)
IF labels$(box, i) = label$ THEN GOTO 310
IF labels$(box, i) = "" THEN GOTO 310
LET i = i + 1
GOTO 301

310 REM loop
PRINT "Shuffling into position", i
LET labels$(box, i) = labels$(box, i + 1)
LET lengths(box, i) = lengths(box, i + 1)
IF labels$(box, i + 1) = "" THEN GOTO 320
LET i = i + 1
GOTO 310

320 PRINT "Done delete"
REM GOSUB 500
GOTO 103

400 REM end
LET power = 0
LET box = 0
LET i = 0
410 IF labels$(box, i) = "" THEN GOTO 420
LET lenspower = (box + 1) * (i + 1) * lengths(box, i)
PRINT "Lens power of box", box, "index", i, "label", labels$(box, i), "length", lengths(box, i), "is", lenspower
LET power = power + lenspower
PRINT "Total power is", power
LET i = i + 1
GOTO 410
420 LET box = box + 1
IF box = 256 THEN GOTO 430
LET i = 0
GOTO 410
430 STOP

500 REM debug boxes
PRINT "CONTENTS:"
LET box = 0
LET j = 0
510 REM loop
IF labels$(box, j) = "" THEN GOTO 520
PRINT "Box", box, j, "has", labels$(box, j), lengths(box, j)
LET j = j + 1
GOTO 510
520 LET box = box + 1
IF box = 256 THEN GOTO 530
LET j = 0
GOTO 510
530 RETURN
