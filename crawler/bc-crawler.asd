(defsystem "bc-crawler"
  :depends-on (#:dexador #:plump #:lquery #:lparallel #:do-urlencode
                         #:bordeaux-threads #:usocket #:bt-semaphore)
  :components ((:file "crawler-drone")
               (:file "crawler-server")))
