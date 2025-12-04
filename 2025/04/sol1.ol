(import (owl io))
(define (lup input x y)
	(if (and
				(>= y 0)
				(< y (vector-length input))
				(>= x 0)
				(< x (vector-length input)))
	(vector-ref (vector-ref input y) x)
	0
	))
(define adjs (list '(-1 -1) '(0 -1) '(1 -1) '(-1 0) '(1 0) '(-1 1) '(0 1) '(1 1)))
(define (test coord input)
	(lets ((x (car coord))
				(y (cadr coord))
				(bad-adjs (filter (lambda (adj) (= 64 (lup input (+ (car adj) x) (+ (cadr adj) y)))) adjs))
				(bad-count (length bad-adjs)))
	(and (= (lup input x y) 64) (<= bad-count 3))))

(lambda (args)
	 (lets
		 (
			(input (list->vector (force-ll (lmap (lambda (x) (list->vector (force-ll (str-iter x)))) (lines (open-input-file (cadr args)))))))
			(idxs (force-ll (ltake (lnums 0) (vector-length input))))
			(coords-raw (map
															(lambda (x) (map
																						(lambda (y) (list x y))
																						idxs))
															idxs))
			(coords (fold append '() coords-raw))
			(coords-paper (filter (lambda (coord) (= (lup input (car coord) (cadr coord)) 64)) coords))
			)
				 (print 'foo)
				 (print (filter (lambda (coord) (test coord input)) coords-paper))
				 (print 'foo)
	 )
				0)
