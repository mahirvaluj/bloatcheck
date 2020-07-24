(defpackage :bg/crawler-server
  (:use :cl)
  (:export :run-server))

(in-package :bg/crawler-server)

(defvar *drones* (make-hash-table))
(defvar *server*)

(defun run-server (host port)
  "Open a listener on given port to accept drones"
  (let ((socket (usocket:socket-connect nil nil
                                        :protocol :datagram
                                        :local-host host
                                        :local-port port)))
    (setf *server* (bordeaux-threads:make-thread #'(lambda () (server-listener socket)) :name "server-thread"))))

(defun server-listener (socket)
  (unwind-protect (loop (multiple-value-bind (buffer size drone-host port) (usocket:socket-receive socket nil 200)
                          (handle-packet buffer size drone-host port)))
    (usocket:socket-close socket)))

(defun handle-packet (buf size drone-host port) 
  (format t "Got buf ~A~% of size ~A~% from drone-host ~A~% on port ~A~%" buf size drone-host port))
