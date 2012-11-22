;;; Unknown



;;; almost the same as above
(defun mql-name-lookup-wild (name &optional type)
  (flet ((do-query (nproperty)
	   (let* ((mql (mql-read
			;; THIS LINE IS DFFERENT
			`((,(string+ (string nproperty) "~=") . ,name)
			  ,@(if type `((:type . ,type)))
			  (:id . nil)
			  ("a:name" . nil)
			  ("a:type" . :empty-list)
			  ))))
	     mql)))
    (append (do-query "name")
	    (do-query "/common/topic/alias"))))

;;; Not working


(defun mql-term (term)
  (mql-read `(("*" .  ,term))))


#|
Leftover sw related stuff
;;; RDF/Frame support


;;; Turns a Freebase ID into a frame name (ie, duplicating what they do to go to RDF)
;(def-namespace "fb" "http://rdf.freebase.com/ns/")

;;;; Bio specific
(defun mql-gene (gene-id)
  (let* ((raw (mql-read `(("/biology/gene/symbol" . ,gene-id) (:id  . nil))))
	 (id (assocdr :id (car raw)))
	 (frame (and id (mql-result->frame id))))
    (when frame
      (dereference frame)			;optional
      frame)))

(defun mql-drug-mfr (drugname)
  (assert drugname)			;nil causes problems
  (mql-name-property-lookup 
   drugname
   "/base/bioventurist/product/developed_by"
   "/medicine/drug"))

(defun mql-result->frame (id)
  (let ((f (make-frame (expand-uri (string+ "fb:" (substitute #\. #\/ (subseq id 1)))))))
    (setf (frame-source f) nil)		;+++ or have a MQL-specific source object
    f))


|#

#|
for demo:

(mapcar #'(lambda (res) 
	    (sw::mql-result->frame (cdr (assoc :id res))))
	(sw::mql-name-lookup (#^drugbank:drugbank/genericName it)))

|#

