(defpackage :bc/kv-drone
  (:use :cl)
  (:export connect)
  )
;; (ql:quickload '(:dexador :plump :lparallel :lquery :bordeaux-threads :bt-semaphore))

(in-package :bc/kv-drone)

(defvar *server*)
(defvar *server-socket*)

#|
We've got a few different kinds of messages
|#

(defun connect (ip port)
  "Open a socket to given ip and port, and present yourself to the server"
  (let ((socket (usocket:socket-connect ip port :protocol :stream :element-type 'character)))
    (setf *server-socket* socket)
    (bordeaux-threads:make-thread #'(lambda () (connection-handler socket)) :name "server-talker")))

(defun connection-handler (socket)
  (let ((stream (usocket:socket-stream socket)) url)
    (unwind-protect
         (loop
            (bt-sem:wait-on-semaphore *thread-semaphore*)
            (request-new-url stream)
            ;;(format *debug-io* "Waiting for input ~%")
            (usocket:wait-for-input socket)
            ;;(format *debug-io* "Got input~%")
            (setf url (read-line stream))
            (bt:make-thread #'(lambda  )))
      (usocket:socket-close socket))))

