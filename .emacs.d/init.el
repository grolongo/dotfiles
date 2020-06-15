;;; start

;; Use a hook so the message doesn't get clobbered by other messages.
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs ready in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; Make startup faster by reducing the frequency of garbage
;; collection.  The default is 0.8MB.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000)
      gc-cons-percentage 0.6)

;; Unset file-name-handler-alist temporarily
(defvar my-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;;; PACKAGING & REPO

(require 'package)
(setq package-enable-at-startup nil) ; to prevent initialising twice
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(setq use-package-always-demand (daemonp)
      use-package-compute-statistics t
      use-package-enable-imenu-support t)
      ;; use-package-verbose t)
(eval-when-compile (require 'use-package))

;;; GENERAL SETTINGS

(if (display-graphic-p)
    (cond
     ((string-equal system-type "windows-nt")
      (tool-bar-mode -1)
      (menu-bar-mode -1))
     ((string-equal system-type "darwin")
      (tool-bar-mode -1)))
  (menu-bar-mode -1))

(setq-default cursor-type 'bar
              indent-tabs-mode nil
              indicate-empty-lines t
              show-trailing-whitespace t)

(setq eol-mnemonic-dos "(DOS)"
      eol-mnemonic-undecided "(?)"
      frame-inhibit-implied-resize t
      inhibit-startup-screen t
      load-prefer-newer t
      scroll-conservatively most-positive-fixnum)

(add-to-list 'default-frame-alist '(height . 40))
(add-to-list 'default-frame-alist '(width . 115))

;; enables trackpad scrolling in emacs terminal
(unless window-system
  (global-set-key (kbd "<mouse-4>") 'scroll-down-line)
  (global-set-key (kbd "<mouse-5>") 'scroll-up-line))

;;; BUILT-IN PACKAGES

(use-package auth-source
  :defer t
  :custom (auth-sources '("~/.emacs.d/.authinfo.gpg")))

(use-package bookmark)

(use-package cus-edit
  :defer t
  :custom (custom-file (concat user-emacs-directory "custom.el"))
  :config
  (when (file-exists-p custom-file)
    (load custom-file)))

(use-package elec-pair
  :config (electric-pair-mode 1))

(use-package epa-file
  :defer t
  :custom
  ;; on Emacs 27 epg-pinentry-mode replaces epa-pinentry-mode
  (epa-pinentry-mode 'loopback)
  :config
  (setenv "GPG_AGENT_INFO" nil)
  (epa-file-enable))

(use-package erc
  :defer t
  :preface
  (defun my/freenode-erc ()
    "custom settings for freenode irc network"
    (interactive)
    (erc :server "irc.freenode.net" :port 6667 :nick "b1anc"))
  (defun my/oftc-erc ()
    "custom settings for oftc irc network"
    (interactive)
    (erc :server "irc.oftc.net" :port 6667 :nick "blanc"))
  :custom
  (erc-track-showcount t)
  (erc-track-shorten-function nil)
  (erc-track-exclude-types '("JOIN" "PART" "QUIT" "NICK" "MODE"))
  (erc-track-position-in-mode-line t) ; don't show in mode line modes for minions
  (erc-prompt-for-nickserv-password nil)
  (erc-kill-buffer-on-part t)
  (erc-kill-queries-on-quit t)
  (erc-kill-server-buffer-on-quit t)
  (erc-timestamp-only-if-changed-flag nil)
  (erc-timestamp-format "%H:%M")
  (erc-insert-timestamp-function 'erc-insert-timestamp-left)
  (erc-hide-list '("JOIN" "PART" "QUIT"))
  (erc-lurker-hide-list '("JOIN" "PART" "QUIT"))
  ;;(erc-lurker-threshold-time 1800)
  (erc-fill-function 'erc-fill-static)
  (erc-fill-static-center 20)
  (erc-dcc-mode nil)
  (erc-dcc-chat-request 'ignore)
  (erc-dcc-send-request 'ignore)
  (erc-paranoid t)
  (erc-disable-ctcp-replies t))

(use-package faces
  :config
  (cond ((string-equal system-type 'windows-nt)
         (set-face-attribute 'default nil :font "Consolas-11"))
        ((string-equal system-type 'darwin)
         (set-face-attribute 'default nil :font "SF Mono-18"))))

(use-package files
  :custom
  (auto-save-file-name-transforms
   `((".*" "~/.emacs.d/auto-save-list/" t)))
  (backup-directory-alist
   `(("." . ,(concat user-emacs-directory "backups"))))
  (require-final-newline t))

(use-package frame
  :config (blink-cursor-mode -1))

(use-package help
  :defer t
  :custom (help-window-select t))

(use-package hexl
  :mode ("\\.exe\\'" . hexl-mode)
  :interpreter ("hexl" . hexl-mode))

(use-package ls-lisp
  :defer t
  :custom (ls-lisp-dirs-first t))

(use-package mwheel
  :custom (mouse-wheel-progressive-speed nil)
  :config (mouse-wheel-mode 1))

(use-package mule
  :config
  (set-language-environment "UTF-8")
  (prefer-coding-system 'utf-8-unix)
  (set-default-coding-systems 'utf-8-unix)
  (set-keyboard-coding-system 'utf-8-unix))

(use-package ns-win
  :if (memq window-system '(mac ns))
  :custom
  (mac-command-modifier 'meta)
  (mac-right-option-modifier 'none))

(use-package org
  :preface
  (defun my/org-fill-width ()
    "Autofill and fill column size for org-mode."
    (auto-fill-mode)
    (set-fill-column 60))
  (defun my/create-note-file ()
    "Create an org file in Notes folder."
    (interactive)
    (let ((name (read-string "Filename (don't add extension): ")))
          (expand-file-name (format "%s.org"
                                    name) org-directory)))
  :hook (org-mode . my/org-fill-width)
  :bind (("C-c c" . org-capture)
         ("C-c a" . org-agenda))
  :custom
  ;; (org-indent-mode-turns-on-hiding-stars nil)
  ;; (org-indent-indentation-per-level 1)
  ;; (org-startup-indented t)
  (org-capture-templates
   '(("f" "New file note" plain (file my/create-note-file)
      "#+TITLE: %^{Title}\n\n* %?")
     ("t" "TODO [inbox]" entry (file+headline "" "Refile")
      "* TODO %?")
     ("n" "Note [inbox]" entry (file "")
      "* %?" :empty-lines 1)
     ("p" "Note [inbox] (plain)" plain (file "")
      "%?" :empty-lines 1)
     ("c" "Citation" entry (file "citations.org")
      "* %^{Author}\n\n#+BEGIN_VERSE\n%c\n#+END_VERSE%?" :empty-lines 1)))
  :config
  (when (bookmark-get-bookmark "Notes" t)
    (setq org-directory (bookmark-location "Notes"))
    (setq org-default-notes-file (concat org-directory "inbox.org"))
    (setq org-agenda-files (directory-files-recursively org-directory "org$"))))

(use-package outline
  :preface
  (defun my/outline-elisp ()
    "Setting the outline regexp for folding in emacs lisp mode."
    (outline-minor-mode 1)
    (setq-local outline-regexp ";;; ")
    (outline-hide-body))
  (defun my/outline-sh-space-ps ()
    "Setting the outline regexp for folding in (power)shell mode and tmux conf."
    (outline-minor-mode 1)
    (setq-local outline-regexp "### ")
    (outline-hide-body))
  (defun my/outline-xdefaults ()
    "Setting the outline regexp for folding in xdefaults conf mode."
    (outline-minor-mode 1)
    (setq-local outline-regexp "!!! ")
    (outline-hide-body))
  :hook ((emacs-lisp-mode . my/outline-elisp)
         (sh-mode . my/outline-sh-space-ps)
         (conf-space-mode . my/outline-sh-space-ps)
         (powershell-mode . my/outline-sh-space-ps)
         (conf-xdefaults-mode . my/outline-xdefaults))
  :bind ("C-c SPC" . outline-toggle-children))

(use-package paren
  :custom (show-paren-delay 0)
  :config (show-paren-mode 1))

(use-package recentf
  :custom
  (recentf-keep '(file-remote-p file-readable-p))
  (recentf-max-saved-items 20)
  (recentf-exclude '("/elpa/"))
  :config (recentf-mode 1))

(use-package saveplace
  :preface
  (defun my/save-place-recenter ()
    "Force windows to recenter current line (with saved position)."
    (run-with-timer 0 nil
                    (lambda (buf)
                      (when (buffer-live-p buf)
                        (dolist (win (get-buffer-window-list buf nil t))
                          (with-selected-window win (recenter)))))
                    (current-buffer)))
  :custom (save-place-forget-unreadable-files t)
  :config
  (add-hook 'find-file-hook 'my/save-place-recenter t)
  (save-place-mode 1))

(use-package scroll-bar
  :if window-system
  :config
  (scroll-bar-mode -1)
  (horizontal-scroll-bar-mode -1))

(use-package simple
  :config (column-number-mode 1))

(use-package uniquify
  :ensure nil ; uniquify isn't a package.el package so not visible as a built-in one
  :custom (uniquify-buffer-name-style 'reverse))

(use-package vc
  :defer t
  :custom (vc-follow-symlinks t))

(use-package windmove
  :defer 2
  :config (windmove-default-keybindings))

(use-package xt-mouse
  :if (eq window-system nil)
  :config (xterm-mouse-mode t))

;;; THIRD-PARTY PACKAGES

(use-package amx
  :defer 1
  :ensure t
  :config (amx-mode 1))

(use-package diff-hl
  :pin gnu
  :ensure t
  :after vc
  :config
  ;; to use in emacs terminal if fringe doesnt work
  ;; (diff-hl-margin-mode)
  ;; (diff-hl-flydiff-mode 1)
  (diff-hl-dired-mode 1)
  (global-diff-hl-mode 1))

(use-package dired-subtree
  :ensure t
  :after ls-lisp
  :config
  (bind-keys :map dired-mode-map
             ("i" . dired-subtree-insert)
             ("I" . dired-subtree-remove)))

(use-package erc-hl-nicks
  :ensure t
  :after erc
  :hook (erc-mode . 'erc-hl-nicks-mode))

(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

(use-package modus-vivendi-theme
  :pin gnu
  :ensure t
  :custom
  (modus-vivendi-theme-slanted-constructs t)
  (modus-vivendi-theme-bold-constructs t)
  (modus-vivendi-theme-3d-modeline t)
  (modus-vivendi-theme-distinct-org-blocks t)
  (modus-vivendi-theme-rainbow-headings t)
  :config (load-theme 'modus-vivendi t))

(use-package powershell
  :defer t
  :ensure t)

;; (use-package which-key
  ;; :defer 2
  ;; :pin gnu
  ;; :ensure t
  ;; :config (which-key-mode 1))

;;; Ivy, Counsel, Swiper

(use-package ivy
  :ensure t
  :custom
  (ivy-use-virtual-buffers t)
  (ivy-count-format "(%d/%d) ")
  (ivy-initial-inputs-alist nil)
  :config (ivy-mode 1))

(use-package counsel
  :ensure t
  :after ivy
  :bind (("C-x C-f" . counsel-find-file)
         ;; ("C-c C-r" . counsel-recentf)
         ("C-x b" . counsel-switch-buffer)
         ("C-x 4 b" . counsel-switch-buffer-other-window)
         ("C-h f" . counsel-describe-function)
         ("C-h v" . counsel-describe-variable)
         ("M-x" . counsel-M-x))
  :custom (counsel-switch-buffer-preview-virtual-buffers nil)
  :config (counsel-mode 1))

(use-package swiper
  :ensure t
  :after ivy
  :bind ("C-s" . swiper-isearch))

;;; end

;; Make gc pauses faster by decreasing the threshold.
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 2 1000 1000)
                  gc-cons-percentage 0.1)))

;; Restore file-name-handler-alist
(add-hook 'emacs-startup-hook
  (lambda ()
    (setq file-name-handler-alist my-file-name-handler-alist)))
