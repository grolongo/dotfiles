;;; early-init.el --- -*- lexical-binding: t; -*-

;;; Commentary:
;; Emacs early startup file

;;; Code:

;;; Garbage collector tweak (taken from doom-emacs)
(defvar my-gc-cons-threshold 16777216) ; 16mb, default = 800000
(defvar default-gc-cons-percentage gc-cons-percentage) ; default = 0.1
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)
;; restoring gc to default/reasonable values
(defun my/reset-garbage-collector ()
  "Restore settings to reasonable values after init."
  (add-hook 'emacs-startup-hook
            (setq gc-cons-threshold my-gc-cons-threshold
                  gc-cons-percentage default-gc-cons-percentage)
            (makunbound 'default-gc-cons-percentage)))
(add-hook 'emacs-startup-hook #'my/reset-garbage-collector)

;;; `file-name-handler-alist' tweak (taken from doom-emacs)
(unless (daemonp)
  (defvar default-file-name-handler-alist file-name-handler-alist)
  (setq file-name-handler-alist nil)
  ;; restoring `file-name-handler-alist' to default value.
  (defun my/reset-file-handler-alist ()
    ;; Re-add rather than `setq', because changes to `file-name-handler-alist'
    ;; since startup ought to be preserved.
    (dolist (handler file-name-handler-alist)
      (add-to-list 'default-file-name-handler-alist handler))
    (setq file-name-handler-alist default-file-name-handler-alist)
    (makunbound 'default-file-name-handler-alist))
  (add-hook 'emacs-startup-hook #'my/reset-file-handler-alist))

;;; Frame elements
(push '(menu-bar-mode . 0) default-frame-alist)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(height . 46) default-frame-alist)
(push '(width . 190) default-frame-alist)
;; Added this after using --with-metal for emacs-mac port,
;; since Metal takes care of double-buffering.
;; https://bitbucket.org/mituharu/emacs-mac/commits/15b25d3144f3b802d0f11caf4017827ab400d7ba?at=work
;; (remove if flickers and half-way updates occur)
(and (eq system-type 'darwin)
     (string-match-p (regexp-quote "--with-mac-metal") system-configuration-options)
     (push '(inhibit-double-buffering . t) default-frame-alist))

;; Remove command line options that aren't relevant to our current OS; means
;; slightly less to process at startup.
(unless (eq system-type 'darwin)
  (setq command-line-ns-option-alist nil))
(unless (eq system-type 'gnu/linux)
  (setq command-line-x-option-alist nil))

(custom-set-variables
 '(inhibit-startup-screen t)
 '(initial-major-mode 'fundamental-mode)
 '(frame-inhibit-implied-resize t))

;; package.el and MELPA
(setq package-quickstart t)
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;;; early-init.el ends here
