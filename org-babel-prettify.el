;;; org-babel-prettify.el --- Prettify display of org-babel src blocks
;; Copyright (C) 2019 Ferdinand Pieper
;;
;; Author: Ferdinand Pieper <fer at pie dot tf>
;;
;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;; This module prettifies the display of org-babel source blocks.
;; Notably it hides the src_lang{code} part for inline source blocks
;; after execution. The code block can be still be interacted with by
;; placing the cursor in front of the result block, on the first {.
;;
;;; Code:

(defvar org-babel-prettify-mode nil)

(defvar org-babel-prettify--keywords '(("\\(src_[^{
 ]*{.*?}[
 ]{{{results(\\)\\(.*?\\))}}}" (1 (org-babel-prettify--compose-symbol))))
  "Keyword list that is added to `font-lock-keywords` when
  entering org-babel-prettify-mode.")

(defun org-babel-prettify--compose-symbol ()
  (let* ((pre_start (match-beginning 1))
	 (pre_end   (match-end 1))
	 (post_start (match-end 2))
	 (post_end   (match-end 0)))
    (put-text-property pre_start pre_end 'display "{{{" nil)
    (put-text-property post_start post_end 'display "}}}" nil)
    'org-macro
  ))

(define-minor-mode org-babel-prettify-mode
  "Mode to prettify org-babel src blocks.

Hides the code part of inline source blocks.

While enabled it the hidden source code can be interacted with
  when the cursor is just at the beginning of the result block."
  nil nil nil
  (if org-babel-prettify-mode
      (progn
	(font-lock-add-keywords nil org-babel-prettify-keywords)
	(setq-local font-lock-extra-managed-props
		    (append font-lock-extra-managed-props
			    '(display)))
	(font-lock-flush))
    (progn
      (font-lock-remove-keywords nil org-babel-prettify-keywords)
      (font-lock-flush)
      (when (memq 'display font-lock-extra-managed-props)
	(setq font-lock-extra-managed-props (delq 'display
						  font-lock-extra-managed-props))
	(with-silent-modifications
	  (remove-text-properties (point-min) (point-max) '(display nil)))
	))))

(provide 'org-babel-prettify)

;;; org-babel-prettify.el ends here
