;;; howdoi.el --- HowDoI backend for emacs

;; Copyright (C) 2017  Gaby Launay

;; Author: Gaby Launay <gaby.launay@tutanota.com>
;; URL: https://github.com/galaunay/howdoi
;; Version: 1.0
;; Keywords: howdoi

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Howdoi is a backend for the howdoi command: https://github.com/gleitz/howdoi

;;; Code:

(require 'ansi-color)

(defconst howdoi-version "1.0"
  "The version of the Howdoi Lisp code.")


;;;;;;;;;;;;;;;;;;;;;;
;;; User customization

(defcustom howdoi-command "howdoi"
  "Command use to invoke howdoi."
  :type 'string
  :group 'howdoi)

(defcustom howdoi-use-colors t
  "If howdoi should display syntaxic coloration."
  :type 'boolean
  :group 'howdoi)


;;;;;;;;;;;;;
;;; Variables

(defvar howdoi-answer-number 1
  "Number of results displayed by howdoi.")

(defvar howdoi-last-query ""
  "Last query send to howdoi.")

(defvar howdoi-full-answer nil
  "If 't', display the full answer.")

(defvar howdoi-buffer-name "*How do i*"
  "Name of the howdoi buffer.")


;;;;;;;;;
;;; Faces

(defface howdoi-answer-number-face
  '((t :inherit font-lock-variable-name-face :bold t :underline t))
  "Face for the answer number indicator."
  :group 'howdoi)

(defface howdoi-query-face
  '((t :inherit font-lock-comment-face))
  "Face for the query reminder."
  :group 'howdoi)


;;;;;;;;;;;;;;;;;;;;;;
;;; Internal functions

(defun howdoi--check-howdoi-is-present ()
  "Check if the 'howdoi' command is available."
  (when (not (executable-find howdoi-command))
    (error "'%s' command not found" howdoi-command)))

(defun howdoi--1 (query)
  "Backend to the 'howdoi' command.

QUERY is the howdoi query."
  (howdoi--check-howdoi-is-present)
  (let ((buff-name howdoi-buffer-name))
    (with-help-window buff-name
      (with-current-buffer buff-name
        (erase-buffer)
        (insert (propertize (format "Query: %s" query)
                            'face 'howdoi-query-face))
        (insert "\n\n")
        (insert (propertize (format "Answer %s:" howdoi-answer-number)
                            'face 'howdoi-answer-number-face))
        (insert "\n\n")
        (let ((command (format "%s %s -p %s %s %s"
                               howdoi-command
                               (if howdoi-use-colors "-c" "")
                               howdoi-answer-number
                               (if howdoi-full-answer "-a" "")
                               query)))
          (call-process-shell-command  command nil (get-buffer buff-name))
          (ansi-color-apply-on-region (point-min) (point-max))
          (howdoi-mode))))))


;;;;;;;;;;;;;;;;;;
;;; User functions

(defun howdoi (query &optional jump-to-it)
  "Backend to the 'howdoi' command.

QUERY is the howdoi query.
if JUMP-TO-IT is non-nil, select the howdoi buffer."
  (interactive "sQuery: ")
  (setq howdoi-last-query query)
  (setq howdoi-answer-number 1)
  (howdoi--1 query)
  (when jump-to-it (switch-to-buffer-other-window howdoi-buffer-name)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; howdoi mode to view results

(define-derived-mode howdoi-mode help-mode "Howdoi"
  "Mode used to display Howdoi results."
  :group 'howdoi-mode)

(defun howdoi-show-next-answer (answer-number)
  "Show the next answer.

If ANSWER-NUMBER is a number, jumpt to this answer number."
  (interactive "P")
  (if answer-number
      (setq howdoi-answer-number answer-number)
    (setq howdoi-answer-number (+ howdoi-answer-number 1)))
  (howdoi--1 howdoi-last-query))

(defun howdoi-show-previous-answer (answer-number)
  "Show the next answer.

If ANSWER-NUMBER is a number, jumpt to this answer number."
  (interactive "P")
  (if answer-number
      (setq howdoi-answer-number answer-number)
    (setq howdoi-answer-number (- howdoi-answer-number 1)))
  (when (< howdoi-answer-number 1)
    (setq howdoi-answer-number 1)
    (message "First answer !"))
  (howdoi--1 howdoi-last-query))

(defun howdoi-toggle-full-answer ()
  "Toggle the display of the full answer."
  (interactive)
  (if howdoi-full-answer
      (setq howdoi-full-answer nil)
      (setq howdoi-full-answer t))
  (howdoi--1 howdoi-last-query))

(defun howdoi-goto-webpage ()
  "Goto the web page coresponding to current answer."
  (interactive)
  (howdoi--check-howdoi-is-present)
  (with-temp-buffer
    (call-process-shell-command
     (format "%s -p %s -l %s"
             howdoi-command
             howdoi-answer-number
             howdoi-last-query)
     nil (current-buffer))
    (browse-url (buffer-substring-no-properties (point-min) (point-max)))))

(defun howdoi-yank-code ()
  "Yank the current answer code."
  (interactive)
  (save-excursion
    (with-current-buffer howdoi-buffer-name
      (goto-char (point-min))
      (forward-line 4)
      (kill-ring-save (point) (point-max)))))

(define-key howdoi-mode-map (kbd "n") 'howdoi-show-next-answer)
(define-key howdoi-mode-map (kbd "p") 'howdoi-show-previous-answer)
(define-key howdoi-mode-map (kbd "f") 'howdoi-toggle-full-answer)
(define-key howdoi-mode-map (kbd "z") 'howdoi-goto-webpage)
(define-key howdoi-mode-map (kbd "y") 'howdoi-yank-code)

(with-eval-after-load 'evil-core
  (evil-set-initial-state 'howdoi-mode 'motion)
  (evil-define-key 'motion howdoi-mode-map
    (kbd "n") 'howdoi-show-next-answer
    (kbd "p") 'howdoi-show-previous-answer
    (kbd "f") 'howdoi-toggle-full-answer
    (kbd "y") 'howdoi-yank-code
    (kbd "z") 'howdoi-goto-webpage))

(provide 'howdoi)
;;; howdoi.el ends here
