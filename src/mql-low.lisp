(in-package :cl-user)

(defvar *freebase-host* "api.freebase.com") 
(defvar *freebase-readservice* "/api/service/mqlread")   ; Path to mqlread service

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

(defun mql-assocdr (property response)
  (mt:assocdr (stringify property) response :test #'equal))

(defun decode-json-from-string-stringily (json-string)
  (let ((json:*identifier-name-to-key* #'identity)
	(json:*json-identifier-name-to-lisp* #'identity))
    (json:decode-json-from-string json-string)
    ))

(defun query-envelope (q)
  `(("query" . (,q))))

(defun mql-read (q)
  (let* ((json (json:encode-json-to-string (query-envelope q)))
	 (url (format nil "https://~A~A" *freebase-host* *freebase-readservice*))
	 response)
    (when *mql-debug*
      (terpri)
      (princ json))
    (setq response
	  (decode-json-from-string-stringily
	   (coerce-to-string (drakma:http-request url :parameters `(("query" . ,json) )))
	   ))
    (unless (equal "/api/status/ok" (mql-assocdr "code" response))
      (error "MQL error ~A" response))
    (when *mql-debug*
      (terpri)
      (print response))
    (mql-assocdr "result" response)))
