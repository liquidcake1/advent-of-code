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

(defun make-fill (input val)
  (eval (cons 'vector (mapcar (lambda (x) (eval (cons 'vector (mapcar (lambda (y) val) x)))) input))))

(defvar ascii-hash (aref "#" 0) "the ASCII code of the # symbol")

(defvar ascii-dot (aref "." 0) "the ASCII code of the . symbol")

(defvar ascii-lt (aref "<" 0) "the ASCII code of the > symbol")

(defvar ascii-gt (aref ">" 0) "the ASCII code of the < symbol")

(defvar ascii-caret (aref "^" 0) "the ASCII code of the ^ symbol")

(defvar ascii-v (aref "v" 0) "the ASCII code of the letter v")

;(defvar dirs '((1 0) (0 1) (-1 0) (0 -1)))
(defvar dirs '((-1 0) (0 -1) (1 0) (0 1)))

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
  (list (+ (car pos) (car dir)) (+ (cadr pos) (cadr dir))))

(defun a2ref (input pos)
  (if (in-bounds input pos)
    (aref (aref input (cadr pos)) (car pos))))

(defun a2set (input pos val)
  (aset (aref input (cadr pos)) (car pos) val))

(defun a2print (input)
  (mapcar (lambda (x) (always-print (format "%s" (mapcar (lambda (c) (if (> c -1) (format "%4d" c) "    ")) x)))) input))

(defun always-print (input)(print input))
(defun always-a2print (input)(a2print input))

(defun get-dirs (queue pos input in-dir validity)
  (let* ((sym (a2ref input pos))
	 (dir-q (valid-dirs sym validity))
	 (rev-in-dir (reverse-dir in-dir))
	 (out-list nil)
	 )
    ;(print (list 'adding-dirs pos sym dir-q))
    (while (> (length dir-q) 0)
	   (let ((dir (car dir-q)))
	     (setq dir-q (cdr dir-q))
	     (let* ((newpos (add-position dir pos))
		    (newsym (a2ref input newpos)))
	       (if (and (funcall validity newsym dir)
			(in-bounds input newpos)
			(not (equal dir rev-in-dir)))
		 (progn
		   (setq out-list (cons (list newpos dir) out-list)))))))
    ;(print (list 'queue queue))
    out-list))

(defun rewind-route (maxes route len)
  ;(print (list 'rewind-route route len))
  (while (and (not (eq route nil))
	      (>= (cadar route) len))
	 (a2set maxes (caar route) -2)
	 ;(print (caddar route))
	 (setq route (cdr route)))
  (if (< (length route) 500) (progn
			       ;DEBUG-DISABLE (print (list 'rewind len (length route)))
			       ))
  route)

(defun valid-any-direction (sym dir)
  (cond ((equal sym ascii-hash) nil)
	((eq sym nil) nil)
	(t t)))

(defun edge-reversal (pos-dir)
  ;DEBUG-DISABLE (print (list 'edge-reversal pos-dir (caar pos-dir) maze-rt (cadadr pos-dir)))
  (not (or
	 (and (eq -1 (cadadr pos-dir)) (or
					 (eq maze-lt (caar pos-dir))
					 (eq maze-rt (caar pos-dir))))
	 (and (eq -1 (caadr pos-dir)) (or
					(eq maze-tp (cadar pos-dir))
					(eq maze-bt (cadar pos-dir))))
	 )))

(defun solve-part-2 (input validity)
  (setq maze-lt 1)
  (setq maze-rt (- (length (aref input 0)) 2))
  (setq maze-tp 1)
  (setq maze-bt (- (length input) 2))
  (let* (
	 (queue '(((1 0) 0 (0 1)))) ; pos len in-dir
	 (maxes (make-fill input -2))
	 (corridors (make-fill input nil)) ; (in-dir len end out-dir) - if corridors[pos] = (in-dir) then add len, set pos=end and in-dir=out-dir
	 (route ()) ; pos len
	 (best 0)
	 (prev-head nil)
	 (corridor-start nil) ; (pos len in-dir)
	 )
    ;(a2set maxes '(1 0) 0)
    (while (> (length queue) 0)
	   (let* ((head (car queue))
		  (pos (car head))
		  (len (cadr head))
		  (in-dir (caddr head))
		  (corridor-cache (a2ref corridors pos)))
	     ;DEBUG-DISABLE (print (list 'dequeue head))
	     ; If we just started on a corridor, just warp to the end!
	     (setq route (rewind-route maxes route len))
	     (if corridor-cache
	       (if (not (equal (car corridor-cache) in-dir))
		 (if (edge-reversal (list pos (car corridor-cache))) (progn
								       ;DEBUG-DISABLE (print (list "Hit a reversed corridor endpoint while navigating a corridor. This may happen on Part 1." 'start corridor-start 'cache corridor-cache 'extra (list pos (car corridor-cache)) (edge-reversal (list pos (car corridor-cache)))))
								       ))
		 (progn
		   (if (not (eq nil corridor-start))
		     (progn
		       ;DEBUG-DISABLE (print (list "ARGHHHHHHHH joined a corridor while in a corridor! This ought to be impossible!" 'start corridor-start 'cache corridor-cache))
		       ;DEBUG-DISABLE (a2print maxes))
		       (progn
			 ;DEBUG-DISABLE (print (list 'warp-corridor head 'to corridor-cache))
			 (setq len (+ (cadr corridor-cache) len))
			 (setq pos (caddr corridor-cache))
			 (setq in-dir (cadddr corridor-cache))
			 ;DEBUG-DISABLE (print (list 'warp-to (list pos len in-dir)))
			 ))))))
	     (setq route (cons (list pos len) route))
	     (a2set maxes pos len)
	     ;DEBUG-DISABLE (a2print maxes)
	     ;(print route)
	     (if (equal (cadr pos) (- (length input) 1))
	       (if (> len best)
		 (progn
		   (setq best len)
		   (always-print (list 'BEST best)))))
	     (setq queue (cdr queue))
	     ; TODO disallow if in-dir*2+pos+out-dir < val[in-dir
	     (let* ((new-pos-dirs- (get-dirs queue pos input in-dir validity))
		    ; Filter any weird edges.
		    ; TODO if there's a self-intersect 2 ahead, this logic can also filter valid-dirs
		    (new-pos-dirs (seq-filter 'edge-reversal new-pos-dirs-))
		    ; Filter any self-intersects.
		    (valid-dirs- (seq-filter (lambda (pos-dir) (< (a2ref maxes (car pos-dir)) 0)) new-pos-dirs))
		    (valid-dir (seq-filter (lambda (pos-dir) ((< (a2ref maxes (add-position (cadr pos-dir) (car pos-dir))) 0) (
		    (new-queue-entries (mapcar (lambda (pos-dir) (list (car pos-dir) (+ 1 len) (cadr pos-dir))) valid-dirs)))
	       ;DEBUG-DISABLE (print (list 'new-pos-dirs new-pos-dirs 'valid-dirs valid-dirs 'new-queue-entries new-queue-entries))
	       (setq queue (append new-queue-entries queue))
	       (cond
		 ((or (eq nil valid-dirs) (not (eq 1 (length new-pos-dirs))))
		  ; is not corridor, or is dead end (either because we looped into ourselves or hit a real dead-end)
		  (if (not (eq corridor-start nil))
		    ; ... and we are on one, so mark the end of the corridor, and end it
		    (let* ((end-pos (car prev-head))
			   (end-out-dir in-dir)
			   (corridor-entry (car corridor-start))
			   (corridor-len (- (cadr prev-head) (cadr corridor-start)))
			   (corridor-in-dir (caddr corridor-start)))
		      ;DEBUG-DISABLE (print (list 'end-corridor corridor-start end-pos end-out-dir corridor-len))
		      ;DEBUG-DISABLE (print (list 'a2set 'corridors corridor-entry (list corridor-in-dir corridor-len end-pos end-out-dir)))
		      (a2set corridors corridor-entry
			     (list
			       corridor-in-dir
			       corridor-len
			       end-pos
			       end-out-dir))
		      ; Set the reverse, too!
		      ;DEBUG-DISABLE (print (list 'a2set 'corridors end-pos (list (reverse-dir end-out-dir) corridor-len corridor-entry (reverse-dir corridor-in-dir))))
		      (a2set corridors end-pos
			     (list
			       (reverse-dir end-out-dir)
			       corridor-len
			       corridor-entry
			       (reverse-dir corridor-in-dir)))
		      (setq corridor-start nil))))
		 ((eq 1 (length new-pos-dirs))
		  ; is corridor
		  (if (eq corridor-start nil)
		    ; ... and we weren't on one, so mark the start
		    (progn
		      ;DEBUG-DISABLE (print (list 'start-corridor head))
		      (setq corridor-start head))))))
	     (setq prev-head head)))
    (setq route (rewind-route maxes route 0))
    (always-a2print maxes)
    (always-print "end")
    best))

(defvar input (parse-input (car command-line-args-left)) "Our input!")

;(print (list 'part1 (solve-part-2 input 'valid-in-direction)))
(print (list 'part2 (solve-part-2 input 'valid-any-direction)))
