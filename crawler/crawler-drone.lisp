(defpackage :bg/crawler-drone
  (:use :cl)
  (:export get-js-size connect)
  )
;; (ql:quickload '(:dexador :plump :lparallel :lquery))

(in-package :bg/crawler-drone)

(defvar *server*)

(setf lparallel:*kernel* (lparallel:make-kernel 8))

#|
We've got a few different kinds of messages
- Hello
- Request site to crawl
- Response with JS size

to architect this, we need a main thread which will spawn off a
thread pool to do the crawling
|#

(defun connect (ip port)
  "Open a socket to given ip and port, and present yourself to the server"
  (let ((socket (usocket:socket-connect ip port
                                        :protocol :datagram
                                        :element-type '(unsigned-byte 8))))
    (unwind-protect
         (progn
           (format t "Sending data~%")
           (usocket:socket-send socket "Hello!" 8))
      (usocket:socket-close socket))))

(defun get-js-size (url)
  (multiple-value-bind (html code #|headers uri stream|#) (dex:get url)
    (when (= code 200)
      (let ((parsed-content (lquery:$ (initialize html))) js js-src-files)
        (loop for script across (lquery:$ parsed-content "script")
           do (progn
                (push (plump:text (aref (plump:children script) 0)) js)
                (multiple-value-bind (src exists) (gethash "src" (plump:attributes script))
                  (when exists
                    (push src js-src-files)))))
        (loop for text across
             (lparallel:pmap 'vector
                             (lambda (url)
                               (ignore-errors (dex:get url)))
                             js-src-files)
           do (progn
                (push text js)))
        (let ((acc 0))
          (loop for i in (remove-if #'null js)
             do (setf acc (+ acc (length i))))
          acc)))))


