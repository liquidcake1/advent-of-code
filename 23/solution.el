;;; -*- lexical-binding: t -*-
(setq lexical-binding t)
(defun my-file-contents (filename)
  "Return the contents of FILENAME."
  (with-temp-buffer
    (insert-file-contents filename)
    (buffer-string)))

(defun parse-input (filename)
  "Load FILENAME as a vector of strings"
  (eval (cons 'vector (reverse (cdr (reverse (split-string (my-file-contents filename) "\n")))))))

(defun make-maxes (input)
  (eval (cons 'vector (mapcar (lambda (x) (eval (cons 'vector (mapcar (lambda (y) -1) x)))) input))))

(defvar ascii-hash (aref "#" 0) "the ASCII code of the # symbol")

(defvar ascii-dot (aref "." 0) "the ASCII code of the . symbol")

(defvar ascii-lt (aref "<" 0) "the ASCII code of the > symbol")

(defvar ascii-gt (aref ">" 0) "the ASCII code of the < symbol")

(defvar ascii-caret (aref "^" 0) "the ASCII code of the ^ symbol")

(defvar ascii-v (aref "v" 0) "the ASCII code of the letter v")

(defvar dirs '((1 0) (0 1) (-1 0) (0 -1)))

(defun dir-of (sym)
  (cond ((equal sym ascii-lt) '(-1 0))
	((equal sym ascii-gt) '(1 0))
	((equal sym ascii-v) '(0 1))
	((equal sym ascii-caret) '(0 -1))))

(defun reverse-dir (dir)
  (list (- (car dir)) (- (cadr dir))))

(defun valid-in-direction (sym dir)
  (cond ((equal sym ascii-hash) nil)
	((equal sym ascii-dot) t)
	((eq sym nil) nil)
	((equal dir (reverse-dir (dir-of sym))) nil)
	(t t)))

(defun valid-dirs (sym validity)
  (seq-filter (lambda (x) (funcall validity sym x)) dirs))

(defun in-bounds (input pos)
  (and (> (car pos) -1)
       (> (cadr pos) -1)
       (< (car pos) (length input))
       (< (cadr pos) (length (aref input 0)))))

(defun add-position (dir pos)
  (list (+ (car pos) (car dir)) (+ (cadr pos) (cadr dir)) (+ 1 (caddr pos))))

(defun a2ref (input pos)
  (if (in-bounds input pos)
    (aref (aref input (cadr pos)) (car pos))))

(defun a2set (input pos val)
  (aset (aref input (cadr pos)) (car pos) val))

(defun a2print (input)
  (mapcar (lambda (x) (print (format "%s" (mapcar (lambda (c) (if (> c -1) (format "%3d" c) "   ")) x)))) input))

(defun solve-part-1 (input)
  (let* (
	 (queue '((1 0 1)))
	 (maxes (make-maxes input))
	 )
    (a2set maxes '(1 0) 1)
    (while (> (length queue) 0)
	   ;(a2print maxes)
	   (let ((pos (car queue)))
	     (a2set maxes pos (caddr pos))
	     (setq queue (cdr queue))
	     (setq queue (add-dirs queue pos maxes input 'valid-in-direction))))
    (a2ref maxes (list (- (length maxes) 2) (- (length (aref maxes (- (length maxes) 1))) 1)))))

(defun add-dirs (queue pos maxes input validity)
  (let* ((sym (a2ref input pos))
	 (dir-q (valid-dirs sym validity))
	 (len (caddr pos))
	 )
    ;(print (list 'adding-dirs pos sym dir-q))
    (while (> (length dir-q) 0)
	   (let ((dir (car dir-q)))
	     (setq dir-q (cdr dir-q))
	     (let* ((newpos (add-position dir pos))
		    (newsym (a2ref input newpos)))
	       (if (and (funcall validity newsym dir)
			(in-bounds input newpos)
			(eq (a2ref maxes newpos) -1))
		 (progn
		   ;(print (list 'adding newpos))
		   (setq queue (cons newpos queue)))))))
    ;(print (list 'queue queue))
    queue))

(defun rewind-route (maxes route len)
  ;(print len)
  (while (and (not (eq route nil))
	      (>= (caddar route) len))
	 (a2set maxes (car route) -1)
	 ;(print (caddar route))
	 (setq route (cdr route)))
  (if (< (length route) 500)
    (print (list 'rewind (length route))))
  route)

(defun valid-any-direction (sym dir)
  (cond ((equal sym ascii-hash) nil)
	((eq sym nil) nil)
	(t t)))

(defun solve-part-2 (input validity)
  (let* (
	 (queue '((1 0 1)))
	 (maxes (make-maxes input))
	 (route ())
	 (best 0)
	 )
    (a2set maxes '(1 0) 1)
    (while (> (length queue) 0)
	   (let ((pos (car queue)))
	     (a2set maxes pos (caddr pos))
	     ;(a2print maxes)
	     (setq route (cons pos (rewind-route maxes route (caddr pos))))
	     ;(print route)
	     (if (equal (cadr pos) (- (length input) 1))
	       (if (> (caddr pos) best)
		 (progn
		   (setq best (caddr pos))
		   (print (list 'BEST best)))))
	     (setq queue (cdr queue))
	     (setq queue (add-dirs queue pos maxes input validity))))
    best))

(defvar input (parse-input (car command-line-args-left)) "Our input!")

(print (list 'part1 (solve-part-2 input 'valid-in-direction)))
(print (list 'part2 (solve-part-2 input 'valid-any-direction)))
