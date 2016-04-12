(ql:quickload :cl-pcp)
(in-package :string-rewriting)

(format t "Rodando...")
(terpri)

(defun process-macmorpho (rule-file)
  (let* ((rules   (read-rules rule-file))
	 (grammar (compile-rules rules)))
    (save-grammar-doc rules "grammar.text")
    (process-file grammar "macmorpho-v1-train.txt" "macmorpho-v1-train-UD.txt")
    (process-file grammar "macmorpho-v1-test.txt"  "macmorpho-v1-test-UD.txt")
    (process-file grammar "macmorpho-v1-dev.txt"   "macmorpho-v1-dev-UD.txt")))

(process-macmorpho "ud-remove-pcp.lisp")

(convert-conllu "macmorpho-v1-train-UD.txt" "macmorpho-v1-train-UD.conllu")
(convert-conllu "macmorpho-v1-test-UD.txt"  "macmorpho-v1-test-UD.conllu")
(convert-conllu "macmorpho-v1-dev-UD.txt"   "macmorpho-v1-dev-UD.conllu")

(sb-ext:quit)
