(defun my-file-contents (filename)
  "Return the contents of FILENAME."
  (with-temp-buffer
    (insert-file-contents filename)
    (buffer-string)))

(defun zip (xs ys)
  (cond
    ((or (null xs) (null ys)) ())
    (t (cons (list (car xs) (car ys)) (zip (cdr xs) (cdr ys))))))

(defun enumerate (xs)
  (zip xs (number-sequence 0 (length xs))))

(enumerate '(a b c))

(defun parse-input (filename)
  (enumerate (reverse (cdr (reverse (mapcar (lambda (x)
					      (mapcar (lambda (y)
							(mapcar 'string-to-number (split-string y ",")))
						      (split-string x "~")))
					    (split-string (my-file-contents filename) "\n")))))))

(setq parsed-input (parse-input "inputtest.txt"))

(defun sort-input (parsed-input) (seq-sort-by
				   (lambda (x) (min (car (cddaar x)) (cadr (cdadar x))))
				   #'<
				   parsed-input
				   ))

(defun add-nil-heights (heights)
  (mapcar (lambda (x) (mapcar (lambda (y) (list y ())) x)) heights))


(defun base () (make-list 10 (make-list 10 '(0 ()))))

(sort-input parsed-input)

(defun block-footprint (block)
  (if (eq (caar block) (caadr block))
    (if (eq (cadar block) (cadadr block))
      (list (list (caar block) (cadar block)))
      (mapcar (lambda (y) (list (caar block) y)) (number-sequence (cadar block) (cadadr block))))
    (mapcar (lambda (y) (list y (cadar block))) (number-sequence (caar block) (caadr block)))))y

(block-footprint '((1 0 2) (1 1 2)))

(defun drop-coord-by (z coord)
  (print (list 'drop-coord-by z coord))
  (list (car coord) (cadr coord) (- (caddr coord) z)))

(drop-coord-by 2 '(1 2 3))

(defun get-height-n (heights coord)
  ;(print (list 'get-height-n heights coord))
  (elt (elt heights (cadr coord)) (car coord))))

(defun get-height (heights coord) (car (get-height-n heights coord)))

(get-height-n '(((0 ()) (1 ())) ((0 ()) (0 ()))) '(1 0))

(+ 1 (seq-max
       (mapcar (lambda (x) (get-height '(((0 ()) (1 ())) ((0 ()) (0 ()))) x)) (block-footprint '((1 0 2) (1 1 3))))
       ))

(defun compare-bests (old-best new)
  (print (list 'compare-bests old-best new))
  (let* (
	 (old-best-n (car old-best))
	 (new-n (car new))
	 (_ (print (list 'debug new-n old-best-n (> new-n old-best-n) (eq new-n old-best-n))))
	 (res (if (> new-n old-best-n)
		(list new-n (list (cadr new)))
		(if (eq new-n old-best-n)
		  (list old-best-n (cons (cadr new) (remq (cadr new) (cadr old-best))))
		  old-best
		  )))
	 (_ (print (list 'compare-bests 'out res)))
	 )
    res))

(compare-bests '(0 (foo)) '(0 bar))
(compare-bests '(2 ((n 1))) '(2 (n 2)))

(defun get-support (heights footprint)
  ;(print (list 'get-support heights footprint))
  (let* (
	 (bests (seq-reduce (lambda (old-best x) (compare-bests old-best (get-height-n heights x))) footprint '(0 ())))
	 (_ (print (list 'get-support 'out bests)))
	 (res (if (= (length (cadr bests)) 1) (list (car bests) (caadr bests)) (list (car bests) ())))
	 )
    res))

(add-nil-heights '((0 0) (0 0)))
(enumerate '(((1 0 1) (1 1 1))))
(get-support (add-nil-heights '((0 0) (0 0))) '((1 0) (1 1)))

(defun drop-block (heights block)
  ;(print (list 'drop-block heights block))
  (let* (
	 (footprint (block-footprint block))
	 ;(_ (print footprint))
	 (target-height-name (get-support heights footprint))
	 (target-height (+ 1 (car target-height-name)))
	 ;(_ (print target-height-name))
	 (actual-height (caddar block))
	 ;(_ (print actual-height))
	 (drop-needed (- actual-height target-height))
	 (res (list (mapcar (lambda (x) (drop-coord-by drop-needed x)) block) (cadr target-height-name)))
	 ;(_ (print (list 'drop-block-is res)))
	 )
    res)
  )

(drop-block '(((0 ()) (0 ())) ((3 ()) (0 ()))) '((0 1 3) (1 1 3)))

(drop-block (add-nil-heights '((0 0) (3 0))) '((0 1 3) (1 1 3)))
(caddar '((1 1 2) (1 1 3)))

(defun set-nth (list n val)
  (if (> n 0)
    (cons (car list)
	  (set-nth (cdr list) (1- n) val))
    (cons val (cdr list))))

(defun set-height-n (heights coord val)
  ;(print (list 'set-height-n heights coord val))
  (set-nth heights (cadr coord) (set-nth (elt heights (cadr coord)) (car coord) val)))

(set-height '((0 0) (0 0)) '(1 1) 2)

(defun apply-block (heights block-and-name)
  (print block-and-name)
  (let* (
	 (block (car block-and-name))
	 ;(_ (print (list 'block block)))
	 (name (cadr block-and-name))
	 (footprint (block-footprint block))
	 ;(_ (print (list 'footprint footprint)))
	 (actual-height (car (cddadr block)))
	 ;(_ (print (list 'actual-height actual-height)))
	 (res (seq-reduce (lambda (in-heights coord) (set-height-n in-heights coord (list actual-height (list 'n name)))) footprint heights))
	 ;(_ (print (list 'res res)))
	 )
    res))

(defun stack (heights input acc sacc)
  (print heights)
  (if (eq input ())
    (list (reverse acc) sacc)
    (let* (
	   (block (car input))
	   (_ (print (list 'block 'in 'stack block)))
	   (dropped-and-support (drop-block heights (car block)))
	   (dropped (car dropped-and-support))
	   (support (cadr dropped-and-support))
	   (_ (print (list "dropped" dropped support)))
	   (raised (apply-block heights (list dropped (cadr block))))
	   )
      (stack raised (cdr input) (cons (list dropped (cadr block)) acc) (cons support (remq support sacc))))))

(add-nil-heights '((0 2) (0 1) (0 3)))
(enumerate '(((1 0 1) (1 2 1))))
(stack (add-nil-heights '((0 2) (0 1) (0 3))) (enumerate '(((1 0 1) (1 2 1)))) '() '())

(defun solve (filename)
  (stack (base) (sort-input (parse-input filename)) () ())
  )


(solve "inputtest.txt")
(sort-input (parse-input "inputtest.txt"))

(base)



(car '(1 2))

(cdr (cdadr '((1 2 3) (4 5 6))))
(cddar '((1 2 3) (4 5 6)))	     

(min 1 2 0)


