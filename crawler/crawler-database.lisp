(defpackage :bc/crawler-peddler
  (:use :cl)
  (:export :run-peddler))

(in-package :bc/crawler-peddler)

;; This is only

(defvar *pedler-socket*)

(defun run-peddler (host port)
  "Open a listener on given port to accept drones"
  (let ((socket (usocket:socket-listen host port
                                       :element-type 'character)))
    (setf *pedler-socket* socket)
    (setf *pedler-thread* (bt:make-thread #'(lambda () (server-listener socket)) :name "server-thread"))))

(defun peddler-listener (socket)
  "Listen on port for all incoming drone server connections, and then spawn off a thread to deal with the server"
  (unwind-protect
       (loop
          (let ((accepted-socket (usocket:socket-accept socket)))
            (push (bt:make-thread
                   #'(lambda () (dserver-manage accepted-socket))
                   :name (format nil "dserver-thread-~A" (incf *drone-count*)))
                  *drone-threads*)))
    (usocket:socket-close socket)))

(defun deserver-manage (socket)
  (format *debug-io* "Got connection~%")
  (let ((stream (usocket:socket-stream socket)))
    (loop
       (usocket:wait-for-input socket)
       (let ((text (read-line stream)))
         (format *debug-io* "command is: ~A~%" text)
         (cond ((string= text "give" :end1 4 :end2 4)
                (progn (format (usocket:socket-stream socket) "~A~%" (get-size text))
                       (force-output (usocket:socket-stream socket)))
                )
               (t
                (format *debug-io* "Unknown packet received")))))))

(defun get-size (text)
  ())
