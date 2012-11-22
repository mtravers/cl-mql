(in-package :asdf)

(defsystem :cl-mql
  :name "cl-mql"
  :description "Interface to Freebase"
  :version "0.1"
  :author "Mike Travers <mt@hyperphor.com>"
  :license "MIT"
  :serial t
  :depends-on (:cl-json :mtlisp :drakma)
  :components 
  ((:static-file "cl-mql.asd")
   (:module :src
	    :serial t      
	    :components
	    (;+++(:file "package")
	     (:file "cl-json-patches")
	     (:file "mql-low")
	     (:file "mql-high")
	     ))))




