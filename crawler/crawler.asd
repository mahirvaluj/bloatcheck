(defsystem "bc/crawler"
  :depends-on (#:dexador #:plump #:lquery #:lparallel)
  :components ((:file "crawler")
               ))
