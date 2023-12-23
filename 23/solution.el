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

(defun valid-dirs (sym)
  (seq-filter (lambda (x) (valid-in-direction sym x)) dirs))

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
  (mapcar 'print input))

(defun solve (input)
  (let* (
	 (queue '((1 0 1)))
	 (maxes (make-maxes input))
	 )
    (a2set maxes '(1 0) 1)
    (while (> (length queue) 0)
	   ;(a2print maxes)
	   (let ((pos (car queue)))
	     (setq queue (cdr queue))
	     (setq queue (add-dirs queue pos maxes input))))
    (a2ref maxes (list (- (length maxes) 2) (- (length (aref maxes (- (length maxes) 1))) 1)))))

(defun add-dirs (queue pos maxes input)
  (let* ((sym (a2ref input pos))
	 (dir-q (valid-dirs sym))
	 (len (caddr pos))
	 )
    ;(print (list 'adding-dirs pos sym dir-q))
    (while (> (length dir-q) 0)
	   (let ((dir (car dir-q)))
	     (setq dir-q (cdr dir-q))
	     (let* ((newpos (add-position dir pos))
		    (newsym (a2ref input newpos)))
	       (if (and (valid-in-direction newsym dir)
			(in-bounds input newpos)
			(< (a2ref maxes newpos) (- len 1)))
		 (progn
		   (a2set maxes newpos (+ 1 len))
		   ;(print (list 'adding newpos))
		   (setq queue (cons newpos queue)))))))
    ;(print (list 'queue queue))
    queue))

(defvar input (parse-input (car command-line-args-left)) "Our input!")

(print (list 'part1 (solve input)))
