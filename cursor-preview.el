;;; cursor-preview.el --- Preview cursor movement while execute command interactively  -*- lexical-binding: t; -*-

;; Copyright (C) 2020-2026  Shen, Jen-Chieh
;; Created date 2020-09-27 13:15:48

;; Author: Shen, Jen-Chieh <jcs090218@gmail.com>
;; URL: https://github.com/jcs-elpa/cursor-preview
;; Version: 0.1.1
;; Package-Requires: ((emacs "24.3"))
;; Keywords: convenience interactive preview cursor movement display

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This global minor mode moves the cursor from the main window according
;; to some possible commands.
;;
;; Some possible commands are `goto-line', `goto-char', `goto-line-relative',
;; `move-to-column', etc.
;;
;; You can enable this mode by simply doing the following exection.
;;
;;  `(cursor-preview-mode 1)`
;;

;;; Code:

(defgroup cursor-preview nil
  "Preview cursor movement while execute command interactively."
  :prefix "cursor-preview-"
  :group 'tool
  :link '(url-link :tag "Repository" "https://github.com/jcs-elpa/cursor-preview"))

(defcustom cursor-preview-commands
  '(goto-char
    goto-line goto-line-relative
    move-to-column)
  "List of commands to do preview."
  :type 'list
  :group 'cursor-preview)

(defvar cursor-preview--window-point nil
  "Record the window point.")

(defvar cursor-preview--current-command nil
  "Record the current command.")

;;; Util

(defun cursor-preview--goto-line (ln)
  "Goto line number (LN)."
  (goto-char (point-min))
  (forward-line (1- ln)))

(defun cursor-preview--goto-line-relative (ln)
  "Goto realtive line number (LN)."
  (cursor-preview--goto-line (+ (line-number-at-pos) ln)))

;;; Core

(defun cursor-preview--preview ()
  "Do preview after input from minibuffer."
  (let ((input (thing-at-point 'line)))
    (with-selected-window minibuffer-scroll-window
      (if (not input)
          (set-window-point (selected-window) cursor-preview--window-point)
        (cl-case cursor-preview--current-command
          ;; NOTE: Character
          ('goto-char
           (let ((char-pos (string-to-number input)))
             (when (numberp char-pos) (goto-char char-pos))))
          ;; NOTE: Line
          ('goto-line
           (let ((ln (string-to-number input)))
             (when (numberp ln) (cursor-preview--goto-line ln))))
          ('goto-line-relative
           (let ((ln (string-to-number input)))
             (when (numberp ln) (cursor-preview--goto-line-relative ln))))
          ;; NOTE: Column
          ('move-to-column
           (let ((col (string-to-number input)))
             (when (numberp col) (move-to-column col)))))))))

(defun cursor-preview--minibuffer-setup ()
  "Minibuffer setup."
  (when (memq this-command cursor-preview-commands)
    (with-selected-window minibuffer-scroll-window
      (setq cursor-preview--window-point (window-point)))
    (setq cursor-preview--current-command this-command)
    (add-hook 'post-command-hook #'cursor-preview--preview nil t)))

(defun cursor-preview--minibuffer-exit ()
  "Minibuffer exit."
  (when cursor-preview--current-command
    (setq cursor-preview--current-command nil)
    (with-selected-window minibuffer-scroll-window
      (set-window-point (selected-window) cursor-preview--window-point))))

;;; Entry

(defun cursor-preview--enable ()
  "Enable `cursor-preview'."
  (add-hook 'minibuffer-setup-hook #'cursor-preview--minibuffer-setup)
  (add-hook 'minibuffer-exit-hook #'cursor-preview--minibuffer-exit))

(defun cursor-preview--disable ()
  "Disable `cursor-preview'."
  (remove-hook 'minibuffer-setup-hook #'cursor-preview--minibuffer-setup)
  (remove-hook 'minibuffer-exit-hook #'cursor-preview--minibuffer-exit))

;;;###autoload
(define-minor-mode cursor-preview-mode
  "Minor mode 'cursor-preview-mode'."
  :global t
  :require 'cursor-preview
  :group 'cursor-preview
  (if cursor-preview-mode (cursor-preview--enable) (cursor-preview--disable)))

(provide 'cursor-preview)
;;; cursor-preview.el ends here
