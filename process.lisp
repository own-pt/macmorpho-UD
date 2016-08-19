(ql:quickload :cl-tag-rewriting)
(in-package :cl-tag-rewriting)

(format t "Rodando...")
(terpri)

(defun process-macmorpho (rule-file suffix log-file)
  (let ((grammar (compile-rules (read-rules rule-file)))
	(files   '("train" "test" "dev")))
    (dolist (file files)
      (let ((in   (format nil "macmorpho-v1-~a.txt" file))
	    (out1 (format nil "macmorpho-v1-~a-~a.tmp" file suffix))
	    (out2 (format nil "macmorpho-v1-~a-~a.conllu" file suffix)))
	(process-file grammar in out1 log-file)
	(convert-conllu out1 out2)))))

(process-macmorpho "ud-remove-pcp.lisp" "remove-pcp" "ud-remove-pcp.log")
(process-macmorpho "ud-keep-pcp.lisp" "keep-pcp" "ud-keep-pcp.log")

;; (tabulate-log "out-2.log" "out-2.tab")
;; (format *standard-output* "not used in ud-keep-pcp :~% ~{~a~%~}~%"
;; 	(rules-not-used "ud-keep-pcp.lisp" "out-2.tab"))

(sb-ext:quit)
