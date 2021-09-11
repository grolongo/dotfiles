;;; init.el --- -*- lexical-binding: t; -*-

;;; Commentary:
;; Emacs startup file

;;; Code:

;;; Startup Timer
;; Use a hook so the message doesn't get clobbered by other messages.
(defun my/emacs-startup-time ()
  "Show the load time at startup in the minibuffer."
  (message "Emacs ready in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                    (time-subtract after-init-time before-init-time)))
           gcs-done))
(add-hook 'emacs-startup-hook #'my/emacs-startup-time)

;;;;;;;;;;;;;;;;;;;
;;; USE-PACKAGE ;;;
;;;;;;;;;;;;;;;;;;;

;; Use the following ordering for use-package keywords:
;; :preface
;; :straight
;; :no-require
;; :defines
;; :functions
;; :demand
;; :defer
;; :after
;; :commands
;; :init
;; :magic
;; :mode
;; :interpreter
;; :hook
;; :bind
;; :bind-keymap
;; :config

;; Make sure `use-package’ is available.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Configure `use-package' prior to loading it.
(eval-and-compile
  (setq use-package-always-demand (daemonp)
        use-package-enable-imenu-support t))

(eval-when-compile
  (require 'use-package))

;;;;;;;;;;;;;;;;;;;;;;;;
;;; GENERAL SETTINGS ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-variables
 '(auto-save-no-message t)
 '(create-lockfiles nil)
 '(frame-title-format
   `((buffer-file-name "%f" "%b")
     ,(format " - GNU Emacs %s" emacs-version)))
 '(indent-tabs-mode nil)
 '(indicate-empty-lines t)
 '(load-prefer-newer t)
 '(mode-line-compact 'long) ; emacs 28
 '(ring-bell-function 'ignore)
 '(scroll-conservatively most-positive-fixnum)
 '(use-dialog-box nil)
 '(use-short-answers t)) ; emacs 28

;; trailing whitespaces
(defun my/show-trailing-whitespace ()
  "Show trailing whitespace in relevant modes."
  (setq show-trailing-whitespace t))
(dolist (hook '(prog-mode-hook text-mode-hook))
  (add-hook hook 'my/show-trailing-whitespace))

;; Add prompt indicator to `completing-read-multiple'
(defun crm-indicator (args)
  (cons (concat "[CRM] " (car args)) (cdr args)))
(advice-add #'completing-read-multiple :filter-args #'crm-indicator)

;; Enable hyper & super keys
(cond ((eq system-type 'windows-nt)
       ;; right Windows key for super
       (setq w32-pass-rwindow-to-system nil)
       (setq w32-rwindow-modifier 'super)
       (w32-register-hot-key [s-]))
       ;; left Windows key for hyper
       ;; (setq w32-pass-lwindow-to-system nil)
       ;; (setq w32-lwindow-modifier 'hyper)
       ;; (w32-register-hot-key [H-]))
      ((eq system-type 'darwin)
       ;; left alt for hyper
       (setq mac-option-modifier 'hyper)
       ;; disable right alt for special chars
       (setq mac-right-option-modifier 'nil)
       ;; right command for super
       (setq mac-right-command-modifier 'super)))

;;;;;;;;;;;;;;;;
;;; MODELINE ;;;
;;;;;;;;;;;;;;;;

(column-number-mode 1)

;;; *%
(setq-default mode-line-modified
              '((:eval
                 (if buffer-read-only
                     (propertize
                      "🔒"
                      'mouse-face 'mode-line-highlight
                      'help-echo 'mode-line-read-only-help-echo
                      'local-map (purecopy (make-mode-line-mouse-map
			                    'mouse-1 #'mode-line-toggle-read-only)))
                   (propertize
                    "-"
                    'mouse-face 'mode-line-highlight
                    'help-echo 'mode-line-read-only-help-echo
                    'local-map (purecopy (make-mode-line-mouse-map
                                          'mouse-1 #'mode-line-toggle-read-only)))))
                (:eval
                 (if (buffer-modified-p)
                     (propertize
                      "*"
                      'mouse-face 'mode-line-highlight
                      'help-echo 'mode-line-modified-help-echo
                      'local-map (purecopy (make-mode-line-mouse-map
                                            'mouse-1 #'mode-line-toggle-modified)))
                   (propertize
                    "-"
                    'mouse-face 'mode-line-highlight
                    'help-echo 'mode-line-modified-help-echo
                    'local-map (purecopy (make-mode-line-mouse-map
                                          'mouse-1 #'mode-line-toggle-modified)))))))

;;; emacsclient @

(setq-default mode-line-client
              `(""
                (:propertize ("" (:eval (if (frame-parameter nil 'client) "😈" "")))
		             help-echo ,(purecopy "emacsclient frame"))))

;;;;;;;;;;;;;;;;;;;;;;;;;
;;; BUILT-IN PACKAGES ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package auth-source
  :disabled t
  :custom
  ;; (auth-source-debug t)
  (auth-sources (list (expand-file-name "authinfo.gpg" user-emacs-directory))))

(use-package autorevert
  :custom
  (auto-revert-verbose t)
  (global-auto-revert-non-file-buffers t)
  :config (global-auto-revert-mode t))

(use-package bookmark :demand t)

(use-package cus-edit
  :custom
  ;; disabling custom entirely
  (custom-file (make-temp-file "emacs-custom")))
  ;; this is if I want to enable custom again:
  ;; (custom-file (expand-file-name "custom.el" user-emacs-directory))
  ;; :config
  ;; (when (file-exists-p custom-file)
  ;; (load custom-file)))

(use-package delsel
  :config (delete-selection-mode 1))

(use-package desktop
  ;; :hook (server-after-make-frame . desktop-read)
  :custom
  (desktop-dirname (expand-file-name user-emacs-directory))
  (desktop-load-locked-desktop t)
  ;; (desktop-save 'ask-if-new)
  :config (desktop-save-mode -1))

(use-package dired
  ;; :hook (dired-mode . dired-hide-details-mode)
  :bind (:map dired-mode-map
              ("RET" . dired-find-alternate-file))
  :custom
  (delete-by-moving-to-trash t)
  (dired-listing-switches "-aFhl1v" --group-directories-first)
  :config
  (when (string-equal system-type 'darwin)
    (setq ls-lisp-use-insert-directory-program nil))
  (put 'dired-find-alternate-file 'disabled nil))

(use-package eldoc :delight)

(use-package electric
  :hook (org-mode . electric-quote-local-mode)
  :custom
  (electric-quote-context-sensitive t)
  (electric-quote-paragraph t)
  (electric-quote-comment nil)
  (electric-quote-string nil)
  (electric-quote-replace-double t)
  :config (electric-quote-mode -1))

(use-package elec-pair
  :custom
  (electric-pair-inhibit-predicate 'electric-pair-conservative-inhibit)
  (electric-pair-skip-whitespace nil)
  :config (electric-pair-mode 1))

(use-package erc
  :preface
  ;; let query buffers tracked as if everything contains our current nick,
  ;; better reflecting the urgency of a private message.
  (defadvice erc-track-find-face (around erc-track-find-face-promote-query activate)
    (if (erc-query-buffer-p)
        (setq ad-return-value (intern "erc-current-nick-face"))
      ad-do-it))

  ;; shows total number of (ops/voice/regular) users in the modeline
  (define-minor-mode erc-count-users-mode "" nil
    (:eval
     (let ((ops 0)
           (voices 0)
           (members 0))
       (maphash (lambda (key value)
                  (when (erc-channel-user-op-p key)
                    (setq ops (1+ ops)))
                  (when (erc-channel-user-voice-p key)
                    (setq voices (1+ voices)))
                  (setq members (1+ members)))
                erc-channel-users)
       (format " %S/%S/%S" ops voices members))))

  (defun my/freenode ()
    "Creates tab and connects using TLS to Freenode."
    (interactive)
    (if (get-buffer "irc.freenode.net:6697")
        (progn
          (tab-bar-switch-to-tab "ERC")
          (message "Already connected to Freenode."))
      (if (try-completion "ERC" (mapcar #'cdadr (funcall tab-bar-tabs-function)))
          (tab-bar-switch-to-tab "ERC")
        (tab-new)
        (tab-rename "ERC"))
      (erc-tls :server "irc.freenode.net" :port 6697 :nick "b1anc")))

  (defun my/oftc ()
    ;; as of 20/04/21 OFTC doesn't allow automatic authentication
    ;; with user/password mechanism so we must
    ;; /msg nickserv identify <password> to auth.
    ;; using CertFP is a solution for automatic auth but setting it
    ;; in Emacs is a pain.
    "Creates tab and connects using TLS credentials for OFTC."
    (interactive)
    (if (get-buffer "irc.oftc.net:6697")
        (progn
          (tab-bar-switch-to-tab "ERC")
          (message "Already connected to OFTC."))
      (if (try-completion "ERC" (mapcar #'cdadr (funcall tab-bar-tabs-function)))
          (tab-bar-switch-to-tab "ERC")
        (tab-new)
        (tab-rename "ERC"))
      (erc-tls :server "irc.oftc.net" :port 6697 :nick "blanc")))
  :hook ((erc-mode . erc-log-mode)
         (erc-join . erc-count-users-mode))
  :custom-face (erc-current-nick-face ((t (:foreground "red" :weight bold))))
  :custom
  (erc-kill-buffer-on-part t)
  (erc-kill-queries-on-quit t)
  (erc-kill-server-buffer-on-quit t)
  ;; display
  (erc-timestamp-only-if-changed-flag nil)
  (erc-timestamp-format "%H:%M")
  (erc-insert-timestamp-function 'erc-insert-timestamp-left)
  (erc-lurker-hide-list '("JOIN" "PART" "QUIT"))
  (erc-lurker-threshold-time 43200)
  (erc-fill-function 'erc-fill-static)
  (erc-fill-static-center 20)
  (erc-fill-column 85)
  (erc-prompt (lambda () (concat (buffer-name)">")))
  ;; modeline
  (erc-track-showcount t)
  (erc-track-exclude-types '("JOIN" "PART" "QUIT" "NICK" "MODE" "333" "353"))
  (erc-track-position-in-mode-line 'after-modes)
  (erc-track-shorten-start 3)
  ;; queries
  (erc-auto-query 'bury)
  (erc-query-display 'buffer)
  ;; DCC & CTCP
  (erc-dcc-mode nil)
  (erc-dcc-chat-request 'ignore)
  (erc-dcc-send-request 'ignore)
  (erc-paranoid t)
  (erc-disable-ctcp-replies t)
  ;; logs
  (erc-log-channels-directory (expand-file-name "erc_logs" user-emacs-directory))
  (erc-generate-log-file-name-function 'erc-generate-log-file-name-short)
  (erc-enable-logging 'erc-log-all-but-server-buffers)
  (erc-log-matches-flag t)
  :config
  ;; notifications, only available for systems with DBUS (mostly linux)
  (when (string-equal system-type 'gnu/linux)
    (erc-notifications-mode 1)))

(use-package face-remap
  :delight (buffer-face-mode)
  :bind (("M-+" . text-scale-increase)
         ("M--" . text-scale-decrease)
         ("M-=" . (lambda ()
                    (interactive)
                    (text-scale-set 0)))))

(use-package faces ; linux
  :when (string-equal system-type 'gnu/linux)
  :preface
  (defun my/set-emoji-font ()
    (set-fontset-font t 'symbol (font-spec :family "Noto Color Emoji"))
    (set-fontset-font t 'symbol (font-spec :family "Symbola" nil 'append)))
  :custom-face
  (default ((t (:family "DejaVu Sans Mono" :height 160))))
  (fixed-pitch ((t (:family "DejaVu Sans Mono" :height 1.0))))
  (variable-pitch ((t (:family "Times" :height 1.0))))
  :config
  (if (daemonp)
      (add-hook 'server-after-make-frame-hook #'my/set-emoji-font)
    (my/set-emoji-font)))

(use-package faces ; windows
  :when (string-equal system-type 'windows-nt)
  :preface
  (defun my/set-emoji-font ()
    (set-fontset-font t 'symbol (font-spec :family "Segoe UI Emoji")))
  :custom-face
  (default ((t (:family "Consolas" :height 110)))) ; { Consolas, Cascadia }
  (fixed-pitch ((t (:family "Consolas" :height 1.0))))
  (variable-pitch ((t (:family "Georgia" :height 1.0)))) ; { screen: Georgia, print: Garamond, inbetween: Cambria}
  :config
  (if (daemonp)
      (add-hook 'server-after-make-frame-hook #'my/set-emoji-font)
    (my/set-emoji-font)))

(use-package faces ; macos
  :when (string-equal system-type 'darwin)
  :preface
  (defun my/set-emoji-font ()
    (set-fontset-font t 'symbol (font-spec :family "Apple Color Emoji")))
  :custom-face
  (default ((t (:family "Monaco" :height 150)))) ; { Menlo, SF Mono, Monaco }
  (fixed-pitch ((t (:family "Monaco" :height 1.0))))
  (variable-pitch ((t (:family "Times" :height 1.0))))
  :config
  (if (daemonp)
      (add-hook 'server-after-make-frame-hook #'my/set-emoji-font)
    (my/set-emoji-font)))

(use-package files
  :custom
  (auto-save-file-name-transforms
   `((".*" ,(expand-file-name "auto-save-list" user-emacs-directory) t)))
  (backup-directory-alist
   `(("." . ,(expand-file-name "backups" user-emacs-directory))))
  (backup-by-copying t)
  (delete-old-versions t)
  (kept-new-versions 6)
  (vc-make-backup-files t)
  (version-control t))

(use-package find-dired
  :custom (find-ls-option '("-exec ls -ldh {} +" . "-ldh")))

(use-package flymake
  :hook ((emacs-lisp-mode sh-mode) . flymake-mode) ;; don't add language modes whose linter is managed by LSP
  :custom (flymake-no-changes-timeout nil) ;; disable automatic checking
  :config (remove-hook 'flymake-diagnostic-functions 'flymake-proc-legacy-flymake))

(use-package frame
  :config
  (window-divider-mode 1)
  (blink-cursor-mode -1))

(use-package gnus
  :custom
  ;; Paths
  (gnus-home-directory (expand-file-name "gnus" user-emacs-directory))
  (nsm-settings-file (expand-file-name "network-security.data" gnus-home-directory))
  (gnus-nntpserver-file (expand-file-name "nntpserver" gnus-home-directory))
  ;; Settings
  (gnus-selected-method '(nnnil ""))
  (gnus-summary-thread-gathering-function 'gnus-gather-threads-by-subject)
  (gnus-parameters
   '((".*"
      (gnus-use-scoring nil)
      (expiry-wait . never)
      (display . all))))
  (gnus-secondary-select-methods
   '((nntp "news.gwene.org")))
  ;; (gnus-topic-topology '(("Gnus" visible)
  ;;                        (("Mailing lists" visible))
  ;;                        (("Blogs" visible)
  ;;                         (("Emacs" visible))
  ;;                         (("Security" visible))
  ;;                         (("Misc" visible)))
  ;;                        (("Youtube" visible))))
  ;; (gnus-topic-alist '(("Mailing lists")
  ;;                     ("Blogs")
  ;;                     (("Emacs"))
  ;;                     (("Security"))
  ;;                     (("Misc"))
  ;;                     ("Youtube")))
  ;; (gnus-topic-topology '(("Gnus" visible)
  ;;                        (("misc" visible))
  ;;                        (("hotmail" visible nil nil))
  ;;                        (("gmail" visible nil nil))))
  ;; key of topic is specified in my sample ".gnus.el"
  ;; (gnus-topic-alist '(("hotmail" ; the key of topic
  ;;                      "nnimap+hotmail:Inbox"
  ;;                      "nnimap+hotmail:Sent"
  ;;                      "nnimap+hotmail:Drafts")
  ;;                     ("gmail" ; the key of topic
  ;;                      "nnimap+gmail:INBOX"
  ;;                      "nnimap+gmail:[Gmail]/Sent Mail"
  ;;                      "nnimap+gmail:[Gmail]/Drafts")
  ;;                     ("misc" ; the key of topic
  ;;                      "nnfolder+archive:sent.2015-12"
  ;;                      "nnfolder+archive:sent.2016"
  ;;                      "nndraft:drafts")
  ;;                     ("Gnus")))
  :config
  (add-hook 'gnus-select-group-hook #'gnus-group-set-timestamp)
  (add-hook 'gnus-group-mode-hook 'gnus-topic-mode))

(use-package gnus-topic
  :config
  (with-eval-after-load 'gnus-topic
    (setq gnus-topic-topology '(("Gnus" visible)
                                (("misc" visible))
                                (("hotmail" visible nil nil))
                                (("gmail" visible nil nil))))
    ;; key of topic is specified in my sample ".gnus.el"
    (setq gnus-topic-alist '(("hotmail" ; the key of topic
                              "nnimap+hotmail:Inbox"
                              "nnimap+hotmail:Sent"
                              "nnimap+hotmail:Drafts")
                             ("gmail" ; the key of topic
                              "nnimap+gmail:INBOX"
                              "nnimap+gmail:[Gmail]/Sent Mail"
                              "nnimap+gmail:[Gmail]/Drafts")
                             ("misc" ; the key of topic
                              "nnfolder+archive:sent.2015-12"
                              "nnfolder+archive:sent.2016"
                              "nndraft:drafts")
                             ("Gnus")))))

(use-package grep
  ;; three useful commands:
  ;; =====================
  ;; lgrep, rgrep (recursive), vc-git-grep (recursive)
  ;; all three use `grep-files-aliases'
  ;; lgrep and rgrep use `grep-find-ignored-files'
  ;; rgrep uses `grep-find-ignored-directories'
  ;; vc-git-grep uses `vc-directory-exclusion-list'
  :custom (grep-save-buffers nil)
  :config
  (grep-apply-setting 'grep-highlight-matches 'always)
  (grep-apply-setting 'grep-find-use-xargs 'exec-plus)
  (push (cons "*" "* .[!.]* ..?*") grep-files-aliases))

(use-package help
  :custom (help-window-select t))

(use-package hexl
  :mode ("\\.exe\\'" . hexl-mode)
  :interpreter ("hexl" . hexl-mode))

(use-package ibuffer
  :bind ("C-x C-b" . ibuffer))

(use-package icomplete
  :disabled t
  :custom
  (icomplete-vertical-mode t) ; emacs 28 (icomplete-vertical-mode 1)
  (fido-vertical-mode t)      ; emacs 28 (should be just an alias of icomplete-vertical-mode)
  (icomplete-scroll)          ; emacs 28
  :config
  (icomplete-mode 1)
  (fido-mode 1))

(use-package imenu
  :custom (imenu-auto-rescan t))

(use-package isearch
  :custom
  (isearch-allow-scroll 'unlimited)
  (isearch-lazy-count t)
  (lazy-highlight-buffer t)
  (lazy-highlight-cleanup t)
  (lazy-count-prefix-format nil)
  (lazy-count-suffix-format " (%s/%s)"))

(use-package ls-lisp
  :custom (ls-lisp-dirs-first t))

(use-package minibuffer
  :preface
  (defun mb-defer-garbage-collection ()
    "Set the value for garbage collection when using the minibuffer."
    (setq gc-cons-threshold most-positive-fixnum))

  (defun mb-restore-garbage-collection ()
    "Defer and restore garbage collection after small delay.
Commands launched immediately after will also enjoy the benefits."
    (run-at-time
     3 nil (lambda () (setq gc-cons-threshold my-gc-cons-threshold))))
  :hook ((minibuffer-setup . mb-defer-garbage-collection)
         (minibuffer-exit . mb-restore-garbage-collection))
  :bind (:map minibuffer-local-completion-map
              ("<backtab>" . minibuffer-completion-help)
              ("SPC") ("?"))
  :custom
  ;; (completion-auto-help t)
  (completion-cycle-threshold 5)
  (completion-ignore-case t)
  ;; (completion-pcm-complete-word-inserts-delimiters t)
  (completion-show-help nil)
  ;; (completions-detailed t) ; emacs 28
  (completions-format 'vertical)
  (echo-keystrokes 0.25)
  (enable-recursive-minibuffers t)
  (read-answer-short t)
  (read-buffer-completion-ignore-case t)
  ;; (resize-mini-windows t)
  :config
  (minibuffer-depth-indicate-mode 1)
  (minibuffer-electric-default-mode 1))

(use-package misc
  :bind ("M-w" . zap-up-to-char)) ; remapping for azerty

(use-package mule
  :config (prefer-coding-system 'utf-8-unix))

(use-package mwheel
  :custom (mouse-wheel-progressive-speed nil)
  :config
  (mouse-wheel-mode 1)
  ;; enables trackpad scrolling in emacs terminal
  (unless window-system
    (global-set-key (kbd "<mouse-4>") 'scroll-down-line)
    (global-set-key (kbd "<mouse-5>") 'scroll-up-line)))

(use-package org
  :preface
  (defun my/org-fill-width ()
    "Autofill and fill column size for org-mode."
    (auto-fill-mode 1)
    (set-fill-column 60))

  (defun my/org-create-note-file ()
    "Create an org file in Notes folder."
    (let ((name (read-string "Filename (don't add extension): ")))
      (expand-file-name (format "%s.org" name) org-directory)))
  :hook ((org-mode . my/org-fill-width)
         (org-mode . variable-pitch-mode))
  :bind (("C-c c" . org-capture)
         ("C-c a" . org-agenda))
  :custom
  (org-use-speed-commands t)
  (org-special-ctrl-a/e t)
  (org-src-tab-acts-natively t)
  (org-edit-src-content-indentation 0)
  ;; (org-indent-mode-turns-on-hiding-stars nil)
  ;; (org-indent-indentation-per-level 1)
  ;; (org-startup-indented t)
  (org-capture-templates
   '(("f" "New file note" plain (file my/org-create-note-file)
      "#+TITLE:\n\n%?")
     ("t" "TODO [inbox]" entry (file+headline "" "Refile")
      "* TODO %?")
     ("n" "Note [inbox]" entry (file "")
      "* %?" :empty-lines 1)
     ("p" "Note [inbox] (plain)" plain (file "")
      "%?" :empty-lines 1)
     ("c" "Citation" entry (file "citations.org")
      "* %^{Author}\n\n#+BEGIN_VERSE\n%c\n#+END_VERSE%?" :empty-lines 1)))
  :config
  ;; Force a few faces to fixed-pitch, even in `variable-pitch-mode'
  (dolist (orgface '(org-checkbox org-done org-priority org-tag org-todo))
    (set-face-attribute orgface nil :inherit 'fixed-pitch))
  ;; Notes folder and inbox file
  (when (member "notes" (bookmark-all-names))
    ;; prepare to use project--list
    (setq org-directory (bookmark-location "notes")
          org-default-notes-file (expand-file-name "inbox.org" org-directory)
          org-agenda-files `(,org-default-notes-file)
          org-agenda-text-search-extra-files (directory-files-recursively org-directory "org$"))))

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
  ;; :hook ((emacs-lisp-mode . my/outline-elisp)
  ;;        (sh-mode . my/outline-sh-space-ps)
  ;;        ((conf-space-mode powershell-mode) . my/outline-sh-space-ps)
  ;;        (conf-xdefaults-mode . my/outline-xdefaults))
  :bind ("C-c C-c" . outline-toggle-children))

(use-package package
  :preface
  (defun my/package-list-updates ()
    "Find packages marked for action in *Packages*."
    (interactive)
    (setq package-menu-async nil)
    (list-packages)
    (package-menu-mark-upgrades)
    (occur "^I")
    (setq package-menu-async t)))

(use-package paren
  :custom (show-paren-delay 0)
  :config (show-paren-mode 1))

(use-package proced
  :custom
  (proced-auto-update-flag t)
  ;; (proced-auto-update-interval 1)
  (proced-tree-flag t)
  (proced-format 'long))

(use-package recentf
  :custom
  (recentf-keep '(file-remote-p file-readable-p))
  (recentf-max-saved-items 20)
  (recentf-exclude '("/elpa/"))
  :config (recentf-mode 1))

(use-package remember
  :preface
  (defun remember-notes-initial-buffer ()
    (if-let ((buf (find-buffer-visiting remember-data-file)))
        ;; If notes are already open, simply return the buffer.  No further
        ;; processing necessary.  This case is needed because with daemon mode,
        ;; ‘initial-buffer-choice’ function can be called multiple times.
        buf
      (if-let ((buf (get-buffer remember-notes-buffer-name)))
          (kill-buffer buf))
      (save-current-buffer
        (remember-notes t)
        (condition-case nil
            (cl-letf (((symbol-function 'yes-or-no-p) (lambda (&rest _) t)))
              (recover-this-file))
          (error)
          (user-error))
        (current-buffer))))
  :custom
  (remember-data-file (expand-file-name ".persistent-scratch" user-emacs-directory))
  (remember-notes-buffer-name "*scratch*")
  (initial-buffer-choice #'remember-notes-initial-buffer))

(use-package savehist
  :custom
  (savehist-additional-variables '(search-ring regexp-search-ring register-alist))
  (history-delete-duplicates t)
  (history-length 999)
  :config (savehist-mode 1))

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
  :when window-system
  :config
  (scroll-bar-mode -1)
  (horizontal-scroll-bar-mode -1))

(use-package simple
  :delight (auto-fill-function)
  :preface
  (defun my/join-line ()
    (interactive)
    (join-line -1))
  :bind (("C-z" . kill-region) ; remapping for azerty
         ("M-z" . kill-ring-save) ; remapping for azerty
         ("M-j" . my/join-line))
  :custom
  (save-interprogram-paste-before-kill t)
  (set-mark-command-repeat-pop t))

(use-package tab-bar
  :bind ("C-x t t" . tab-bar-switch-to-tab)
  :custom
  (tab-bar-close-last-tab-choice 'tab-bar-mode-disable)
  (tab-bar-new-tab-to 'rightmost)
  (tab-bar-close-button-show nil)
  (tab-bar-new-button nil)
  (tab-bar-tab-hints t)
  (tab-bar-tab-name-function 'tab-bar-tab-name-all)
  (tab-bar-show 1)
  :config (tab-bar-mode -1))

(use-package tab-line
  :disabled t
  :custom
  (tab-line-close-tab-function 'kill-buffer)
  (tab-line-exclude-modes '(completion-list-mode
                            speedbar-mode
                            imenu-list-major-mode
                            dired-sidebar-mode))
  :config (global-tab-line-mode 1))

(use-package uniquify
  :custom (uniquify-buffer-name-style 'reverse))

(use-package vc-git
  :preface
  (defun prot-vc-git-grep (regexp)
    "Run 'git grep' for REGEXP in current project.
This is a simple wrapper around `vc-git-grep' to streamline the
basic task of searching for a regexp in the current project.  Use
the original command for its other features."
  (interactive
   (list (read-regexp "git-grep for PATTERN: "
		      nil 'grep-history)))
  (vc-git-grep regexp "*" (prot-vc--current-project)))
  :custom (vc-follow-symlinks t))

(use-package windmove
  :config (windmove-default-keybindings))

(use-package window
  :preface
  (defun my/split-window-below ()
    "Split window horizontally and switch cursor inside it."
    (interactive)
    (split-window-below)
    (other-window 1))

  (defun my/split-window-right ()
    "Split window vetically and switch cursor inside it."
    (interactive)
    (split-window-right)
    (other-window 1))
  :bind (("C-x 2" . my/split-window-below)
         ("C-x 3" . my/split-window-right)))

(use-package winner
  :config (winner-mode 1))

(use-package xt-mouse
  :when (eq window-system nil)
  :config (xterm-mouse-mode 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; THIRD-PARTY PACKAGES ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package aggressive-indent
  :delight
  :ensure t
  :config (global-aggressive-indent-mode 1))

(use-package avy
  :ensure t
  :bind (("C-:" . 'avy-goto-char-2)
         ("C-/" . 'avy-goto-line)))

(use-package company
  :ensure t
  :delight
  :preface
  (defun my/disable-company-mode ()
    (when (eq major-mode 'erc-mode)
      (company-mode -1)))
  :hook (erc-mode . my/disable-company-mode)
  :bind (:map company-active-map
              ("C-n" . company-select-next-or-abort)
              ("C-p" . company-select-previous-or-abort)
              ("<tab>" . company-complete-selection))
  :custom
  (company-idle-delay 0)
  (company-minimum-prefix-length 2)
  (company-format-margin-function #'company-vscode-dark-icons-margin)
  (global-company-mode 1))

(use-package company-box
  :disabled t
  :ensure t
  :after company
  :hook (company-mode . company-box-mode)
  :custom (company-box-scrollbar nil))

(use-package consult
  :ensure t
  :preface
  (defun consult-line-symbol-at-point ()
    "Starts consult-line search with symbol at point"
    (interactive)
    (consult-line (thing-at-point 'symbol)))

  (defun consult-initial-narrow ()
    "Automatically narrows down to ERC buffers when under 'ERC' tab/buffer"
    (when (and (eq this-command #'consult-buffer)
               ;; either we can use narrowing on buffer mode or tab-name detection
               ;; (eq (buffer-local-value 'major-mode (window-buffer (minibuffer-selected-window))) 'erc-mode))
               (string-equal "ERC" (alist-get 'name (alist-get 'current-tab (tab-bar-tabs)))))
      (setq unread-command-events (append unread-command-events (list ?e 32)))))

  (defun my/search-erc-logs-consult ()
    "Lookup for any given term in ERC logs."
    (interactive)
    (consult-grep erc-log-channels-directory))

  (defvar consult--source-erc
    `(:name     "ERC"
                :hidden   t
                :narrow   ?e
                :category buffer
                :state    ,#'consult--buffer-state
                :items    ,(lambda () (mapcar #'buffer-name (erc-buffer-list)))))

  (defvar consult--source-org
    `(:name     "Org"
                :hidden   t
                :narrow   ?o
                :category buffer
                :state    ,#'consult--buffer-state
                :items    ,(lambda () (mapcar #'buffer-name (org-buffer-list)))))

  :hook (minibuffer-setup . consult-initial-narrow)
  :bind (("M-y" . consult-yank)
         ("M-X" . consult-mode-command)
         ("C-s" . consult-line-symbol-at-point)
         ("C-x r b" . consult-bookmark)
         ("C-x b" . consult-buffer)
         ("C-x <tab>" . consult-imenu)
         ("C-x C-r" . consult-recent-file)
         ("C-x m" . consult-global-mark))
  :custom
  (consult-find-args "find .")
  (consult-ripgrep-args "rg --line-buffered --color=never --max-columns=1000\
                         --path-separator / --no-heading --line-number\
                         --follow --hidden --search-zip --smart-case .")
  (consult-preview-key nil)
  (consult-project-root-function
   (lambda ()
     (when-let (project (project-current))
       (car (project-roots project)))))
  :config
  ;; ? to show narrowing keys
  (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; customizing built-in sources
  (consult-customize
   consult--source-buffer
   :narrow ?m

   consult--source-file
   :name "Recent file"
   :hidden t
   :narrow ?r

   consult--source-bookmark
   :hidden t
   :narrow ?b)

  ;; Org buffers source narrowing
  (autoload 'org-buffer-list "org")
  (add-to-list 'consult-buffer-sources 'consult--source-org 'append)

  ;; ERC buffers source narrowing
  (autoload 'erc-buffer-list "erc")
  (add-to-list 'consult-buffer-sources 'consult--source-erc 'append))

(use-package delight
  :ensure t)

(use-package diff-hl
  :ensure t
  ;; :after vc
  :hook ((dired-mode . diff-hl-dired-mode)
         (magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh-hook . diff-hl-magit-post-refresh))
  :config
  ;; to use in emacs terminal if fringe doesnt work
  ;; (diff-hl-margin-mode)
  ;; (diff-hl-flydiff-mode 1)
  (diff-hl-dired-mode 1)
  (global-diff-hl-mode 1))

(use-package dired-git-info
  :ensure t
  :after dired
  :custom (dgi-auto-hide-details-p nil)
  :hook (dired-after-readin . dired-git-info-auto-enable))

(use-package diredfl
  :ensure t
  :after dired
  :config (diredfl-global-mode 1))

(use-package dired-subtree
  :ensure t
  :bind ((:map dired-mode-map ("<tab>" . #'dired-subtree-toggle))))

(use-package drag-stuff
  :ensure t
  :delight
  :bind (("M-p" . drag-stuff-up)
         ("M-n" . drag-stuff-down))
  :config (drag-stuff-global-mode 1))

(use-package embark-consult
  :ensure t
  :bind ("C-;" . embark-act)
  :custom (prefix-help-command #'embark-prefix-help-command))

(use-package elfeed
  :disabled t
  :ensure t
  :defer t
  :preface
  (defun my/elfeed ()
    "Creates a new tab and starts Elfeed."
    (interactive)
    (if (get-buffer "*elfeed-search*")
        (tab-bar-switch-to-tab "Elfeed")
      (tab-new)
      (tab-rename "Elfeed")
      (elfeed-update)
      (elfeed)))
  :custom
  (elfeed-db-directory (expand-file-name "elfeed" user-emacs-directory))
  (elfeed-search-date-format '("%d.%m.%y" 10 :left))
  :config
  (load-file (expand-file-name "feeds.el" user-emacs-directory)))

(use-package engine-mode :ensure t)

(use-package erc-hl-nicks
  :ensure t
  :after erc
  :config (add-to-list 'erc-hl-nicks-skip-faces "erc-current-nick-face" t))

(use-package erc-status-sidebar ; built in Emacs 28 (removed from Melpa...)
  :disabled t
  :ensure t
  :after erc
  :preface
  (defun my/erc-window-reuse-condition (buf-name action)
    (with-current-buffer buf-name
      (if (eq major-mode 'erc-mode)
          ;; Don't override an explicit action
          (not action))))
  :hook (erc-mode . erc-status-sidebar-open)
  :config
  (add-to-list 'display-buffer-alist
               '(my/erc-window-reuse-condition .
                                               (display-buffer-reuse-mode-window
                                                (inhibit-same-window . t)
                                                (inhibit-switch-frame . t)
                                                (mode . erc-mode))))
  ;; this also adds irc servers name and queries to the sidebar
  ;; related: https://github.com/drewbarbs/erc-status-sidebar/issues/1
  (defun erc-status-sidebar-refresh ()
    "Update the content of the sidebar."
    (interactive)
    (let ((chanlist (apply
                     erc-status-sidebar-channel-sort
                     (erc-buffer-list nil) nil)))
      (with-current-buffer (erc-status-sidebar-get-buffer)
        (erc-status-sidebar-writable
         (delete-region (point-min) (point-max))
         (goto-char (point-min))
         (dolist (chanbuf chanlist)
           (let* ((tup (seq-find (lambda (tup) (eq (car tup) chanbuf))
                                 erc-modified-channels-alist))
                  (count (if tup (cadr tup)))
                  (face (if tup (cddr tup)))
                  (channame (apply erc-status-sidebar-channel-format
                                   (buffer-name chanbuf) count face nil))
                  (cnlen (length channame)))
             (put-text-property 0 cnlen 'erc-buf chanbuf channame)
             (put-text-property 0 cnlen 'mouse-face 'highlight channame)
             (put-text-property
              0 cnlen 'help-echo
              "mouse-1: switch to buffer in other window" channame)
             (insert channame "\n"))))))))

(use-package evil
  :disabled t
  :ensure t
  :bind ((:map evil-insert-state-map
               ("C-g" . 'evil-force-normal-state))
         (:map evil-visual-state-map
               ("C-g" . 'evil-force-normal-state))
         (:map evil-replace-state-map
               ("C-g" . 'evil-force-normal-state)))
  :custom (evil-disable-insert-state-bindings t) ; enables emacs bindings in insert mode
  :config (evil-mode 1))

(use-package exec-path-from-shell
  :when (memq window-system '(mac ns x))
  :ensure t
  :init (setq exec-path-from-shell-arguments '("-l"))
  :config (exec-path-from-shell-initialize))

(use-package expand-region
  :ensure t
  :bind (("C-=" . er/expand-region)
         ("C--" . er/contract-region)))

(use-package fd-dired
  :ensure t
  :init
  (when (string-equal system-type 'darwin)
    (setq fd-dired-ls-option '(" | xargs -0 ls -ld | uniq" . "-ld")))
  :custom (fd-dired-pre-fd-args "-0 --color=never --hidden"))

(use-package flymake-shellcheck
  :ensure t
  :after flymake
  :commands flymake-shellcheck-load
  :init (add-hook 'sh-mode-hook 'flymake-shellcheck-load))

(use-package lsp-mode
  :disabled t
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (((python-mode sh-mode powershell-mode) . lsp-deferred)
         (lsp-mode . lsp-enable-which-key-integration))
  :custom
  (lsp-keymap-prefix "C-c l")
  (lsp-modeline-diagnostics-enable nil))

(use-package lsp-ui
  :disabled t
  :ensure t)
;; :after lsp-mode)

(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)))

(use-package marginalia
  :ensure t
  :custom (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :config (marginalia-mode 1))

(use-package modus-themes ; built in Emacs 28
  :ensure t
  :demand t
  :custom
  (modus-themes-bold-constructs t)
  (modus-themes-completions 'opinionated)
  (modus-themes-fringes 'subtle)
  (modus-themes-mode-line '3d)
  (modus-themes-paren-match 'intense-bold)
  (modus-themes-region 'no-extend)
  (modus-themes-slanted-constructs t)
  (modus-themes-syntax 'alt-syntax-yellow-comments)
  ;;; org-related
  (modus-themes-headings
   '((1 . section)
     (t . rainbow-highlight)))
  ;; modus-themes-no-mixed-fonts nil
  (modus-themes-org-blocks 'grayscale)
  (modus-themes-scale-headings t)
  (modus-themes-variable-pitch-headings t)
  :config (modus-themes-load-vivendi))

(use-package multiple-cursors
  :ensure t
  ;; C-' to hide unmatched lines
  :bind (("C-c m c" . mc/edit-lines)
         ("C-c m d" . mc/mark-all-dwim)
         ("C-)" . mc/mark-next-like-this) ; to be used after er/expand-region (C-=)
         ("C-c m a" . mc/mark-all-words-like-this)))

(use-package orderless
  :ensure t
  :custom
  (completion-category-defaults nil)
  (completion-styles '(orderless)))

(use-package powershell :ensure t)

(use-package project ; built in Emacs 28
  :ensure t
  :preface
  (cl-defmethod project-root ((project (head local)))
    "Return root directory of current PROJECT."
    (cdr project))

  (defun my/project-try-local (dir)
    "Determine if DIR is a non-VC project.
DIR must include a .project file to be considered a project."
    (if-let ((root (locate-dominating-file dir ".project")))
        (cons 'local root)))

  (defun project/find-name-dired (pattern)
    (interactive
     "sFind-name (filename wildcard): ")
    (let* ((pr (project-current t))
           (dir (cdr pr)))
      (find-dired dir (concat find-name-arg " " (shell-quote-argument pattern)))))

  (defun project/fd-name-dired (pattern)
    (interactive
     "sFd-name (filename regexp): ")
    (let* ((pr (project-current t))
           (dir (cdr pr)))
      (fd-dired dir (shell-quote-argument pattern))))

  (defun project/magit-status ()
    "Run `magit-status' on project."
    (interactive)
    (let* ((pr (project-current t))
           (dir (cdr pr)))
      (magit-status dir)))
  :custom
  (project-switch-commands
   '((project-find-file "Find file")
     (consult-find "consult-find" ?F)
     (project/find-name-dired "find-n-d" ?n)
     (project/fd-name-dired "fd-n-d" ?N)
     (consult-grep "grep" ?g)
     (consult-ripgrep "rg" ?r)
     (consult-git-grep "git-grep" ?G)
     (project-dired "Dired")
     (project/magit-status "Magit" ?m)))
  :config
  (add-hook 'project-find-functions 'my/project-try-local 90))

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package rg
  :disabled t
  :ensure t
  :preface
  (rg-define-search my/rg-search-project
                    "Search in project."
                    :files "everything"
                    :dir default-directory)
  (rg-define-search my/rg-search-erc-logs
                    "Search in ERC logs using ripgrep."
                    :files "everything"
                    :dir erc-log-channels-directory)
  :bind (:map rg-mode-map
              ("M-n" . rg-next-file)
              ("M-p" . rg-prev-file))
  :custom
  (rg-custom-type-aliases nil)
  (rg-command-line-flags '("--follow" "--hidden" "--search-zip"))
  (rg-default-alias-fallback "everything")
  :config (rg-enable-default-bindings))

(use-package vertico
  :ensure t
  :custom
  (vertico-group-format nil)
  ;; (vertico-resize t)
  :config (vertico-mode 1))

(use-package vterm
  :when (not (string-equal system-type 'windows-nt))
  :ensure t)

(use-package transmission
  :ensure t
  :custom
  (transmission-refresh-interval 1)
  (transmission-refresh-modes
   '(transmission-mode
     transmission-files-mode
     transmission-info-mode
     transmission-peers-mode))
  (transmission-geoip-function 'transmission-geoiplookup))

;;; init.el ends here
