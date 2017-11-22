;;;; Auxiliary script used to produce the confusion matrix

(ql:quickload :cl-conllu)
(in-package :cl-conllu)


(defvar *macmorpho-upostag-list*
  '("`" "=" "-" "," ";" ":" "!" "?" "/" "." "..." "'" "\"" "(" "((" ")" "))" "[" "$" "ADJ" "ADV" "ADV-KS" "ADV-KS-REL" "ART" "CUR" "IN" "KC" "KS" "N" "NIL" "NPROP" "NUM" "PCP" "PDEN" "PREP" "PROADJ" "PRO-KS" "PRO-KS-REL" "PROPESS" "PROSUB" "V" "VAUX"))

(defun fix-postags (list-of-sentences &key (switch-labels t))
  (mapc
   #'(lambda (sentence)
       (mapc
	#'(lambda (token)
	    (setf (token-upostag token)
		  (ppcre:regex-replace-all
		   "\\+.*" (token-upostag token)
		   ""))
	    (if switch-labels
		(cond
		  ((equal (token-upostag token)     
			  "CONJ")
		   (setf (token-upostag token)
			 "CCONJ"))
		  ((equal (token-upostag token)
			  "NIL")
		   (setf (token-upostag token)
			 "PROPN")))))
	(sentence-tokens sentence)))
   list-of-sentences))

(defun classify-disagreeing-words (disagreeing-pair field)
  (let ((value-1 (slot-value (first disagreeing-pair)
			    field))
	(value-2 (slot-value (second disagreeing-pair)
			     field)))
    `(,value-1 ,value-2)))


(defun classify-disagreeing-sentences (list-of-disagreements sentences field tag-list)
  "Maps from a list of list of disagreements (each list of
  disagreements corresponding to a pair of sentences) and a list of
  sentences used in the comparison (for instance, the classified ones)
  to a hash representing a function from a type of error (a pair
  (classified-value original-value)) to a pair (sentence,
  (classified-word original-word))"
  (let ((error-list-by-type (make-hash-table
			     :test #'equal
			     :size (* (length tag-list)
				      (length tag-list)))))
    ;; hash keys: pairs of tags
    ;; hash values: (sentence, (word1, word2))
    (dolist (tag1 tag-list)
      (dolist (tag2 tag-list)
	(setf (gethash `(,tag1 ,tag2)
		       error-list-by-type)
	      nil)))
    (mapcar
     #'(lambda (disagreeing-words sent)
	 (dolist (disagreeing-pair disagreeing-words)
	   (push `(,sent ,disagreeing-pair)
		 (gethash
		  (classify-disagreeing-words disagreeing-pair field)
		  error-list-by-type))))
     list-of-disagreements
     sentences)
    error-list-by-type))

(defun print-classified-sentences (error-hash &key (stream *standard-output*))
  (maphash
   #'(lambda (key value)
       (format stream "~%~a~%" key)
       (dolist (val value)
	 (destructuring-bind (sentence disagreeing-pair) val
	   (format stream "~a~%"
		   (sentence->text
		    sentence
		    :ignore-mtokens t
		    :special-format-test
		    #'(lambda (token)
			(equal (token-id token)
			       (token-id (first disagreeing-pair))))
		    :special-format-function
		    #'(lambda (string)
			(format nil "*~a*" (string-upcase string)))))
	   (format stream "~a~%" disagreeing-pair))))
   error-hash))

(defun run ()
  (let ((tagged-files (directory
		       "/home/gppassos/Documentos/nlp-general/macmorpho-UD/opennlp/run-tagger/tagged/*.tagged")))
    (dolist (tagged-file tagged-files)
      (let* ((scenario
	      ;; if complete or bosque, should be compared to bosque-test
	      ;; else, should be compared to test to its own dataset
	      ;; (keep-pcp, remove-pcp, mm-revisto)
	      (cond 
		((ppcre:scan "\(bosque\)\|\(complete\)"
			     (file-namestring tagged-file))
		 'bosque)
		((ppcre:scan "mm-revisto"
			     (file-namestring tagged-file))
		 'mm-revisto)
		((ppcre:scan "keep-pcp"
			     (file-namestring tagged-file))
		 'keep-pcp)
		((ppcre:scan "remove-pcp"
			     (file-namestring tagged-file))
		 'remove-pcp)))
	     (original
	      (case scenario
		(bosque
		 (read-conllu "/home/gppassos/Documentos/nlp-general/UD_Portuguese/pt-ud-test.conllu"))
		(mm-revisto
		 (read-conllu "/home/gppassos/Documentos/nlp-general/macmorpho-UD/macmorpho-v1-test-mm-revisto.conllu"))
		(keep-pcp
		 (fix-postags
		  (read-conllu "/home/gppassos/Documentos/nlp-general/macmorpho-UD/macmorpho-v1-test-keep-pcp.conllu")))
		(remove-pcp
		 (fix-postags
		  (read-conllu "/home/gppassos/Documentos/nlp-general/macmorpho-UD/macmorpho-v1-test-remove-pcp.conllu")))))
	     (tagged
	      (case scenario
		((bosque keep-pcp remove-pcp)	   
		 (fix-postags
		  (conllu.converters.tags:read-file-tag-suffix tagged-file)))
		(mm-revisto
		 (fix-postags
		  (conllu.converters.tags:read-file-tag-suffix tagged-file)
		  :switch-labels nil)))))
	
	(with-open-file (stream
			 (format nil "/home/gppassos/Documentos/nlp-general/macmorpho-UD/opennlp/run-tagger/confusion-matrix/~a-confusion-matrix.txt"
				 (pathname-name tagged-file))
			 :direction :output
			 :if-exists :supersede
			 :if-does-not-exist :create)
	  (let ((*upostag-value-list*
		 (cond 
		   ((ppcre:scan "keep-pcp"
				(file-namestring tagged-file))
		    (cons "PCP" *upostag-value-list*))
		   ((ppcre:scan "mm-revisto"
				(file-namestring tagged-file))
		    *macmorpho-upostag-list*)
		   (t *upostag-value-list*))))
	    (format-matrix (confusion-matrix tagged original :tag 'upostag)
			   :stream stream))
	  (format stream "~%~%~%")
	  ;; (pretty-disagreeing-sentences tagged original
	  ;; 				:head-error nil
	  ;; 				:label-error nil
	  ;; 				:upostag-error t
	  ;; 				:remove-punct nil
	  ;; 				:stream stream)
	  (print-classified-sentences
	   (classify-disagreeing-sentences 
	    (mapcar
	     #'(lambda (x y) (disagreeing-words x y
						:head-error nil
						:label-error nil
						:upostag-error t))
	     tagged original)
	    tagged
	    'upostag
	    *upostag-value-list*)
	   :stream stream))))))

;;;;
;;;; Not used anymore

;; (defun beautify-disagreeing-words (disagreeing-list sentence &key (stream *standard-output*) (skip-correct t))
;;   "Prints to STREAM sentence text along with indication of disagreeing
;;    tokens.
;;    If SKIP-CORRECT, then sentence text of correct pairs is skipped."
;;   (if (or (null skip-correct)
;; 	  disagreeing-list)
;;       (format
;;        stream
;;        "~a~%~{~a~%~}~%"
;;        (sentence->text sentence :ignore-mtokens t)
;;        disagreeing-list)))

;; (defun pretty-disagreeing-sentences (list-sent1 list-sent2 &key (head-error t) (label-error t) (upostag-error nil) (remove-punct nil) (simple-deprel nil) (stream *standard-output*))
;;   (mapcar
;;    #'(lambda (sent1 sent2)       
;;        (beautify-disagreeing-words
;; 	(disagreeing-words sent1 sent2
;; 			   :head-error head-error
;; 			   :label-error label-error
;; 			   :upostag-error upostag-error
;; 			   :remove-punct remove-punct
;; 			   :simple-deprel simple-deprel)
;; 	sent1
;; 	:stream stream))
;;    list-sent1 list-sent2))
