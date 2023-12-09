variable buf-size 2000 buf-size !
create line-buf buf-size @ allot ( create a new name line-buf pointing at the current heap, then advance heap by that amount )
variable stack-size 1000 stack-size !
create n-buf stack-size @ 2 * cell * allot ( create a buf of stack-size double ints )
variable #depth ( create a single cell var of depth )
stack-size @ #depth !
: init-stack
	( .\" \ninit-stack\n" )
	#depth @ n-buf
	begin
		dup 0 0 rot 2!
		2 cell * + swap 1 - swap
		over
		0 =
	until
	2drop
	0 #depth !
	( .\" \nend init-stack\n" )
;
: print-stack
	.\" \nprint-stack\n"
	#depth @ n-buf
	begin
		.\" Stack at " dup . ." is " dup 2@ d. .\" \n"
		2 cell * + swap 1 - swap
		over
		0 =
	until
	2drop
	.\" end print-stack\n"
;
: sum-stack
	( .\" \nsum-stack\n" )
	0 0 #depth @ n-buf
	begin
		2tuck nip 2@ d+ 2swap
		2 cell * + swap 1 - swap
		over
		0 =
	until
	2drop
	( .\" end sum-stack\n" )
;
: add-to-stack
	( .\" \nadd-to-stack" .s .\" \n" )
	#depth @ dup 1 + #depth !
	n-buf
	begin
		( stack is val2 depth-left ptr )
		2swap
		2over nip
		2@    ( stack dl ptr val2 old2 )
		2over 2swap d-  ( stack dl ptr val2 diff2 )
		2swap 2rot 2tuck nip ( stack diff2 dl ptr val2 dl ptr )
		2!
		2 cell * + swap 1 - swap
		over 1 + 0 =
	until
	2drop 2drop
	( .\" \nend add-to-stack" .s .\" \n" )
;
: read-numbers 
	.\" \nread-numbers" .s .\" \n"
	begin
		over c@ 45 - 0 =
		if
			swap 1 + swap 1 - ( skip the minus )
			1
		else
			0
		endif
		-rot
		0 0 2swap
		>number ( parse a number out )
		.\" \npost-read: " .s .\" \n"
		2swap
		4 roll
		if
			dnegate
		endif
		add-to-stack
		dup
		.\" \nTest in read-numbers: " over . .s .\" \n"
	while
		swap 1 + swap 1 - ( skip the space )
		.\" \nPredict: " sum-stack d. .\" \n"
	repeat
	2drop
	.\" \nend read-numbers" .s .\" \n"
;
: run-all
	0 0
	begin
		init-stack .s
		line-buf buf-size @ stdin read-line ( get a line of input -- length flag error ) .s
		0 = 0 = swap 0 = 0 = +
	while
		line-buf swap ( prep read ) .s
		.\" \nReading a line; stack: " .s .\" \n"
		read-numbers
		.\" \nRead a line; stack now: " .s .\" \n"
		print-stack
		sum-stack
		.\" \nNext number is: " 2dup d. .\" \n"
		d+
		.\" \nRunning total is: " 2dup d. .\" \n"
	repeat
;
run-all
