(defsystem "bc-crawler"
  :depends-on (#:dexador #:plump #:lquery #:lparallel #:do-urlencode
                         #:bordeaux-threads #:usocket)
  :components ((:file "crawler-drone")
               (:file "crawler-server")))
