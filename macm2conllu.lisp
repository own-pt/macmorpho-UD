
(ql:quickload :cl-ppcre)
(ql:quickload :fare-csv)

(defun format-line (sent)
  (let ((counter 0))
    (mapcar (lambda (tk) (list (incf counter) (car tk) "_" (cadr tk) "_" "_" 0 "_" "_" "_"))
	    sent)))

(defun process-file (filename)
  (let (res)
    (with-open-file (in filename)
      (do ((line (read-line in nil nil)
		 (read-line in nil nil)))
	  ((null line)
	   (reverse res))
	(push (mapcar (lambda (tk) (cl-ppcre:split "_" tk))
		      (cl-ppcre:split "[ ]+" line))
	      res)))))

(defun main (input output)
  (with-open-file (out output :direction :output :if-exists :supersede)
    (let ((fare-csv:*separator* #\Tab)
	  (fare-csv:*allow-binary* t)
	  (fare-csv:*quote* #\|)
	  (sentences (process-file input)))
      (dolist (sent sentences)
	(fare-csv:write-csv-lines (format-line sent) out)))))

