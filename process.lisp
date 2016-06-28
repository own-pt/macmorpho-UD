(ql:quickload :cl-tag-rewriting)
(in-package :cl-tag-rewriting)

(format t "Rodando...")
(terpri)

(defun process-macmorpho (rule-file log-file)
  (let* ((rules   (read-rules rule-file))
	 (grammar (compile-rules rules)))
    (save-grammar-doc rules "grammar.text")
    (process-file grammar "macmorpho-v1-train.txt" "macmorpho-v1-train-UD.txt" log-file)
    (process-file grammar "macmorpho-v1-test.txt"  "macmorpho-v1-test-UD.txt" log-file)
    (process-file grammar "macmorpho-v1-dev.txt"   "macmorpho-v1-dev-UD.txt" log-file)))

(process-macmorpho "ud-remove-pcp.lisp" "out-1.log")

(convert-conllu "macmorpho-v1-train-UD.txt" "macmorpho-v1-train.conllu")
(convert-conllu "macmorpho-v1-test-UD.txt"  "macmorpho-v1-test.conllu")
(convert-conllu "macmorpho-v1-dev-UD.txt"   "macmorpho-v1-dev.conllu")

(tabulate-log "out-1.log" "out-1.tab")
(format *standard-output* "not used in ud-remove-pcp : ~% ~{~a~%~}~%"
	(rules-not-used "ud-remove-pcp.lisp" "out-1.tab"))

(process-macmorpho "ud-keep-pcp.lisp" "out-2.log")

(convert-conllu "macmorpho-v1-train-UD.txt" "macmorpho-v1-train-pcp.conllu")
(convert-conllu "macmorpho-v1-test-UD.txt"  "macmorpho-v1-test-pcp.conllu")
(convert-conllu "macmorpho-v1-dev-UD.txt"   "macmorpho-v1-dev-pcp.conllu")

(tabulate-log "out-2.log" "out-2.tab")
(format *standard-output* "not used in ud-keep-pcp :~% ~{~a~%~}~%"
	(rules-not-used "ud-keep-pcp.lisp" "out-2.tab"))

(sb-ext:quit)
