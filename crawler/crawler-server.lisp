(defpackage :bc/crawler-server
  (:use :cl)
  (:export :run-server))

(in-package :bc/crawler-server)

(defvar *drone-threads* nil)
(defparameter *drone-count* 0)
(defvar *server-socket*)
(defvar *server-thread*)
(defvar *files-with-domains* '("out"))
(defvar *concat-filestream* nil)
(defvar *logging-stream*)

(defun run-server (host port)
  "Open a listener on given port to accept drones"
  (let ((socket (usocket:socket-listen host port
                                       :element-type 'character)))
    (setf *server-socket* socket)
    (setf *server-thread* (bt:make-thread #'(lambda () (server-listener socket)) :name "server-thread"))))

(defun server-listener (socket)
  "Listen on port for all incoming drone connections, and then spawn off a thread to deal with the drone"
  (unwind-protect
       (loop
          (let ((accepted-socket (usocket:socket-accept socket)))
            (push (bt:make-thread
                   #'(lambda () (drone-manage accepted-socket))
                   :name (format nil "drone-thread-~A" (incf *drone-count*)))
                  *drone-threads*)))
    (usocket:socket-close socket)))

(defun drone-manage (socket)
  (format *debug-io* "Got connection~%")
  (let ((stream (usocket:socket-stream socket)))
    (loop
       (usocket:wait-for-input socket)
       (let ((text (read-line stream)))
         (format *debug-io* "command is: ~A~%" text)
         (cond ((string= text "requ" :end1 4 :end2 4)
                (progn (format (usocket:socket-stream socket) "~A~%" (get-new-url))
                       (force-output (usocket:socket-stream socket)))
                )
               ((string= text "size" :end1 4 :end2 4)
                (register-pagesize text)
                )
               (t
                (format *debug-io* "Unknown packet received")))))))

(defun regen-stream-of-domains ()
  (when *concat-filestream*
    (close *concat-filestream*))
  (setf *concat-filestream*
        (apply #'make-concatenated-stream
               (map 'list (lambda (x)
                            (open x :if-does-not-exist :error))
                   *files-with-domains*))))

(defun register-pagesize (packet)
  (multiple-value-bind (enc-url len-url) (read-from-string packet nil nil :start 4)
    (let ((url-js-size (read-from-string packet nil nil :start len-url)))
      (format *debug-io* "~S~%" `(,enc-url ,url-js-size)))))

(defun get-new-url ()
  (when (null *concat-filestream*)
    (regen-stream-of-domains))
  (do-urlencode:urlencode (format nil "http://~A/" (read-line *concat-filestream*))))

(defun close-all-drone-connections ()
  (mapc (lambda (drone-thread) (bt:destroy-thread drone-thread)) *drone-threads*)
  (setf *drone-threads* nil)
  (setf *drone-count* 0))

(defun handle-packet (buf size drone-host port) 
  (format t "Got buf ~A~% of size ~A~% from drone-host ~A~% on port ~A~%" buf size drone-host port))
