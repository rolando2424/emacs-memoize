;; -*-lexical-binding: t; -*-
;;; memoize.el --- memoize elisp functions

;; Written by Christopher Wellons <mosquitopsu@gmail.com>
;; This program is public domain.

;;; Commentary:

;; Memoizing an interactive function will render that function
;; non-interactive. It would be easy to fix this problem when it comes
;; to non-byte-compiled functions, but recovering the interactive
;; definition from a byte-compiled function is more complex than I
;; care to deal with. Besides, interactive functions are always used
;; for their side effects anyway.

;; There's no way to memoize nil returns, but why would your expensive
;; functions do all that work just to return nil? :-)

;; If you wait to byte-compile the function until *after* it is
;; memoized then the function and memoization wrapper both get
;; compiled at once, so there's no special reason to do them
;; separately. But there really isn't much advantage to compiling the
;; memoization wrapper anyway.

;;; Code:

(defun memoize (func)
  "Memoize the given function. If argument is a symbol then
install the memoized function over the original function."
  (typecase func
    (symbol
     (put func 'function-documentation
          (concat (documentation func) " (memoized)"))
     (fset func (memoize-wrap (symbol-function func)))
     func)
    (function (memoize-wrap func))))

;; ID: 83bae208-da65-3e26-2ecb-4941fb310848
(defun memoize-wrap (func)
  "Return the memoized version of FUNC."
  (let ((table (make-hash-table :test 'equal)))
    (lambda (&rest args)
      (let ((value (gethash args table)))
        (if value
            value
          (puthash args (apply func args) table))))))

(provide 'memoize)

;;; memoize.el ends here