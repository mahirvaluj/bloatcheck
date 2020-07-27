(defpackage :bc/triage
  (:use :cl)
  (:export :triage))
;; (ql:quickload '(:cl-json :split-sequence))


(in-package :bc/triage)

(defun new-str (str &optional (start 0) end)
  (when (null end)
    (setf end (length str)))
  (let ((ret (make-string (- end start))))
    (loop for i from start to (- end 1) 
       do
         (setf (char ret (- i start)) (char str i)))
    ret))

(defun interleave (item list &optional (at-end nil))
  (let ((acc))
    (loop for i in list
       do
         (push i acc)
         (push item acc))
    (unless at-end
      (pop acc))
    (nreverse acc)))

(defun triage (pathname outpathname)
  (with-open-file (f pathname)
    (with-open-file (out outpathname :direction :output :if-exists :overwrite :if-does-not-exist :create)
      (block zzz
        (loop
           (let ((line (read-line f nil nil)))
             (when (null line)
               (return-from zzz))
             (let ((acc) (back-index 0))
               (loop for i from 0 to (search ")" line)
                  do (when (char= #\, (char line i))
                       (push (new-str line back-index i) acc)
                       (setf back-index (+ 1 i)))
                  finally (progn (push (new-str line back-index (or (search ":" line :start2 back-index :end2 i) (- i 1))) acc)))
               (format out "~A~%" (apply #'concatenate `(,'string ,@ (interleave "." acc)))))))))))
