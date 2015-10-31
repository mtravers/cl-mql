(in-package :cl-user)

(defvar *freebase-host* "https://www.googleapis.com/freebase/v1/") 

(defvar *mql-debug* nil)

(defun coerce-to-string (ss)
  (if (stringp ss)
      ss
      ;; alternatively 
      ;; (babel:octets-to-string ss :encoding :iso-8859-1)))
      (flexi-streams:octets-to-string ss)))

(defun stringify (thing)
  (etypecase thing
    (string thing)
    (symbol (string-downcase (symbol-name thing)))))

(defun mql-prop-eql (a b)
  (or (eq a b)
      (equal a b)
      (equal (mt:fast-string a) (mt:fast-string b))))

(defmacro mql-assocdr (property response)
  `(mt:assocdr
    ,property
    ,response
   :test #'mql-prop-eql))

(defun decode-json-from-string-stringily (json-string)
  (let ((json:*identifier-name-to-key* #'identity)
	(json:*json-identifier-name-to-lisp* #'identity))
    (json:decode-json-from-string json-string)
    ))

(defun query-envelope (q)
  `(("query" . (,q))))

(defun mql-read (q)
  (let* ((json (json:encode-json-to-string q))
	 (url (format nil "~A~A" *freebase-host* "mqlread"))
	 response)
    (when *mql-debug*
      (terpri)
      (princ json))
    (setq response
	  (decode-json-from-string-stringily
	   (coerce-to-string (drakma:http-request url :parameters `(("query" . ,json) )))
	   ))
    ;; +++ HTTP error checking needed
    (when *mql-debug*
      (terpri)
      (print response))
    (mql-assocdr "result" response)))
