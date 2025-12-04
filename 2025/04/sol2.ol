(import (owl io))
(import (owl queue))

(define (lup input x y)
	(if (and (>= x 0) (>= y 0))
	(let ((row (rget input y #n)))
		(if (null? row)
			0
			(rget row x 0))) 0))

(define adjs (list '(-1 -1) '(0 -1) '(1 -1) '(-1 0) '(1 0) '(-1 1) '(0 1) '(1 1)))

(define (test coord input)
	(lets ((x (car coord))
				 (y (cadr coord))
				(val (lup input x y))
				(bad-adjs (filter (lambda (adj) (= 64 (lup input (+ (car adj) x) (+ (cadr adj) y)))) adjs))
				(bad-count (length bad-adjs)))
	(if (= val 64) bad-count bad-count)))

(define input (list->rlist (force-ll (lmap (lambda (x) (list->rlist (force-ll (str-iter x)))) (lines (open-input-file "input"))))))
(define idxs (list->rlist (force-ll (ltake (lnums 0) (rlen input)))))
(define coords-raw (rmap
												(lambda (y) (rmap
																			(lambda (x) (list x y))
																			idxs))
												idxs))
(define adjacents
	(rmap (lambda (row)
				 (rmap
					 (lambda (coord) (test coord input))
					 row))
				 coords-raw))  
(define coords-flat (rlist->list (rfold rappend (rlist) coords-raw)))
;(print (test (list 2 0) input))
;(rmap print (rmap rlist->list adjacents))
;(print (map (lambda (adj) (lup input (+ (car adj) 2) (+ (cadr adj) 0))) adjs))
(define coords-removable
	(filter
		(lambda (coord)
			(let
				((at (lup input (car coord) (cadr coord)))
				 (val (lup adjacents (car coord) (cadr coord))))
			
				(and (= at 64) (>= val 0) (<= val 3))
				))
		coords-flat))
(define queue (list->queue coords-removable))

(define (update-adj grid adjacents queue x y)
	(if (and (>= x 0) (>= y 0))
		(let ((row (rget adjacents y #n)))
			(if (null? row)
				(list adjacents queue)
				(let ((val (rget row x #n)))
					(if (null? val)
						(list adjacents queue)
						(let*((new-val (- val 1))
									(new-adj (rset adjacents y (rset row x new-val))))
							(list
								new-adj
							(if (and (= 3 new-val) (= 64 (lup grid x y)))
								(begin
									;(print "Before " x " " y)
									;(rmap print (rmap rlist->list adjacents))
									;(print "After")
									;(rmap print (rmap rlist->list new-adj))
									(qsnoc (list x y) queue)
									)
								queue
								)
							))
						))))
		(begin
			(list adjacents queue))
		))
	
	
(define (remove-paper grid adjacents queue coord)
	(lets ((x (car coord))
				 (y (cadr coord))
				 (row (rget grid y #n))
				 (new-grid (rset grid y (rset row x 46)))

				(new-adj new-queue (fold2 (lambda (acc-adj acc-queue adj) (begin
								(let ((v (update-adj new-grid acc-adj acc-queue (+ (car adj) x) (+ (cadr adj) y))))
								(values (car v) (cadr v)))))
							adjacents queue
							adjs)))
				(values new-grid new-adj new-queue)))


(define (eat-queue grid adjacents queue total)
	(lets ((coord rest (quncons queue #n)))
				;(print "Consuming " (+ 0 (car coord)) " " (+ 0 (cadr coord)))
				(lets ((new-grid new-adj new-queue (remove-paper grid adjacents rest coord)))
							;(print "New" new-adj new-queue)
							(values new-grid new-adj new-queue (+ 1 total))
							)
				))
(lambda (args)
	(let loop ((loop-grid input)
						 (loop-adj adjacents)
						 (loop-queue queue)
						 (loop-total 0))
		(lets ((new-grid new-adj new-queue new-total (eat-queue loop-grid loop-adj loop-queue loop-total)))
			 ;(print (qlen new-queue) " " new-total)
			 ;(print "After EATS")
			 ;(rmap print (rmap rlist->list new-adj))
			 (if (qnull? new-queue)
				 (begin
			 (rmap print (rmap (lambda (x) (map (lambda (c) (if (= 64 c) "@" ".")) (rlist->list x))) new-grid))
				 (print "DONE!" new-total))
			 (loop new-grid new-adj new-queue new-total)
				))))
