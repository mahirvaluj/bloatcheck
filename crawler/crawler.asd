(defsystem "bc/crawler"
  :depends-on (#:dexador #:plump #:lquery #:lparallel
                         #:bordeaux-threads #:usocket)
  :components ((:file "crawler-drone")
               (:file "crawler-server")))
