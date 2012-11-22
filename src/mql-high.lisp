(in-package :cl-user)

(defun name-types (name)
  (mql-name-property-lookup name :type nil))

;;; Generalized
;;; this doesn't work, because you need to provide a type or you get errors
;;; Solution: do one query to get all the types, then do the query for each type, with an error handler.  Yuck!
;;; MQL has no OR operator, so this takes 2 separate queries
(defun mql-name-property-lookup (name property &optional type)
  (flet ((do-query (nproperty)
	   (let* ((mql (mql-read
			`((,nproperty . ,name)
			  ,@(if type `((:type . ,type)))
			  ("a:type" . :empty-list)
			  (,property  . :empty-list))))
		  ;; Aigh, bad car
		  (dev (mt:mapunion #'(lambda (result)
				     (mql-assocdr property result))
				 mql
				 :test #'equal))
		  )
	     dev)))
    (or (do-query "name")
	(do-query "/common/topic/alias"))))

;;; eg: (type-properties "/music/recording")
;;; this should be memoized.
(defun type-properties (type)
  (mql-read `((:id . ,type)
	      ("properties" . :empty-list)
	      (:type . "/type/type"))))

(defun mql-name-lookup (name &optional type)
  (flet ((do-query (nproperty)
	   (let* ((mql (mql-read
			`((,nproperty . ,name)
			  ,@(if type `((:type . ,type)))
			  (:id . nil)
			  ("a:name" . nil)
			  ("a:type" . :empty-list)
			  ))))
	     mql)))
    (append (do-query "name")
	    (do-query "/common/topic/alias"))))

;;; Given a GUID, return everything we can find
;;; I think this is isomorphic to what you get from dereferencing the RDF?
(defun id->everything (id)
  (let ((types
	 (mql-assocdr 
	  :type 
	  (car (mql-read `((:id . ,id)
			   (:type . :empty-list))))))
	(result nil))
    (dolist (type types)
      (setf result 
	    (append result
		    (mt:report-and-ignore-errors 	;+++ some types give errors, just ignore
		      (mql-read `((:id . ,id)
				  (:type . ,type)
				  ("*" . :empty-dict))))))) ; or ("*" . nil) to get values only
    result))


(defun links (id)
  (mql-read `((:type . "/type/link")
	      (:source . ((:id . ,id)))
	      (:master_property . nil)
	      (:target . :empty-dict)
	      (:target_value . nil))))


