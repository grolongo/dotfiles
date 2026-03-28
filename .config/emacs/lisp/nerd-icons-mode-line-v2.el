;;; nerd-icons-mode-line-v2.el --- -*- lexical-binding: t; -*-

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package applies icons from `nerd-icons' to the mode line,
;; right before the filename.

;; You will need `nerd-icons' installed, as this one is complementary.
;; Use `nerd-icons-mode-line-global-mode' to toggle the display.

;;; Code:

(require 'nerd-icons)
(require 'cl-lib)

(defgroup nerd-icons-mode-line nil
  "Manage how Nerd Icons show up in the mode line."
  :prefix "nerd-icons-mode-line-"
  :group 'appearance
  :group 'convenience)

(defcustom nerd-icons-mode-line-v-adjust 0.1
  "Raises the icon vertical position."
  :group 'nerd-icons-mode-line
  :type 'float)

(defcustom nerd-icons-mode-line-size 1.0
  "Changes the display size of the icon."
  :group 'nerd-icons-mode-line
  :type 'float)

(defvar mode-line-nerd-icon
  '(:eval
    (when-let* ((icon (with-current-buffer (current-buffer) (nerd-icons-icon-for-buffer)))
                (v-adjust nerd-icons-mode-line-v-adjust)
                (size nerd-icons-mode-line-size))
      (propertize (concat icon " ")
                  'display `((raise ,v-adjust)
                             (height ,size))))))

(defvar original mode-line-nerd-icon
  "Pristine variable, original value of `mode-line-nerd-icon'.")

(put 'mode-line-nerd-icon 'risky-local-variable t)

(let ((idx (cl-position 'mode-line-buffer-identification mode-line-format)))
  (setq-default mode-line-format
                (append (cl-subseq mode-line-format 0 idx) '(mode-line-nerd-icon) (cl-subseq mode-line-format idx))))

;;;###autoload
(define-minor-mode nerd-icons-mode-line-global-mode
  "Toggle icon display for all buffers in the mode line."
  :group 'nerd-icons-mode-line
  :init-value nil
  :lighter nil
  :keymap nil
  :global t
  (if nerd-icons-mode-line-global-mode
      (setq-default mode-line-nerd-icon original)
    (setq-default mode-line-nerd-icon ""))
  (force-mode-line-update t))

(provide 'nerd-icons-mode-line-v2)

;;; nerd-icons-mode-line-v2.el ends here
