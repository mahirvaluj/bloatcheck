(defsystem "bc-keyval"
  :depends-on (#:dexador #:plump #:lquery #:lparallel #:do-urlencode #:split-sequence
                         #:bordeaux-threads #:usocket #:bt-semaphore)
  :components ((:file "package")
               (:file "kv-talk")
               (:file "kv-talk-auth")
               (:file "kv-commander")
               (:file "kv-drone")
               (:file "kv-db")))
