(defpackage :bg/crawler
  (:use :cl :dexador :plump :lquery :lparallel)
  (:export crawl-page)
  )
;; (ql:quickload '(:dexador :plump :lparallel :lquery))

(in-package :bg/crawler)

(setf lparallel:*kernel* (lparallel:make-kernel 8))

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


