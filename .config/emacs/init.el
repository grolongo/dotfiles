;;; init.el --- -*- lexical-binding: t; -*-

;;; Commentary:
;; Emacs startup file

;;; Code:

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

;;;;;;;;;;;;;;;;;;;;;;;;
;;; GENERAL SETTINGS ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

(keymap-global-set "C-a" '("beginning-of-indent-or-line" .
                           (lambda () (interactive)
                             (let ((pos (current-column)))
                               (back-to-indentation)
                               (when (and (not (= 0 pos))
                                          (<= pos (current-column)))
                                 (beginning-of-line))))))

(setopt auto-save-no-message t
        auto-save-list-file-prefix (expand-file-name "auto-saves/.saves-" user-emacs-directory)
        delete-by-moving-to-trash t
        fill-column 80
        indicate-buffer-boundaries 'left
        indicate-empty-lines t
        load-prefer-newer t
        mode-line-compact 'long
        mode-line-position-column-line-format '(" (L%l C%c)")
        ring-bell-function 'ignore
        select-active-regions nil ;; fix for copying to clipboard in wayland
        scroll-conservatively most-positive-fixnum
        sentence-end-double-space nil
        tab-always-indent 'complete
        tab-width 4
        use-short-answers t
        w32-follow-system-dark-mode nil)

;; make C-x C-u and C-x C-l available
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

;; Add prompt indicator to `completing-read-multiple'
(defun crm-indicator (args)
  (cons (format "[CRM%s] %s"
                (replace-regexp-in-string
                 "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                 crm-separator)
                (car args))
        (cdr args)))
(advice-add #'completing-read-multiple :filter-args #'crm-indicator)

;; Enable hyper & super keys
(cond ((eq system-type 'windows-nt)
       ;; right Windows key for hyper
       (setq w32-pass-rwindow-to-system nil)
       (setq w32-rwindow-modifier 'hyper)
       (w32-register-hot-key [H-]))
      ;; left Windows key for super
      ;; (setq w32-pass-lwindow-to-system nil)
      ;; (setq w32-lwindow-modifier 'super)
      ;; (w32-register-hot-key [s-]))
      ((eq system-type 'darwin)
       ;; left alt for super
       (setq mac-option-modifier 'super)
       ;; disable right alt for special chars
       (setq mac-right-option-modifier 'nil)
       ;; right command for hyper
       (setq mac-right-command-modifier 'hyper)))

;;;;;;;;;;;;;;;;;;;;
;;; MODUS-THEMES ;;;
;;;;;;;;;;;;;;;;;;;;

(require-theme 'modus-themes)

(setopt modus-themes-variable-pitch-ui t
        modus-themes-bold-constructs t
        modus-themes-italic-constructs t
        ;;; org-related
        modus-themes-mixed-fonts t
        modus-themes-org-blocks 'gray-background
        modus-themes-common-palette-overrides '(;; borderless mode line
                                                (border-mode-line-active bg-mode-line-active)
                                                (border-mode-line-inactive bg-mode-line-inactive)
                                                ;; purple parens
                                                (bg-paren-match bg-magenta-intense)
                                                ;; org
                                                (prose-todo "medium blue")
                                                ;; (fg-heading-1 "blue1")
                                                (fg-heading-2 "sienna")
                                                (fg-heading-3 "Purple")
                                                (fg-heading-4 "Firebrick")
                                                (fg-heading-5 "ForestGreen")
                                                (fg-heading-6 "dark cyan")))

;; (bg-heading-1 "#E5E4E2")
;; (bg-heading-2 bg-yellow-nuanced)
;; (bg-heading-3 bg-blue-nuanced)
;; (bg-heading-4 bg-magenta-nuanced)
;; (bg-heading-5 bg-green-nuanced)
;; (bg-heading-6 bg-red-nuanced))

(modus-themes-load-theme 'modus-operandi-tinted)

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

(defun tabbar-name-check ()
  "Return the name of the current tab-bar."
  (if tab-bar-mode
      (format "[%s]  " (cdr (assq 'name (tab-bar--current-tab))))
    ""))

(defvar-local mode-line-tabgroup
    '((:eval
       (propertize (tabbar-name-check) 'face 'mode-line-emphasis
                   'mouse-face 'mode-line-highlight
                   'local-map (purecopy (make-mode-line-mouse-map
                                         'mouse-1 #'tab-bar-switch-to-next-tab
                                         ))))))

(put 'mode-line-tabgroup 'risky-local-variable t)

;;; mode-line construct
(setopt mode-line-format '("%e" mode-line-front-space
                           ;; mode-line-tabgroup
                           (:propertize
                            (""
                             mode-line-mule-info
                             mode-line-client
                             mode-line-modified
                             mode-line-remote)
                            display
                            (min-width
                             (5.0)))
                           mode-line-frame-identification
                           mode-line-buffer-identification
                           "   "
                           mode-line-position
                           (project-mode-line project-mode-line-format)
                           (vc-mode vc-mode)
                           "  "
                           mode-line-modes
                           mode-line-misc-info
                           mode-line-end-spaces))

;;;;;;;;;;;;;;;;;;;;;;;;;
;;; BUILT-IN PACKAGES ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package abbrev
  :demand t
  :delight
  :custom
  (save-abbrevs nil)
  (abbrev-file-name (expand-file-name "templates/abbrevs.el" user-emacs-directory))
  :config
  (read-abbrev-file (expand-file-name "templates/abbrevs.el" user-emacs-directory))
  (setq-default abbrev-mode t))

(use-package auth-source
  :demand t
  :preface
  ;; this avoids having your copied password going into the kill-ring
  (define-advice read-passwd (:around (&rest args) my-inhibit-kill-ring)
    "Avoid modifying `kill-ring' in `read-passwd'."
    (let ((kill-ring kill-ring))
      (apply args)))
  :custom
  ;; (auth-source-debug t)
  (auth-source-save-behavior nil)
  (auth-sources (list (expand-file-name "authinfo.gpg" user-emacs-directory)))
  :config (auth-source-forget-all-cached))

(use-package autoinsert
  :demand t
  :preface
  (defun autoinsert-yas-expand ()
    "Replace text in yasnippet template."
    (yas-expand-snippet (buffer-string) (point-min) (point-max)))
  :custom
  (auto-insert-query nil)
  (auto-insert-directory (expand-file-name "templates/autoinsert" user-emacs-directory))
  :config
  (define-auto-insert "\\.el$" ["elisp-template.el" autoinsert-yas-expand])
  (define-auto-insert "\\.ps1$" ["powershell-template.ps1" autoinsert-yas-expand])
  (define-auto-insert "\\.sh$" ["shell-template.sh" autoinsert-yas-expand])
  (define-auto-insert "\\.py$" ["python-template.py" autoinsert-yas-expand])
  (auto-insert-mode t))

(use-package autorevert
  :demand t
  :custom
  (auto-revert-verbose t)
  (auto-revert-check-vc-info t)
  (global-auto-revert-non-file-buffers t)
  :config (global-auto-revert-mode t))

;; (use-package bindings
;;   ;; :demand t
;;   :custom (setopt mode-line-position-column-line-format '(" (L%l,C%c)")))

(use-package bookmark
  :demand t
  :custom (bookmark-fringe-mark 'bookmark-mark))

(use-package completion-preview
  :disabled t
  :demand t
  :hook ((org-mode-hook prog-mode-hook) . completion-preview-mode)
  :bind (:map completion-preview-active-mode-map
              ("C-n" . completion-preview-next-candidate)
              ("C-p" . completion-preview-prev-candidate)))

(use-package cus-edit
  :demand t
  :custom
  (custom-raised-buttons t)
  ;; disabling custom entirely
  (custom-file (make-temp-file "emacs-custom")))
;; this is if I want to enable custom again:
;; (custom-file (expand-file-name "custom.el" user-emacs-directory))
;; :config
;; (when (file-exists-p custom-file)
;;   (load custom-file)))

(use-package delsel
  :demand t
  :config (delete-selection-mode 1))

(use-package desktop
  :demand t
  ;; :hook (server-after-make-frame-hook . desktop-read)
  :custom
  (desktop-dirname (expand-file-name user-emacs-directory))
  (desktop-load-locked-desktop t)
  ;; (desktop-save 'ask-if-new)
  :config (desktop-save-mode -1))

(use-package dired
  :demand t
  :preface
  (defun check-files-extension (&rest allowed-extensions)
    "Return the different extension(s) of marked files in Dired.
Check if the marked files have extensions not included in the ALLOWED-EXTENSIONS list."
    (let ((extensions nil)
          (invalid-extensions nil)
          (marked-files (dired-get-marked-files 'verbatim nil nil nil t)))
      (dolist (file marked-files)
        (let ((extension (file-name-extension file)))
          (unless (member extension extensions)
            (setq extensions (cons extension extensions)))))

      ;; Check for invalid extensions
      (dolist (ext extensions)
        (unless (member ext allowed-extensions)
          (push ext invalid-extensions)))

      invalid-extensions))

  (defun ffmpeg-fileslist-gen ()
    "Generate fileslist.txt for `ffmpeg`.
FFmpeg doesn't allow multiple files at once."
    (let ((marked-files (dired-get-marked-files 'verbatim nil nil nil t)))
      (with-temp-file "fileslist.txt"
        (dolist (file marked-files)
          (princ (concat "file '" file "'\n") (current-buffer))))))

  (defun ffmpeg-concatenate-videofiles ()
    "Concatenate video files with `ffmpeg`.
FFmpeg doesn't allow multiple files at once."
    (interactive)
    (if (not (check-files-extension "mp4" "webm" "mkv" "ts"))
        (progn
          (ffmpeg-fileslist-gen)
          (call-process "ffmpeg" nil nil nil "-f" "concat" "-safe" "0" "-i" "fileslist.txt" "-c" "copy" "output.mp4")
          (delete-file "fileslist.txt"))
      (error "You have incompatible file(s) marked for this command")))

  (defun ffmpeg-extract-frame ()
    "Extract single frame from video file with `ffmpeg`
FFmpeg doesn't allow multiple files at once."
    (interactive)
    (if (not (check-files-extension "mp4" "webm" "mkv"))
        (progn
          (let ((marked-files (dired-get-marked-files 'verbatim nil nil nil t)))
            (dolist (file marked-files)
              (let ((output-file (concat (file-name-sans-extension file) "-frame.png"))
                    (timeframe (read-string (format "Timestamp for %s in HH:MM:SS: " file))))
                (start-process "ffmpeg" "*ffmpeg*" "ffmpeg" "-ss" timeframe "-i" file "-vframes:v" "1" output-file)))))
      (error "You have incompatible file(s) marked for this command")))

  (defun ffmpeg-remove-metadata ()
    "Remove metadata from video file.
FFmpeg doesn't allow multiple files at once, so we run the
command multiple times."
    (interactive)
    (if (not (check-files-extension "mp4" "webm" "mkv"))
        (let ((marked-files (dired-get-marked-files 'verbatim nil nil nil t)))
          (dolist (file marked-files)
            (let ((output-file (concat (file-name-sans-extension file) "-nometa." (file-name-extension file))))
              (start-process "ffmpeg" "*ffmpeg*" "ffmpeg" "-i" file "-vcodec" "copy" "-acodec" "copy" "-map" "0" "-map_metadata" "-1" output-file))))
      (error "You have incompatible file(s) marked for this command")))

  (defun ffmpeg-remove-audio ()
    "Removed audio from video files.
FFmpeg doesn't allow multiple files at once, so we run the
command multiple times."
    (interactive)
    (if (not (check-files-extension "mp4" "webm" "mkv"))
        (let ((marked-files (dired-get-marked-files 'verbatim nil nil nil t)))
          (dolist (file marked-files)
            (let ((output-file (concat (file-name-sans-extension file) "-noaudio." (file-name-extension file))))
              (start-process "ffmeg" "*ffmpeg*" "ffmpeg" "-i" file "-vcodec" "copy" "-an" output-file))))
      (error "You have incompatible file(s) marked for this command")))

  (defun ffmpeg-trim-video ()
    "Trim video file according to START and END using `FFmpeg`."
    (interactive)
    (if (not (check-files-extension "mp4" "webm" "mkv"))
        (let* ((marked-file (car (dired-get-marked-files 'verbatim nil nil nil t)))
               (output-file (concat (file-name-sans-extension marked-file) "-trimmed." (file-name-extension marked-file)))
               (starttime (read-string (format "Starttime for %s in HH:MM:SS: " marked-file)))
               (stoptime (read-string (format "Stoptime for %s in HH:MM:SS: " marked-file))))
          ;; (call-process "ffmpeg" nil nil nil "-ss" starttime "-to" stoptime "-i" marked-file "-vcodec" "copy" "-acodec" "copy" output-file)
          (start-process "ffmpeg" "*ffmpeg*" "ffmpeg" "-ss" starttime "-to" stoptime "-i" marked-file "-vcodec" "copy" "-acodec" "copy" output-file))
      (error "You have incompatible file(s) marked for this command")))

  (defun ffmpeg-flip-video ()
    "Flip video horizontally using `FFmpeg`.
FFmpeg doesn't allow multiple files at once, so we run the
command multiple times."
    (interactive)
    (if (not (check-files-extension "mp4" "webm" "mkv"))
        (let ((marked-files (dired-get-marked-files 'verbatim nil nil nil t)))
          (dolist (file marked-files)
            (let ((output-file (concat (file-name-sans-extension file) "-flipped." (file-name-extension file))))
              (start-process "ffmpeg" "*ffmpeg*" "ffmpeg" "-i" file "-vf" "hflip" "-c:a" "copy" output-file))))
      (error "You have incompatible file(s) marked for this command")))

  (defun ffmpeg-merge-audiovideo ()
    "Concatenate audio and video file together using `FFmpeg`."
    (interactive)
    (if (not (check-files-extension "mp4" "mp3"))
        (let* ((marked-files (dired-get-marked-files 'verbatim nil nil nil t))
               (video-file (seq-find (lambda (file) (string-match-p "\\.mp4\\'" file)) marked-files))
               (audio-file (seq-find (lambda (file) (string-match-p "\\.mp3\\'" file)) marked-files))
               (output-file (concat (file-name-sans-extension video-file) "-merge." (file-name-extension video-file))))
          (start-process "ffmpeg" "*ffmpeg*" "ffmpeg" "-i" video-file "-stream_loop" "-1" "-i" audio-file "-c:v" "copy" "-shortest" "-fflags" "+shortest""-max_interleave_delta" "100M" output-file))
      (error "You have incompatible file(s) marked for this command")))

  (defun ffmpeg-x265-convert ()
    "Converts specified formats to x265 to save some space."
    (interactive)
    (if (not (check-files-extension "mkv" "ts" "avi" "flv" "mp4"))
        (let ((marked-files (dired-get-marked-files 'verbatim nil nil nil t)))
          (dolist (file marked-files)
            (let ((output-file (concat (file-name-sans-extension file) ".mp4")))
              (start-process "ffmpeg" "*ffmpeg*" "ffmpeg" "-i" file "-vcodec" "libx265" "-crf" "28" output-file))))
      (error "You have incompatible file(s) marked for this command")))

  (defun ffmpeg-ts-convert ()
    "Converts ts format to mp4 with timestamps mapping."
    (interactive)
    (if (not (check-files-extension "ts"))
        (let ((marked-files (dired-get-marked-files 'verbatim nil nil nil t)))
          (dolist (file marked-files)
            (let ((output-file (concat (file-name-sans-extension file) ".mp4")))
              (start-process "ffmpeg" "*ffmpeg*" "ffmpeg" "-i" file "-map" "0" "-map" "-0:d" "-c" "copy" output-file))))
      (error "You have incompatible file(s) marked for this command")))

  (defun ffmpeg-scale-half ()
    "Scale down video file resolution to half."
    (interactive)
    (if (not (check-files-extension "ts" "avi" "flv" "mp4" "webm" "mkv" "gif"))
        (let ((marked-files (dired-get-marked-files 'verbatim nil nil nil t)))
          (dolist (file marked-files)
            (let ((output-file (concat (file-name-sans-extension file) "-halved." (file-name-extension file))))
              (start-process "ffmpeg" "*ffmpeg*" "ffmpeg" "-i" file "-vf" "scale=trunc(iw/4)*2:trunc(ih/4)*2" output-file))))
      (error "You have incompatible file(s) marked for this command")))

  (defun ffmpeg-scale-third ()
    "Scale down video file resolution to half."
    (interactive)
    (if (not (check-files-extension "ts" "avi" "flv" "mp4" "webm" "mkv" "gif"))
        (let ((marked-files (dired-get-marked-files 'verbatim nil nil nil t)))
          (dolist (file marked-files)
            (let ((output-file (concat (file-name-sans-extension file) "-thirded." (file-name-extension file))))
              (start-process "ffmpeg" "*ffmpeg*" "ffmpeg" "-i" file "-vf" "scale=trunc(iw/6)*2:trunc(ih/6)*2" output-file))))
      (error "You have incompatible file(s) marked for this command")))

  (defun ffmpeg-upscale ()
    "Upscale video to 60 fps."
    (interactive)
    (if (not (check-files-extension "ts" "avi" "flv" "mp4" "webm" "mkv" "gif"))
        (let ((marked-files (dired-get-marked-files 'verbatim nil nil nil t)))
          (dolist (file marked-files)
            (let ((output-file (concat (file-name-sans-extension file) "-upscaled." (file-name-extension file))))
              (start-process "ffmpeg" "*ffmpeg*" "ffmpeg" "-i" file "-vf" "minterpolate=fps=60:mi_mode=mci:mc_mode=aobmc:me_mode=bidir:vsbmc=1" output-file))))
      (error "You have incompatible file(s) marked for this command")))

  (defun mkvmerge-rm-subtitles ()
    "Uses `MKVToolNix` to remove subtitles from mkv video file."
    (interactive)
    (if (not (check-files-extension "mkv"))
        (let* ((marked-file (car (dired-get-marked-files 'verbatim nil nil nil t)))
               (output-file (concat (file-name-sans-extension marked-file) "-resub.mkv")))
          (if (y-or-n-p "Remove ALL subtitles? ")
              (start-process "mkvmerge" "*mkvmerge*" "mkvmerge" "-o" output-file "--no-subtitles" marked-file)
            (let ((tracks (read-string (format "List of subs (separated by a comma): "))))
              (start-process "mkvmerge" "*mkvmerge*" "mkvmerge" "-o" output-file "--subtitle-tracks" tracks marked-file))))
      (error "You have incompatible file(s) marked for this command")))

  (defun mkvmerge-rm-audiotracks ()
    "Uses `MKVToolNix` to select specific audio tracks to create a new mkv video file."
    (interactive)
    (if (not (check-files-extension "mkv"))
        (let* ((marked-file (car (dired-get-marked-files 'verbatim nil nil nil t)))
               (output-file (concat (file-name-sans-extension marked-file) "-new-audio.mkv"))
               (tracks (read-string (format "List of tracks to remove (separated by a comma): "))))
          (start-process "mkvmerge" "*mkvmerge*" "mkvmerge" "-o" output-file "--audio-tracks" tracks marked-file))
      (error "You have incompatible file(s) marked for this command")))

  (defun magick-flip-image ()
    "Flip marked image files using `magick`.
  Magick allows to process multiple files at once."
    (interactive)
    (if (not (check-files-extension "jpg" "jpeg" "webp" "png"))
        (let ((marked-files (dired-get-marked-files 'verbatim nil nil nil t)))
          (apply #'start-process "magick" "*magick*" "mogrify" "-flop" marked-files))
      (error "You have incompatible file(s) marked for this command")))

  (defun magick-convert-to-jpg ()
    "Convert image file to jpg format with `magick`.
  Magick allows to process multiple files at once."
    (interactive)
    (if (not (check-files-extension "avif" "webp" "png" "jpeg"))
        (let ((marked-files (dired-get-marked-files 'verbatim nil nil nil t)))
          (apply #'start-process "magick" "*magick*" "magick" "mogrify" "-format" "jpg" marked-files))
      (error "You have incompatible file(s) marked for this command")))

  (defun exiftool-remove-exif ()
    "Remove exif data with `exiftool`.
  Exiftool allows to process multiple files at once.
ExifTool can remove metadata from both images, documents and video files."
    (interactive)
    (let ((marked-files (dired-get-marked-files 'verbatim nil nil nil t)))
      (apply #'start-process "exiftool" "*exiftool*" "exiftool" "-overwrite_original" "-all=" marked-files)))

  (defun random-rename-files ()
    "Rename all marked files with a name of random numbers and letters."
    (interactive)
    (let* ((marked-files (dired-get-marked-files 'verbatim nil nil nil t))
           (chars "abcdefghijklmnopqrstuvwxyz0123456789")
           (len 12))
      (dolist (file marked-files)
        (when (file-regular-p file)
          (let* ((ext (file-name-extension file t))
                 new-name new-path)
            (while
                (progn
                  (setq new-name
                        (concat
                         (apply #'string
                                (cl-loop repeat len
                                         collect (elt chars (random (length chars)))))
                         ext))
                  (setq new-path (expand-file-name new-name (file-name-directory file)))
                  (file-exists-p new-path)))
            (rename-file file new-path))))))

  ;; :hook (dired-mode-hook . dired-hide-details-mode)
  :bind ((:map dired-mode-map
               ([remap dired-prev-dirline] . dired-up-directory)))
  :custom
  (dired-dwim-target t)
  (dired-kill-when-opening-new-dired-buffer t)
  ;; -v = natural numeric order, -X = sort by extension, can't use both
  (dired-listing-switches "-Alh1XF --group-directories-first")
  (dired-use-ls-dired t)
  (dired-free-space 'separate)
  (dired-movement-style 'cycle)
  (dired-filename-display-length 'window)
  (dired-recursive-copies 'always)
  (dired-recursive-deletes 'always)
  :config
  (when (string-equal system-type 'darwin)
    (setopt ls-lisp-use-insert-directory-program nil))
  (put 'dired-find-alternate-file 'disabled nil))

(use-package dired-aux
  :demand t
  :custom
  (dired-create-destination-dirs 'ask)
  (dired-create-destination-dirs-on-trailing-dirsep t))

(use-package eglot
  :demand t
  :hook (powershell-mode-hook . eglot-ensure))

(use-package eldoc
  :demand t
  :delight
  :preface
  (defun my/eldoc-list ()
    "Show flymake diagnostics first."
    (setq eldoc-documentation-functions
          (cons #'flymake-eldoc-function
                (remove #'flymake-eldoc-function eldoc-documentation-functions))))
  :hook (eldoc-mode-hook . my/eldoc-list)
  :custom
  (eldoc-echo-area-display-truncation-message nil)
  (eldoc-idle-delay 0.1))

(use-package electric
  :demand t
  :preface
  (defun my/disable-electric-indent ()
    "Disable electric everywhere aggressive-indent is
enabled. Ignored modes for aggressive-indent are listed in
aggressive-indent-excluded-modes."
    (when (bound-and-true-p aggressive-indent-mode)
      (electric-indent-local-mode -1)))
  :hook ((org-mode-hook . electric-quote-local-mode)
         (after-change-major-mode-hook . my/disable-electric-indent))
  :custom
  (electric-quote-context-sensitive nil)
  (electric-quote-paragraph t)
  (electric-quote-comment nil)
  (electric-quote-string nil)
  (electric-quote-replace-double t)
  :config (electric-quote-mode -1))

(use-package elec-pair
  :demand t
  :preface
  (defun my/disable-elec-pair ()
    "Disable elec-pair everywhere paredit is enabled."
    (when (bound-and-true-p paredit-mode)
      (electric-pair-local-mode -1)))
  :hook (after-change-major-mode-hook . my/disable-elec-pair)
  :custom (electric-pair-skip-self nil)
  :config (electric-pair-mode 1))

(use-package eshell
  :defer 1 ;; necessary for prompt colors
  :preface
  ;; using custom functions for mv and cp to add flags as it doesn't work in the alias file
  ;; see https://old.reddit.com/r/emacs/comments/xs2ofo/eshell_aliases_for_mv_and_cp_using_their_elisp/
  (defun my/mv (&rest args)
    (let ((x (append (list "--interactive" "--verbose") (elt args 0))))
      (apply #'eshell/mv x)))
  (defun my/cp (&rest args)
    (let ((x (append (list "--interactive" "--preserve" "--recursive" "--verbose") (elt args 0))))
      (apply #'eshell/cp x)))
  :custom
  (eshell-bad-command-tolerance 9999)
  (eshell-hist-ignoredups t)
  ;; (eshell-prompt-regexp "^[^#$\n]*[#>] ")
  :config
  (cond ((memq 'modus-vivendi custom-enabled-themes)
         (setopt eshell-prompt-function
                 (lambda ()
                   (concat
                    ;; (propertize (user-login-name) 'face `(:foreground "green"))
                    ;; (propertize "@" 'face `(:foreground "white"))
                    ;; (propertize (system-name) 'face `(:foreground "green"))
                    ;; " "
                    (propertize (eshell/pwd) 'face `(:foreground "#CF9FFF"))
                    (propertize (if (= (user-uid) 0) " # " " $ ") 'face `(:foreground "white"))))))
        ((memq 'modus-operandi custom-enabled-themes)
         (setopt eshell-prompt-function
                 (lambda ()
                   (concat
                    ;; (propertize (user-login-name) 'face `(:foreground "chartreuse4"))
                    ;; (propertize "@" 'face `(:foreground "black"))
                    ;; (propertize (system-name) 'face `(:foreground "chartreuse4"))
                    ;; " "
                    (propertize (eshell/pwd) 'face `(:foreground "#8000FF"))
                    (propertize (if (= (user-uid) 0) " # " " $ ") 'face `(:foreground "black"))))))))

(use-package erc
  :demand t
  :preface
  ;; let query buffers tracked as if everything contains our current nick,
  ;; better reflecting the urgency of a private message.
  (defadvice erc-track-find-face (around erc-track-find-face-promote-query activate)
    (if (erc-query-buffer-p)
        (setq ad-return-value (intern "erc-current-nick-face"))
      ad-do-it))

  (define-minor-mode erc-count-users-mode
    "Shows total number of (ops/voice/regular) users in the modeline."
    :global nil
    :lighter (:eval
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

  (defun my/libera-connect ()
    "Creates tab and connects using TLS to Libera IRC server."
    (interactive)
    (if (get-buffer "Libera.Chat")
        (progn
          (pop-to-buffer-same-window "Libera.Chat")
          (delete-other-windows)
          (message "already connected to Libera Chat."))
      (erc-tls :server "irc.libera.chat" :port 6697 :nick "grolongo")
      (sit-for 2)
      (pop-to-buffer-same-window "Libera.Chat")))

  (defun my/oftc-connect ()
    ;; as of 20/04/21 OFTC doesn't allow automatic authentication
    ;; with user/password mechanism so we must
    ;; /msg nickserv identify <password> to auth.
    ;; using CertFP is a solution for automatic auth but setting it
    ;; in Emacs is a pain.
    "Creates tab and connects using TLS credentials for OFTC."
    (interactive)
    (if (get-buffer "OFTC")
        (progn
          (pop-to-buffer-same-window "OFTC")
          (delete-other-windows)
          (message "already connected to OFTC."))
      (erc-tls :server "irc.oftc.net" :port 6697 :nick "grolongo")
      (sit-for 2)
      (pop-to-buffer-same-window "OFTC")))

  (defun my/quit-if-erc-tab (&rest _args)
    (when (tab-bar--tab-index-by-name "ERC")
      (tab-bar-close-tab-by-name "ERC")))
  :hook ((erc-quit-hook . my/quit-if-erc-tab)
         (erc-mode-hook . erc-log-mode)
         (erc-join-hook . erc-count-users-mode))
  :custom-face (erc-current-nick-face ((t (:foreground "red" :weight bold))))
  :custom
  (erc-kill-buffer-on-part t)
  (erc-kill-queries-on-quit t)
  (erc-kill-server-buffer-on-quit t)
  ;; display
  (erc-header-line-uses-tabbar-p t) ; so it doesn't hide tabbar
  (erc-hide-list '("353"))
  (erc-timestamp-only-if-changed-flag nil)
  (erc-timestamp-format "%H:%M")
  (erc-insert-timestamp-function 'erc-insert-timestamp-left)
  (erc-lurker-hide-list '("JOIN" "PART" "QUIT"))
  (erc-lurker-threshold-time 43200)
  (erc-fill-function 'erc-fill-static)
  (erc-fill-static-center 20)
  (erc-fill-column 115)
  (erc-prompt (lambda () (concat (buffer-name)">")))
  ;; modeline
  (erc-track-showcount t)
  (erc-track-exclude-types '("JOIN" "PART" "QUIT" "NICK" "MODE" "333" "353"))
  (erc-track-position-in-mode-line 'after-modes)
  (erc-track-shorten-start 3)
  ;; queries
  (erc-receive-query-display 'bury)
  (erc-buffer-display 'buffer)
  (erc-interactive-display 'buffer)
  ;; ‘window’          - in another window,
  ;; ‘window-noselect’ - in another window, but don’t select that one,
  ;; ‘frame’           - in another frame,
  ;; ‘bury’            - bury it in a new buffer,
  ;; ‘buffer’          - in place of the current buffer,
  ;; DISPLAY-FUNCTION  - a ‘display-buffer’-like function
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
  ;; (add-to-list 'display-buffer-alist
  ;;              '(;; Matcher
  ;;                (derived-mode . erc-mode)
  ;;                ;; List of display functions
  ;;                (display-buffer-in-tab)
  ;;                ;; Parameters
  ;;                (ignore-current-tab . t)
  ;;                (tab-name . "ERC")
  ;;                (tab-group . "ERC")))

  ;; notifications, only available for systems with DBUS (mostly linux)
  (when (string-equal system-type 'gnu/linux)
    (erc-notifications-mode 1)))

(use-package erc-status-sidebar
  :disabled t
  :after erc
  :hook (erc-mode-hook . erc-status-sidebar-open)
  :config
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

(use-package face-remap
  :demand t
  :delight (buffer-face-mode))

(use-package faces ; linux
  :when (string-equal system-type 'gnu/linux)
  :demand t
  :preface
  (defun my/set-emoji-font ()
    (set-fontset-font t 'emoji (font-spec :family "Noto Color Emoji")))
  :config
  ;; The default face is the only one that must have an absolute :height value.
  ;; Everything else uses a floating point, which is understood as a multiple of
  ;; the default.
  (let ((mono-spaced-font "Ubuntu Sans Mono") ; { Ubuntu Sans Mono, DejaVu Sans Mono }
        (proportionately-spaced-font "Ubuntu Sans")) ; { Ubuntu, Ubuntu Sans, Ubuntu Sans Mono, Arial }
    (set-face-attribute 'default nil :family mono-spaced-font :height 120)
    (set-face-attribute 'fixed-pitch nil :family mono-spaced-font :height 1.0)
    (set-face-attribute 'variable-pitch nil :family proportionately-spaced-font :height 1.0))

  (if (daemonp)
      (add-hook 'server-after-make-frame-hook #'my/set-emoji-font)
    (my/set-emoji-font)))

(use-package faces ; windows
  :when (string-equal system-type 'windows-nt)
  :demand t
  :preface
  (defun my/set-emoji-font ()
    (set-fontset-font t 'emoji (font-spec :family "Segoe UI Emoji")))
  :config
  (let ((mono-spaced-font "Cascadia Mono") ; { Cascadia Mono, Consolas }
        (proportionately-spaced-font "Verdana")) ; { Courier New, Verdana, Georgia, Lucida Sans Unicode }
    (set-face-attribute 'default nil :family mono-spaced-font :height 100)
    (set-face-attribute 'fixed-pitch nil :family mono-spaced-font :height 1.0)
    (set-face-attribute 'variable-pitch nil :family proportionately-spaced-font :height 1.0))

  (if (daemonp)
      (add-hook 'server-after-make-frame-hook #'my/set-emoji-font)
    (my/set-emoji-font)))

(use-package faces ; macos
  :when (string-equal system-type 'darwin)
  :demand t
  :preface
  (defun my/set-emoji-font ()
    (set-fontset-font t 'emoji (font-spec :family "Apple Color Emoji")))
  :config
  (let ((mono-spaced-font "Monaco") ; { Menlo, SF Mono, Monaco }
        (proportionately-spaced-font "Lucida Grande")) ; { Times, Lucida Grande }
    (set-face-attribute 'default nil :family mono-spaced-font :height 100)
    (set-face-attribute 'fixed-pitch nil :family mono-spaced-font :height 1.0)
    (set-face-attribute 'variable-pitch nil :family proportionately-spaced-font :height 1.0))

  (if (daemonp)
      (add-hook 'server-after-make-frame-hook #'my/set-emoji-font)
    (my/set-emoji-font)))

(use-package files
  :demand t
  :custom
  (auto-save-file-name-transforms
   `((".*" ,(expand-file-name "auto-saves/" user-emacs-directory) t)))
  (backup-directory-alist
   `(("." . ,(expand-file-name "backups" user-emacs-directory))))
  (lock-file-name-transforms
   `((".*" ,(expand-file-name "lockfiles/" user-emacs-directory) t)))
  (backup-by-copying t)
  (delete-old-versions t)
  (kept-new-versions 6)
  (vc-make-backup-files t)
  (version-control t)
  (require-final-newline t)
  (remote-file-name-inhibit-locks t)
  (remote-file-name-inhibit-delete-by-moving-to-trash t)
  :config
  ;; inhibit remote backup file creation
  (setq backup-enable-predicate
        (lambda (fname)
          (and (normal-backup-enable-predicate fname)
               (not (file-remote-p fname)))))

  (make-directory (expand-file-name "auto-saves" user-emacs-directory) t)
  (make-directory (expand-file-name "lockfiles" user-emacs-directory) t))

(use-package find-dired
  ;; find-dired, find-dired-with-command, find-name-dired, find-grep-dired
  :demand t
  :custom
  (find-exec-terminator  "\"+\"")
  (find-ls-option '("-exec ls -ldh {} +" . "-ldh")))

(use-package flymake
  :demand t
  :hook ((emacs-lisp-mode-hook sh-mode-hook) . flymake-mode) ;; don't add language modes whose linter is managed by LSP
  :config (remove-hook 'flymake-diagnostic-functions 'flymake-proc-legacy-flymake))

(use-package flyspell
  :demand t
  ;; :hook ((text-mode-hook . flyspell-mode)
  ;;        (prog-mode-hook . flyspell-prog-mode))
  :bind (:map flyspell-mode-map ("C-c f" . flyspell-auto-correct-previous-word))
  :config
  (define-key flyspell-mode-map (kbd "C-;") nil)
  (define-key flyspell-mode-map (kbd "C-,") nil))

(use-package frame
  :demand t
  :custom
  (blink-cursor-blinks 0) ; blinks forever
  (blink-cursor-delay 0.2)
  :config (blink-cursor-mode -1))

(use-package gnus
  :demand t
  :hook (gnus-mode-hook . hl-line-mode)
  :custom
  (gnus-directory (expand-file-name "gnus" user-emacs-directory))
  (gnus-home-directory (expand-file-name "gnus" user-emacs-directory))
  (gnus-article-save-directory (expand-file-name "gnus" user-emacs-directory))
  (gnus-use-scoring nil)
  (gnus-keep-backlog nil)
  (gnus-interactive-exit 'quiet)
  (gnus-suppress-duplicates t)
  (gnus-select-method '(nnnil ""))
  (gnus-secondary-select-methods
   '((nntp "news.gwene.org") ;; rss
     (nntp "news.gmane.io") ;; mailing lists
     (nntp "feedbase"
           (nntp-open-connection-function nntp-open-tls-stream)
           (nntp-port-number 563)
           (nntp-address "feedbase.org"))
     (nnimap "icloud"
             (nnimap-address "imap.mail.me.com")
             (nnimap-server-port 993)
             (nnimap-stream ssl)
             (nnir-search-engine imap))))
  (gnus-message-archive-group "nnimap+icloud:Sent Messages")
  (gnus-summary-line-format "%U%R %-18,18&user-date; %4L:%-25,25f %B%s\n")
  ;; (gnus-summary-goto-unsplit-windows t)
  (gnus-parameters
   '((".*"
      (display . 100))
     ("INBOX"
      (modeline-notify . t)
      (gnus-show-threads nil)
      (display . 70))))
  :config
  ;; (add-to-list 'display-buffer-alist
  ;;              '(;; Matcher
  ;;                (or (derived-mode . gnus-group-mode)
  ;;                    (derived-mode . gnus-summary-mode)
  ;;                    (derived-mode . gnus-article-mode)
  ;;                    "\\*Group\\*")
  ;;                ;; List of display functions
  ;;                (display-buffer-in-tab)
  ;;                ;; Parameters
  ;;                (ignore-current-tab . t)
  ;;                (dedicated . t)
  ;;                (tab-name . "Gnus")
  ;;                (tab-group . "Gnus")))
  )

(use-package gnus-agent
  :demand t
  :custom (gnus-agent-prompt-send-queue t))

(use-package gnus-art
  :demand t
  :bind (:map gnus-article-mode-map ("M-q" . gnus-article-fill-long-lines)))

(use-package gnus-group
  :demand t
  :preface
  (defun my/quit-if-gnus-tab ()
    (when (tab-bar--tab-index-by-name "Gnus")
      (tab-bar-close-tab-by-name "Gnus")))
  :hook ((gnus-group-mode-hook . gnus-topic-mode)
         (gnus-exit-gnus-hook . my/quit-if-gnus-tab))
  :custom
  (gnus-group-line-format "%M%S%p%P%5y:%B%(%G%)\n")
  (gnus-permanently-visible-groups ".*"))

(use-package gnus-start
  :demand t
  :preface
  (defun gnus-demon-load ()
    "Start the Gnus demon during Gnus startup."
    (gnus-demon-init)
    (gnus-demon-add-handler 'gnus-demon-scan-news 30 nil))

  (defun turn-off-backup ()
    (set (make-local-variable 'backup-inhibited) t))
  :hook
  (gnus-startup-hook . gnus-demon-load)
  ((gnus-save-quick-newsrc-hook gnus-save-standard-newsrc-hook) . turn-off-backup)
  :custom
  (gnus-activate-level 1)
  (gnus-save-killed-list nil)
  (gnus-check-new-newsgroups 'ask-server)
  (gnus-subscribe-newsgroup-method 'gnus-subscribe-topics)
  (gnus-use-dribble-file nil)
  (gnus-read-newsrc-file nil)
  (gnus-save-newsrc-file nil))

(use-package gnus-sum
  :demand t
  :custom
  (gnus-auto-select-first nil)
  (gnus-article-sort-functions
   '((not gnus-article-sort-by-date)))
  (gnus-thread-sort-functions
   '(gnus-thread-sort-by-most-recent-date))
  (gnus-summary-mode-line-format "[%U] %p")
  (gnus-sum-thread-tree-false-root "")
  (gnus-sum-thread-tree-indent " ")
  (gnus-sum-thread-tree-single-indent "")
  (gnus-sum-thread-tree-leaf-with-other "+-> ")
  (gnus-sum-thread-tree-root "")
  (gnus-sum-thread-tree-single-leaf "\\-> ")
  (gnus-sum-thread-tree-vertical "|"))

(use-package gnus-topic
  :demand t
  :bind (:map gnus-topic-mode-map ([remap gnus-topic-indent] . gnus-topic-read-group)))

;; (use-package gnus-win
;;   :demand t
;;   :config
;;   (gnus-add-configuration
;;    '(article
;;      (summary 1.0 point)
;;      (article 1.0))))

(use-package grep
  :demand t
  :custom
  (grep-save-buffers nil)
  (grep-use-headings t)
  (grep-command-position 122)
  :config
  ;; (when (string-equal system-type 'windows-nt)
  ;;   (setopt find-program "\"C:/Program Files/Git/usr/bin/find.exe\""))

  (grep-apply-setting 'grep-highlight-matches 'always)
  (grep-apply-setting 'grep-find-use-xargs 'exec-plus)
  (grep-apply-setting 'grep-use-null-filename-separator t)
  (grep-apply-setting 'grep-use-null-device nil)

  ;; grep (non-recursive)
  (grep-apply-setting 'grep-command "grep --binary-file=without-match --directories=skip --color=always --ignore-case --line-number --with-filename --null -e  * .*")

  ;; lgrep (non-recursive)
  (grep-apply-setting 'grep-template "grep <X> --binary-file=without-match --directories=skip --color=always --ignore-case --line-number --with-filename --null -e <R> <F>")

  ;; grep-find (recursive)
  (grep-apply-setting 'grep-find-command '("find . -type f -exec grep --binary-file=without-match --color=always --ignore-case --line-number --with-filename --null -e  {} +" . 124))

  ;; rgrep (recursive)
  (grep-apply-setting 'grep-find-template "find -H <D> <X> -type f <F> -exec grep --binary-file=without-match --color=always --ignore-case --line-number --with-filename --null -e <R> {} +"))

(use-package help
  :demand t
  :hook (help-fns-describe-function-functions . shortdoc-help-fns-examples-function)
  :custom (help-window-select t))

(use-package hexl
  :demand t
  :mode ("\\.exe\\'" . hexl-mode)
  :interpreter ("hexl" . hexl-mode))

(use-package hippie-exp
  :demand t
  :bind (("M-/"   . hippie-expand)
         ("C-M-/" . dabbrev-completion)))

(use-package ibuffer
  :demand t
  :preface
  (defun my/ibuffer-set-up-preferred-filters ()
    (ibuffer-switch-to-saved-filter-groups "default"))
  :hook ((ibuffer-mode-hook . hl-line-mode)
         (ibuffer-mode-hook . ibuffer-auto-mode)
         (ibuffer-mode-hook . my/ibuffer-set-up-preferred-filters))
  :bind (([remap list-buffers] . ibuffer) ; "C-x C-b"
         (:map ibuffer-mode-map
               ("q" . (lambda () (interactive) (quit-window t)))))
  :custom
  (ibuffer-display-summary nil)
  (ibuffer-default-sorting-mode 'major-mode)
  (ibuffer-expert t)
  (ibuffer-formats
   '((mark modified read-only locked " "
    	   (name 35 35 :left :elide)
    	   " "
    	   (size-h 9 -1 :right)
    	   " "
    	   (mode 16 16 :left :elide)
    	   " " filename-and-process)
     (mark " "
           (name 16 -1)
           " " filename)))
  (ibuffer-saved-filter-groups
   '(("default"
      ("Tramp"
       (or
        (mode . tramp-mode)
        (filename . "/ssh:")
        (filename . "/sudo:")
        (name . "\\*tramp")))
      ("Dired" (mode . dired-mode))
      ("ERC" (mode . erc-mode))
      ("Magit"
       (or
        (mode . magit-status-mode)
        (mode . magit-log-mode)
        (name . "\\*magit")
        (name . "magit-")
        (name . "git-monitor")))
      ("Gnus"
       (or
        (mode . message-mode)
        (mode . mail-mode)
        (mode . gnus-server-mode)
        (mode . gnus-browse-mode)
        (mode . gnus-group-mode)
        (mode . gnus-summary-mode)
        (mode . gnus-article-mode)
        (name . "^\\.newsrc-dribble")
        (name . "^\\*\\(sent\\|unsent\\|fetch\\)")
        (name . "^ \\*\\(nnimap\\|nntp\\|nnmail\\|gnus\\|server\\|mm\\*\\)")
        (name . "\\(Original Article\\|canonical address\\|extract address\\)")))
      ("Special"
       (or
        (name . "\\*docker")
        (starred-name))))))
  (ibuffer-show-empty-filter-groups nil)
  :config
  ;; Use human readable Size column instead of original one
  (define-ibuffer-column size-h
    (:name "Size" :inline t)
    (file-size-human-readable (buffer-size))))

(use-package icomplete
  :disabled t
  :demand t
  :preface
  ;; fido-mode hardcodes the built-in flex completion
  ;; we need to add a hook to change it
  ;; !! might be changed in Emacs 29 !!
  (defun use-orderless ()
    (setopt completion-styles '(orderless basic)
            completion-category-overrides '((file (styles basic partial-completion)))))
  :custom
  (icomplete-matches-format "%s/%s   ")
  (icomplete-show-matches-on-no-input t)
  (icomplete-compute-delay 0)
  :config
  (add-hook 'minibuffer-setup-hook #'use-orderless)
  (fido-vertical-mode 1))

(use-package imenu
  :demand t
  :custom (imenu-auto-rescan t))

(use-package isearch
  :demand t
  :preface
  (defun my/goto-match-beginning ()
    "Go to the start of current isearch match.
    Use in `isearch-mode-end-hook'."
    (when (and isearch-forward
               (number-or-marker-p isearch-other-end)
               (not mark-active)
               (not isearch-mode-end-hook-quit))
      (goto-char isearch-other-end)))
  :hook ('isearch-mode-end-hook . #'my/goto-match-beginning)
  :bind (:map isearch-mode-map
              ([remap isearch-delete-char] . isearch-del-char) ; <backspace>
              ("C-s" . isearch-forward-thing-at-point) ; C-s C-s
              ("C-p" . isearch-repeat-backward)
              ("C-n" . isearch-repeat-forward))
  :custom
  (search-whitespace-regexp ".*?")       ; so we can use <space> as wildcard
  (isearch-repeat-on-direction-change t)
  (isearch-allow-scroll 'unlimited)
  (isearch-lazy-count t)
  (isearch-allow-motion t)
  (isearch-motion-changes-direction t)
  (lazy-highlight-buffer t)
  (lazy-highlight-cleanup t)
  (lazy-highlight-initial-delay 0)
  (lazy-count-prefix-format nil)
  (lazy-count-suffix-format " (%s/%s)"))

(use-package ispell
  :demand t
  :custom (ispell-dictionary "en_US,fr_FR")
  :config
  (if (string-equal system-type 'darwin)
      (setq ispell-program-name "enchant-2")
    (setq ispell-program-name "hunspell"))

  (when (string-equal system-type 'windows-nt)
    (setq ispell-hunspell-dict-paths-alist
          (list (cons "en_US" (list (expand-file-name "hunspell/en_US.aff" user-emacs-directory)))
                (cons "fr_FR" (list (expand-file-name "hunspell/fr_FR.aff" user-emacs-directory)))))
    (setenv "DICPATH" (expand-file-name "hunspell/" user-emacs-directory))
    (setenv "LANG" "en_US.UTF-8"))

  ;; ispell-set-spellchecker-params has to be called
  ;; before ispell-hunspell-add-multi-dic will work
  (ispell-set-spellchecker-params)
  (ispell-hunspell-add-multi-dic "en_US,fr_FR"))

(use-package js
  :demand t
  :mode ("\\.jsonc\\'" . js-json-mode))

(use-package ls-lisp
  :demand t
  :custom
  (ls-lisp-use-localized-time-format t)
  (ls-lisp-format-time-list '("%Y-%m-%d"
                              "%Y-%m-%d"))
  (ls-lisp-use-insert-directory-program nil)
  (ls-lisp-dirs-first t))

(use-package menu-bar
  :when (memq window-system '(mac ns))
  :config (menu-bar-mode 1))

(use-package message
  :demand t
  :custom (message-send-mail-function 'smtpmail-send-it))

(use-package minibuffer
  :demand t
  :preface
  (defun mb-defer-garbage-collection ()
    "Set the value for garbage collection when using the minibuffer."
    (setopt gc-cons-threshold most-positive-fixnum))

  (defun mb-restore-garbage-collection ()
    "Defer and restore garbage collection after small delay.
    Commands launched immediately after will also enjoy the benefits."
    (run-at-time
     3 nil (lambda () (setopt gc-cons-threshold my-gc-cons-threshold))))
  :hook ((minibuffer-setup-hook . mb-defer-garbage-collection)
         (minibuffer-exit-hook . mb-restore-garbage-collection))
  :bind (:map minibuffer-local-completion-map
              ("<backtab>" . minibuffer-completion-help)
              ("SPC") ("?"))
  :custom
  (completions-group t)
  (completions-detailed t)
  (completions-format 'vertical)
  ;; (completion-auto-help 'always)
  ;; (completion-auto-select t)
  (completion-ignore-case t)
  ;; (completion-pcm-complete-word-inserts-delimiters t)
  (completion-show-help nil)
  (echo-keystrokes 0.25)
  (enable-recursive-minibuffers t)
  (read-answer-short t)
  (read-buffer-completion-ignore-case t)
  ;; (resize-mini-windows t)
  :config
  (minibuffer-depth-indicate-mode 1)
  (minibuffer-electric-default-mode 1))

(use-package mule
  :demand t
  :config (prefer-coding-system 'utf-8-unix))

(use-package mwheel
  :demand t
  :custom
  (mouse-wheel-progressive-speed nil)
  (mouse-wheel-scroll-amount '(3
                               ((shift) . hscroll)
                               ((meta))
                               ((control meta) . global-text-scale)
                               ((control) . text-scale)))
  :config
  (mouse-wheel-mode 1)
  ;; enables trackpad scrolling in emacs terminal
  (unless window-system
    (global-set-key (kbd "<mouse-4>") 'scroll-down-line)
    (global-set-key (kbd "<mouse-5>") 'scroll-up-line)))

(use-package ob-core
  :demand t
  :custom (org-confirm-babel-evaluate nil))

(use-package org
  :preface
  (defface my/org-code
    '((default :inherit 'fixed-pitch)
      (((class color) (min-colors 88) (background light))
       :foreground "#41332a"
       :background "#f0e0d6"
       :weight normal
       :box (:line-width (1 . -1) :color "#d2c2b8"))
      (((class color) (min-colors 88) (background dark))
       :foreground "#6bc1e4"
       :background "#282a2e"
       :weight normal
       :box (:line-width (1 . -1) :color "#191b1f")))
    "My new code for org.")

  (defun my/org-autofill-mode ()
    "Autofill for org-mode."
    (auto-fill-mode 1))

  (defun my/org-create-note-file ()
    "Create an org file in Notes folder."
    (let ((name (read-string "Filename (don't add extension): ")))
      (expand-file-name (format "%s.org" name) org-directory)))

  (defun my/org-syntax-table ()
    "Modify org syntax table so '~', '/' & '=' can be used to surround strings."
    (modify-syntax-entry ?/ "$/" org-mode-syntax-table)
    (modify-syntax-entry ?= "$=" org-mode-syntax-table)
    ;; (modify-syntax-entry ?* "$*" org-mode-syntax-table)
    (modify-syntax-entry ?_ "$_" org-mode-syntax-table)
    (modify-syntax-entry ?~ "$~" org-mode-syntax-table))

  (defun my/org-toggle-hide-emphasis-markers (&optional arg)
    "Toggle the value of `org-hide-emphasis-markers'.
    If ARG is non-nil, the effect is global.
    Otherwise, the effect is buffer-local."
    (interactive "P")
    (let* ((current-value org-hide-emphasis-markers)
           (toggled (not current-value))
           (status (concat "org-hide-emphasis set to " (format "%s" toggled))))
      (if arg
          (progn
            (setopt org-hide-emphasis-markers toggled)
            (setq status (concat status " globally")))
        (setq-local org-hide-emphasis-markers toggled)
        (setq status (concat status " in buffer " (buffer-name))))
      (font-lock-flush)
      (font-lock-ensure)
      (message "%s" status)))
  :hook ((org-mode-hook . my/org-autofill-mode)
         (org-mode-hook . variable-pitch-mode)
         (org-mode-hook . my/org-syntax-table))
  :bind (([remap org-cycle-agenda-files] . 'er/expand-region)
         (:map org-mode-map ("C-c s" . my/org-toggle-hide-emphasis-markers)))
  :custom
  (org-special-ctrl-a/e t)
  (org-hide-emphasis-markers t)
  (org-hide-leading-stars t)
  (org-startup-indented t)
  (org-startup-folded nil)
  (org-emphasis-alist
   '(("*" bold)
     ("/" italic)
     ("_" underline)
     ("=" org-verbatim verbatim)
     ("~" my/org-code)
     ("+" (:strike-through t))))
  (org-babel-load-languages '((emacs-lisp . t)
                              (shell . t)
                              (python . t)
                              (js . t)))
  (org-todo-keywords '((type "TODO" "EMACS" "WINDOWS" "MACOS" "LINUX" "BOOK" "MOVIE" "|" "DONE")))
  (org-todo-keyword-faces
   '(("EMACS"   . (:inherit fixed-pitch :foreground "#531ab6"))
     ("MACOS"   . (:inherit fixed-pitch :foreground "#595959"))
     ("LINUX"   . (:inherit fixed-pitch :foreground "#d00000"))
     ("BOOK"    . (:inherit fixed-pitch :foreground "#2E8B57"))
     ("MOVIE"   . (:inherit fixed-pitch :foreground "#000000"))
     ("WINDOWS" . (:inherit fixed-pitch :foreground "#0000ff"))))
  :custom-face
  ;; Force a few faces to fixed-pitch, even in `variable-pitch-mode'
  (org-checkbox ((t (:inherit fixed-pitch))))
  (org-done     ((t (:inherit fixed-pitch))))
  (org-priority ((t (:inherit fixed-pitch))))
  (org-tag      ((t (:inherit fixed-pitch))))
  (org-todo     ((t (:inherit fixed-pitch))))
  (org-block    ((t (:inherit fixed-pitch))))
  (org-code     ((t (:inherit fixed-pitch))))
  :config
  (global-set-key (kbd "<f1>") (lambda () (interactive) (find-file org-default-notes-file)))
  ;; Notes folder and inbox file
  (when (member "notes" (bookmark-all-names))
    ;; prepare to use project--list
    (setopt org-directory (bookmark-location "notes")
            org-default-notes-file (expand-file-name "master.org" org-directory)
            org-agenda-files `(,org-default-notes-file)
            org-agenda-text-search-extra-files (directory-files-recursively org-directory org-agenda-file-regexp))))


(use-package org-agenda
  :demand t
  :bind ("C-c a" . org-agenda))

(use-package org-capture
  :demand t
  :bind ("C-c c" . org-capture)
  :custom
  (org-capture-bookmark nil) ; disable org creating a bookmark after capturing
  (org-capture-templates
   '(("f" "new file note" plain (file my/org-create-note-file)
      "#+TITLE: %?")
     ("n" "quick note" entry (file "")
      "* %?" :empty-lines 1)
     ("t" "TODO" checkitem (file+headline "" "main") nil :prepend t)
     ("c" "citation" entry (file "citations.org")
      "* %^{Author}\n\n#+BEGIN_VERSE\n%c\n#+END_VERSE%?" :empty-lines 1))))

(use-package org-indent
  :demand t
  :delight (org-indent-mode)
  :custom (org-indent-indentation-per-level 1))

(use-package org-keys
  :demand t
  :custom (org-use-speed-commands t))

(use-package org-list
  :demand t
  :custom (org-list-allow-alphabetical t))

(use-package org-src
  :demand t
  :custom
  (org-src-tab-acts-natively t)
  (org-edit-src-content-indentation 0))

(use-package outline
  :demand t
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
  ;; :hook ((emacs-lisp-mode-hook . my/outline-elisp)
  ;;        (sh-mode-hook . my/outline-sh-space-ps)
  ;;        ((conf-space-mode-hook powershell-mode-hook) . my/outline-sh-space-ps)
  ;;        (conf-xdefaults-mode-hook . my/outline-xdefaults))
  :bind ("C-c C-c" . outline-toggle-children))

(use-package package-vc
  :demand t
  :custom (package-vc-register-as-project nil))

(use-package paren
  :demand t
  :custom (show-paren-style 'expression)
  :custom-face (show-paren-match-expression ((t (:foreground "red2" :background unspecified))))
  ;; :custom (show-paren-delay 0)
  :config (show-paren-mode 1))

(use-package password-cache
  :demand t
  :custom (password-cache-expiry nil))

(use-package pixel-scroll
  :when (memq window-system '(mac ns x))
  :demand t
  :config (pixel-scroll-precision-mode t))

(use-package proced
  :demand t
  :custom
  (proced-enable-color-flag t)
  (proced-auto-update-flag t)
  ;; (proced-auto-update-interval 1)
  (proced-tree-flag t)
  (proced-format 'long))

(use-package project
  :demand t
  :preface
  (defun project/fd-name-dired (pattern)
    (interactive
     "sFd-name (filename regexp): ")
    (let ((pr (project-root (project-current))))
      (fd-dired pr (shell-quote-argument pattern))))
  (defun my/project-mode-line-format () ; fixed in Emacs 31
    (unless (file-remote-p default-directory)
      (project-mode-line-format)))
  :custom
  (project-vc-extra-root-markers '(".project"))
  (project-mode-line t) ; bugged in 30.1
  (project-switch-commands
   '((consult-fd "consult-fd" ?f)
     (consult-ripgrep "consult-ripgrep" ?g)
     (project-dired "Dired" ?d)
     (magit-project-status "Magit" ?m)
     (project-eshell "Eshell")
     (project/fd-name-dired "fd-name-dired" ?n)))
  :config (setq project-mode-line-format '(:eval (my/project-mode-line-format)))) ; fixed in Emacs 31

(use-package re-builder
  :demand t
  :custom (reb-re-syntax 'string))

(use-package recentf
  :demand t
  :custom
  ;; (recentf-keep '(file-remote-p file-readable-p)) ;; tramp-tramp-file-p
  (recentf-auto-cleanup 'never) ; mode, 60, never
  (recentf-max-saved-items 30)
  (recentf-exclude '("/elpa/" ".persistent-scratch" "index" ".jpg" ".png" ".mp4" ".mkv"))
  :config (recentf-mode 1))

(use-package remember
  :demand t
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

(use-package repeat
  :demand t
  :config (repeat-mode 1))

(use-package savehist
  :demand t
  :custom
  (savehist-additional-variables '(search-ring regexp-search-ring register-alist))
  (history-delete-duplicates t)
  (history-length 999)
  :config (savehist-mode 1))

(use-package saveplace
  :demand t
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
  :disabled t
  :when window-system
  :demand t
  :custom-face (scroll-bar ((t (:background "grey"))))
  :config
  ;; (scroll-bar-mode -1)
  (set-window-scroll-bars (minibuffer-window) nil nil nil nil 1)
  (set-scroll-bar-mode 'left)
  (horizontal-scroll-bar-mode -1))

(use-package sendmail
  :demand t
  :custom (send-mail-function 'smtpmail-send-it))

(use-package shr
  :demand t
  :custom-face (shr-text ((t (:height 0.9)))))

(use-package simple
  :demand t
  :delight (auto-fill-function)
  :preface
  (defun my/join-line ()
    (interactive)
    (join-line -1))

  (defun push-mark-no-activate ()
    "Pushes `point' to `mark-ring' and does not activate the region
     Equivalent to \\[set-mark-command] when \\[transient-mark-mode] is disabled"
    (interactive)
    (push-mark (point) t nil)
    (message "Pushed mark to ring"))

  (defun jump-to-mark ()
    "Jumps to the local mark, respecting the `mark-ring' order.
    This is the same as using \\[set-mark-command] with the prefix argument."
    (interactive)
    (set-mark-command 1))

  (defun exchange-point-and-mark-no-activate ()
    "Identical to \\[exchange-point-and-mark] but will not activate the region."
    (interactive)
    (exchange-point-and-mark)
    (deactivate-mark nil))

  (defun my/keyboard-quit-dwim ()
    "Do-What-I-Mean behaviour for a general `keyboard-quit'.

The generic `keyboard-quit' does not do the expected thing when
the minibuffer is open.  Whereas we want it to close the
minibuffer, even without explicitly focusing it.

The DWIM behaviour of this command is as follows:

- When the region is active, disable it.
- When a minibuffer is open, but not focused, close the minibuffer.
- When the Completions buffer is selected, close it.
- In every other case use the regular `keyboard-quit'."
    (interactive)
    (cond
     ((region-active-p)
      (keyboard-quit))
     ((derived-mode-p 'completion-list-mode)
      (delete-completion-window))
     ((> (minibuffer-depth) 0)
      (abort-recursive-edit))
     (t
      (keyboard-quit))))
  :bind (("C-x C-m" . execute-extended-command)
         ("C-z" . kill-region)
         ("M-z" . kill-ring-save)
         ([remap default-indent-new-line] . my/join-line) ; "M-j"
         ("C-?" . jump-to-mark)
         ("C-'" . push-mark-no-activate)
         ([remap keyboard-quit] . my/keyboard-quit-dwim) ; "C-g"
         ([remap exchange-point-and-mark] . exchange-point-and-mark-no-activate)) ; "C-x C-x"
  :custom
  (indent-tabs-mode nil)
  (mark-ring-max 3)
  (global-mark-ring-max 8)
  (save-interprogram-paste-before-kill t)
  (set-mark-command-repeat-pop t)
  :config
  (add-to-list 'display-buffer-alist
               '(;; Matcher
                 (or (derived-mode . messages-buffer-mode)
                     "\\*\\(Messages\\|Warnings\\)\\*")
                 ;; List of display functions
                 (display-buffer-reuse-mode-window
                  display-buffer-in-side-window)
                 ;; Parameters
                 (side . right)
                 (slot . 0)
                 (window-width . 1)
                 (body-function . select-window))))

(use-package smtpmail
  :demand t
  :custom
  (smtpmail-default-smtp-server "smtp.mail.me.com")
  (smtpmail-smtp-server "smtp.mail.me.com")
  (smtpmail-smtp-service 587)
  (smtpmail-stream-type 'starttls)
  ;; (user-full-name "")
  ;; (user-mail-address "")
  )

(use-package subword
  :demand t
  :delight (subword-mode)
  :config (global-subword-mode 1))

(use-package tab-bar
  :demand t
  :preface
  (defun my/rename-first-tab ()
    "Rename the first tab to 'Main'."
    (tab-bar-rename-tab "Main"))
  :bind (;; Azerty keyboard adaptation
         ("C-x t &" . tab-bar-close-other-tabs) ; "C-x t 1"
         ("C-x t é" . tab-bar-new-tab) ; "C-x t 2"
         ("C-x t à" . tab-bar-close-tab)) ; "C-x t 0"
  :hook (window-setup-hook . my/rename-first-tab)
  :custom
  (tab-bar-show 1)
  (tab-bar-close-last-tab-choice 'tab-bar-mode-disable)
  (tab-bar-new-tab-to 'rightmost)
  (tab-bar-close-button-show nil)
  (tab-bar-format '(tab-bar-format-history tab-bar-format-tabs tab-bar-separator))
  :config (tab-bar-mode 1))

(use-package tab-line
  :disabled t
  :demand t
  :preface
  (defun my/tab-quit-messages ()
    (when (and (get-buffer "*Messages*")
               tab-line-mode)
      (tab-line-switch-to-next-tab)
      (quit-window)))
  :bind (("C-x c" . tab-line-close-tab)
         ("C-<tab>" . tab-line-switch-to-next-tab)
         ("C-<iso-lefttab>" . tab-line-switch-to-prev-tab))
  :hook (emacs-startup-hook . my/tab-quit-messages)
  :custom
  (tab-line-switch-cycling t)
  (tab-line-exclude-modes '(completion-list-mode
                            speedbar-mode
                            imenu-list-major-mode
                            flymake-diagnostics-buffer-mode
                            dired-sidebar-mode))
  :config (global-tab-line-mode t))

(use-package time
  :demand t
  :preface
  (defun my/time-check ()
    (message "Startup time: %s seconds" (emacs-init-time "%.1f")))
  :hook (emacs-startup-hook . my/time-check))

(use-package tramp
  :demand t
  :preface
  (defun my/tramp-cleanup-all ()
    (interactive)
    (tramp-cleanup-all-connections)
    (tramp-cleanup-all-buffers))
  :custom
  (tramp-show-ad-hoc-proxies t)
  (tramp-auto-save-directory
   (expand-file-name "auto-saves" user-emacs-directory))
  (remote-file-name-inhibit-auto-save t)
  (remote-file-name-inhibit-auto-save-visited t)
  (tramp-completion-use-auth-sources nil)
  ;; both settings below taken from: https://coredumped.dev/2025/06/18/making-tramp-go-brrrr./
  (tramp-use-scp-direct-remote-copying t)
  (tramp-copy-size-limit (* 1024 1024)) ;; 1MB
  :config
  ;; speeding up Tramp a bit
  (remove-hook 'find-file-hook 'forge-bug-reference-setup)

  ;; prevent TRAMP from clearing the recentf-list
  (remove-hook 'tramp-cleanup-connection-hook #'tramp-recentf-cleanup)
  (remove-hook 'tramp-cleanup-all-connections-hook #'tramp-recentf-cleanup-all)

  ;; use ssh controlmaster on macOS & Linux
  (when (memq system-type '(darwin gnu/linux))
    (setopt tramp-use-connection-share t))

  ;; disable using authinfo.gpg for root/sudo password query
  ;; (connection-local-set-profile-variables
  ;;  'remote-without-auth-sources '((auth-sources . nil)))
  ;; (connection-local-set-profiles
  ;;  '(:application tramp) 'remote-without-auth-sources)

  ;; let the remote system decide the umask
  (setopt tramp-remote-process-environment
          (append tramp-remote-process-environment
                  '("UMASK="))))

(use-package transient
  :demand t
  :bind (:map dired-mode-map ("C-." . transient-dired))
  :config
  (transient-define-prefix transient-dired ()
    "A menu to open customize options"
    [["FFmpeg"
      ("f c" "concatenate video files"     ffmpeg-concatenate-videofiles)
      ("f x" "merge audio and video files" ffmpeg-merge-audiovideo)
      ("f f" "flip video(s)"               ffmpeg-flip-video)
      ("f t" "trim video"                  ffmpeg-trim-video)
      ("f e" "extract a single frame"      ffmpeg-extract-frame)
      ("f a" "remove audio"                ffmpeg-remove-audio)
      ("f m" "remove metadata"             ffmpeg-remove-metadata)
      ("f 5" "converts to x265"            ffmpeg-x265-convert)
      ("f s" "converts ts to mp4"          ffmpeg-ts-convert)
      ("f h" "scale to half size"          ffmpeg-scale-half)
      ("f 3" "scale to third size"         ffmpeg-scale-third)
      ("f u" "upscale to 60 fps"           ffmpeg-upscale)]

     ["MKVToolNix"
      ("m s" "remove all subtitles"        mkvmerge-rm-subtitles)
      ("m a" "remove audio tracks"         mkvmerge-rm-audiotracks)]

     ["ImageMagick"
      ("i c" "convert to jpg"              magick-convert-to-jpg)
      ("i f" "flip image"                  magick-flip-image)]

     ["ExifTool"
      ("e e" "remove exif data"            exiftool-remove-exif)]

     ["Misc"
      ("r f" "rename file(s)"              random-rename-files)]]))

(use-package uniquify
  :demand t
  :custom (uniquify-buffer-name-style 'reverse))

(use-package vc-git
  :demand t
  :custom
  ;; vc-git-grep (recursive)
  (vc-git-grep-template "git --no-pager grep --color=always --ignore-case --line-number -I -e <R> -- <F>")
  (vc-follow-symlinks t))

(use-package vc-hooks
  :demand t
  :custom (vc-handled-backends '(Git)))

(use-package webjump
  :demand t
  :preface
  (defun my/webjump-do-simple-query (name noquery-url query-prefix query-suffix)
    (let ((query (if mark-active
                     (buffer-substring (region-beginning) (region-end))
                   (webjump-read-string (concat name " query")))))
      (if query
          (concat query-prefix (webjump-url-encode query) query-suffix)
        noquery-url)))
  :bind ("C-x /" . webjump)
  :custom
  (webjump-use-internal-browser nil)
  (webjump-sites '(("Google" . [simple-query "www.google.com" "www.google.com/search?ie=utf-8&oe=utf-8&q=" ""])
                   ("GitHub" . [simple-query "github.com" "github.com/search?ref=simplesearch&q=" ""])
                   ("Stack Overflow" . [simple-query "stackoverflow.com" "stackoverflow.com/search?q=" ""])
                   ("YouTube" . [simple-query "www.youtube.com" "www.youtube.com/results?search_query=" ""])
                   ("Wikipedia" . [simple-query "wikipedia.org" "wikipedia.org/wiki/" ""])
                   ("Amazon" . [simple-query "www.amazon.fr" "www.amazon.fr/s?k=" ""])))
  :config (advice-add 'webjump-do-simple-query :override 'my/webjump-do-simple-query))

(use-package which-func
  :disabled t
  :demand t
  :custom (which-func-display 'header)
  :config (which-function-mode 1))

(use-package which-key
  :demand t
  :delight
  :config (which-key-mode 1))

(use-package whitespace
  :demand t
  :delight (whitespace-mode)
  :custom
  (whitespace-global-modes
   '(not shell-mode
         eshell-mode
         help-mode
         ibuffer-mode
         dired-mode
         occur-mode
         magit-mode
         erc-mode))
  (whitespace-style '(face trailing tabs)) ; lines-tail for long lines
  (whitespace-action '(auto-cleanup warn-if-read-only))
  :config (global-whitespace-mode 1))

(use-package windmove
  :demand t
  :config (windmove-default-keybindings))

(use-package window
  :demand t
  :preface
  (defun my/split-window-below ()
    "Split window horizontally and switch cursor inside it."
    (interactive)
    (split-window-below)
    (balance-windows)
    (other-window 1))

  (defun my/split-window-right ()
    "Split window vetically and switch cursor inside it."
    (interactive)
    (split-window-right)
    (balance-windows)
    (other-window 1))
  :bind (; ("C-<tab>" . next-buffer)
         ("M-o" . other-window)
         ([remap split-window-below] . my/split-window-below) ; "C-x 2"
         ([remap split-window-right] . my/split-window-right) ; "C-x 3"
         ;; Azerty keyboard adaptation
         ("C-x é" . my/split-window-below) ; "C-x 2"
         ("C-x \"" . my/split-window-right) ; "C-x 3"
         ("C-x &" . delete-other-windows) ; "C-x 1"
         ("C-x à" . delete-window)) ; "C-x 0"
  :custom (switch-to-buffer-obey-display-actions t)
  :config
  (add-to-list 'display-buffer-alist
               '(;; Matcher
                 (or (derived-mode . inferior-emacs-lisp-mode)
                     (derived-mode . backtrace-mode)
                     (derived-mode . info-mode)
                     "\\*\\(info\\|ielm\\|Backtrace\\)\\*")
                 ;; List of display functions
                 (display-buffer-reuse-mode-window
                  display-buffer-in-side-window)
                 ;; Parameters
                 (side . right)
                 (slot . 0)
                 (window-width . 1)
                 (body-function . select-window))))

(use-package winner
  :demand t
  :bind (("C-x w u" . winner-undo)
         ("C-x w r" . winner-redo))
  :custom (winner-dont-bind-my-keys t)
  :config (winner-mode 1))

(use-package xref
  :demand t
  :custom
  ;; consult-xref is enhanced with preview, but there are not many differences
  ;; with xref-show-definitions-completing-read
  (xref-show-definitions-function 'consult-xref)
  (xref-show-xrefs-function 'consult-xref)
  ;; (xref-show-definitions-function #'xref-show-definitions-completing-read)
  ;; (xref-show-xrefs-function #'xref-show-definitions-completing-read)
  (xref-search-program 'ripgrep)) ; used by project-find-regexp

(use-package xt-mouse
  :when (eq window-system nil)
  :demand t
  :config (xterm-mouse-mode 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; THIRD-PARTY PACKAGES ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package aggressive-indent
  :ensure t
  :demand t
  :delight
  :custom (aggressive-indent-sit-for-time 0)
  :config (global-aggressive-indent-mode 1))

(use-package ahk-mode :ensure t :demand t)

(use-package avy
  :ensure t
  :after paredit
  :bind (("C-j" . avy-goto-char-timer)
         (:map paredit-mode-map ("C-j" . avy-goto-char-timer))
         (:map org-mode-map ("C-j" . avy-goto-char-timer)))
  :custom (avy-timeout-seconds 0.3))

(use-package company
  :disabled t
  :ensure t
  :demand t
  :preface
  ;; don't use orderless with company
  (defun company-completion-styles (capf-fn &rest args)
    (let ((completion-styles '(substring)))
      (apply capf-fn args)))

  (defun my/company-eshell ()
    (setq-local company-backends '((company-yasnippet company-abbrev company-capf :separate))))

  (defun my/company-emacs-lisp ()
    (setq-local company-backends
                '(company-files
                  (company-yasnippet company-abbrev company-dabbrev-code company-keywords company-capf :separate))))

  (defun my/company-shell-script ()
    (setq-local company-backends
                '(company-files
                  (company-yasnippet company-abbrev company-dabbrev-code company-keywords company-capf :separate))))

  (defun my/company-erc ()
    (setq-local company-backends '(company-capf)
                company-idle-delay nil))
  :hook ((eshell-mode-hook . my/company-eshell)
         (emacs-lisp-mode-hook . my/company-emacs-lisp)
         (sh-mode-hook . my/company-shell-script)
         (erc-mode-hook . my/company-erc)
         ((prog-mode-hook text-mode-hook eshell-mode-hook) . company-mode))
  :bind ((:map company-mode-map
               ("<tab>" . company-indent-or-complete-common))
         (:map company-active-map
               ("<tab>" . company-complete-selection)))
  :custom
  ;; tweaking frontends so company pops up even for single candidate
  ;; instead of inline completion
  (company-frontends '(company-pseudo-tooltip-frontend
                       company-echo-metadata-frontend))
  (company-global-modes '(not org-mode))
  (company-dabbrev-code-everywhere t)
  (company-dabbrev-code-modes t)
  (company-dabbrev-code-other-buffers 'all)
  (company-dabbrev-downcase nil)
  (company-dabbrev-ignore-case t)
  (company-files-chop-trailing-slash nil)
  (company-selection-wrap-around t)
  (company-idle-delay 0)
  (company-minimum-prefix-length 2)
  (company-pseudo-tooltip-frontend t)
  (company-tooltip-align-annotations t)
  ;; (company-format-margin-function 'company-text-icons-margin)
  (company-text-icons-add-background t)
  (company-icon-margin 3)
  ;; (company-backends '(company-bbdb
  ;; company-files
  ;; (company-yasnippet company-abbrev company-dabbrev company-dabbrev-code company-capf company-keywords :separate)))
  :config (advice-add 'company-capf :around #'company-completion-styles))

(use-package company-quickhelp
  :disabled t
  :ensure t
  :demand t
  :custom (company-quickhelp-delay 0.2)
  :config (company-quickhelp-mode))

(use-package corfu
  :ensure t
  :demand t
  :preface
  (defun my/corfu-no-auto ()
    (setq-local corfu-auto nil))

  (defun corfu-send-shell (&rest _)
    "Send completion candidate when inside comint/eshell."
    (cond
     ((and (derived-mode-p 'eshell-mode) (fboundp 'eshell-send-input))
      (eshell-send-input))
     ((and (derived-mode-p 'comint-mode)  (fboundp 'comint-send-input))
      (comint-send-input))))
  :hook ((erc-mode-hook eshell-mode-hook) . my/corfu-no-auto)
  :custom
  (corfu-exclude-modes '(org-mode))
  (corfu-auto t)
  (corfu-auto-delay 0)
  (corfu-auto-prefix 3)
  (corfu-cycle t)
  (corfu-popupinfo-delay '(1 . 0.5))
  (corfu-preview-current nil)
  (corfu-on-exact-match nil)
  (corfu-min-width 50)
  (corfu-right-margin-width 0.5)
  :custom-face (corfu-popupinfo ((t (:inherit corfu-default :height 0.9))))
  :config
  (advice-add #'corfu-insert :after #'corfu-send-shell)
  ;; (corfu-echo-mode 0)
  (corfu-popupinfo-mode 1)
  (global-corfu-mode 1))

(use-package cape
  :ensure t
  :demand t
  :preface
  (defun my/cape-eshell ()
    (setq-local completion-at-point-functions
                (list
                 #'yasnippet-capf
                 ;; #'pcomplete-from-help
                 #'pcomplete-completions-at-point)))

  (defun my/cape-org ()
    (setq-local completion-at-point-functions
                (list (cape-capf-super
                       #'org-block-capf
                       #'yasnippet-capf
                       #'cape-emoji
                       #'cape-abbrev
                       #'cape-dabbrev))))

  (defun my/cape-emacs-lisp ()
    (setq-local completion-at-point-functions
                (list (cape-capf-super
                       #'yasnippet-capf
                       #'cape-abbrev
                       #'cape-dabbrev
                       #'elisp-completion-at-point
                       #'cape-keyword
                       #'cape-elisp-symbol)))
    (add-to-list 'completion-at-point-functions #'cape-file))

  (defun my/cape-sh ()
    (setq-local completion-at-point-functions
                (list (cape-capf-super
                       #'yasnippet-capf
                       #'cape-abbrev
                       #'cape-dabbrev
                       #'sh-completion-at-point-function
                       #'cape-keyword)))
    (add-to-list 'completion-at-point-functions #'cape-file))

  (defun my/cape-snippet ()
    (setq-local completion-at-point-functions
                (list (cape-capf-super
                       #'yasnippet-capf
                       #'cape-abbrev
                       #'cape-dabbrev))))
  :hook ((eshell-mode-hook . my/cape-eshell)
         (org-mode-hook . my/cape-org)
         (emacs-lisp-mode-hook . my/cape-emacs-lisp)
         (sh-mode-hook . my/cape-sh)
         (snippet-mode-hook . my/cape-snippet)))

(use-package consult
  :ensure t
  :demand t
  :preface
  (defun consult-info-emacs ()
    "Search through Emacs info pages."
    (interactive)
    (consult-info "emacs" "efaq" "elisp" "cl" "compat"))

  (defun consult-line-symbol-at-point ()
    "Starts consult-line search with symbol at point"
    (interactive)
    (consult-line (thing-at-point 'symbol)))

  (defun my/search-erc-logs-consult ()
    "Lookup for any given term in ERC logs."
    (interactive)
    (consult-grep erc-log-channels-directory))
  :bind (("C-c l"                     . consult-line-symbol-at-point)
         ([remap info]                . consult-info-emacs)
         ([remap yank-pop]            . consult-yank-pop)
         ([remap set-fill-column]     . consult-flymake)
         ([remap count-lines-page]    . consult-locate)
         ([remap goto-line]           . consult-goto-line)
         ([remap bookmark-jump]       . consult-bookmark)
         ([remap switch-to-buffer]    . consult-buffer)
         ([remap indent-rigidly]      . consult-imenu-multi)
         ([remap find-file-read-only] . consult-recent-file)
         ([remap compose-mail]        . consult-mark)
         ([remap jump-to-register]    . consult-register)
         ([remap point-to-register]   . consult-register-store)
         (:map dired-mode-map
               ("C-c r" . consult-ripgrep)
               ("C-c f" . consult-fd)))
  :custom
  (consult-find-args "find .")
  (consult-fd-args '((if (executable-find "fdfind" 'remote) "fdfind" "fd") "--full-path --color=never --follow --hidden"))
  (consult-grep-args "grep --null --line-buffered --color=never --ignore-case --with-filename --line-number --binary-file=without-match --recursive --exclude-dir=.git")
  (consult-ripgrep-args "rg --null --line-buffered --color=never --max-columns=1000 --path-separator / --smart-case --no-heading --with-filename --line-number --search-zip  --follow --hidden")
  (consult-git-grep-args "git --no-pager grep --null --color=never --ignore-case --extended-regexp --line-number -I")
  (consult-preview-key "C-<return>")
  (consult-buffer-sources '(consult-source-hidden-buffer
                            consult-source-modified-buffer
                            consult-source-buffer
                            consult-source-project-buffer-hidden
                            consult-source-project-recent-file-hidden
                            consult-source-erc
                            consult-source-gnus))
  :config
  (consult-customize consult-line-symbol-at-point :preview-key 'any :prompt "Search: ")

  ;; ? to show narrowing keys
  (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; ERC filtering
  (autoload 'erc-buffer-list "erc")

  (defvar consult-source-erc
    (list :name     "ERC"
          :hidden   t
          :narrow   ?e
          :category 'buffer
          :state    #'consult--buffer-state
          ;; Either use erc-buffer-list or the :mode attribute
          ;; :items    '(lambda () (mapcar #'buffer-name (erc-buffer-list)))
          :items '(lambda () (consult--buffer-query :mode 'erc-mode :as #'buffer-name))))

  ;; ERC automatic narrowing
  (defun consult-erc-narrow ()
    (when (and (eq this-command #'consult-buffer)
               (string-equal "ERC" (alist-get 'name (alist-get 'current-tab (tab-bar-tabs)))))
      (setq unread-command-events (append unread-command-events (list ?e 32)))))

  (add-hook 'minibuffer-setup-hook #'consult-erc-narrow)

  ;; Gnus filtering
  (defvar consult-source-gnus
    (list :name     "Gnus"
          :hidden   t
          :narrow   ?g
          :category 'buffer
          :state    #'consult--buffer-state
          :items    '(lambda () (consult--buffer-query :mode '(gnus-server-mode gnus-browse-mode gnus-group-mode gnus-article-mode gnus-summary-mode message-mode) :as #'buffer-name))))

  ;; Gnus automatic narrowing
  (defun consult-gnus-narrow ()
    (when (and (eq this-command #'consult-buffer)
               (string-equal "Gnus" (alist-get 'name (alist-get 'current-tab (tab-bar-tabs)))))
      (setq unread-command-events (append unread-command-events (list ?g 32)))))

  (add-hook 'minibuffer-setup-hook #'consult-gnus-narrow))

(use-package consult-yasnippet
  :disabled t
  :ensure t
  :after consult
  :bind ("C-x y" . consult-yasnippet))

(use-package delight :ensure t :demand t)

(use-package diff-hl
  :ensure t
  :demand t
  :hook ((dired-mode-hook . diff-hl-dired-mode)
         (magit-pre-refresh-hook . diff-hl-magit-pre-refresh)
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
  :hook (dired-after-readin-hook . dired-git-info-auto-enable)
  :custom (dgi-auto-hide-details-p nil)
  :config
  ;; fix for subfolder without file bug
  ;; waiting for https://github.com/clemera/dired-git-info/pull/16
  ;; to be merged
  (define-advice dgi--get-dired-files-length
      (:around (fun &rest args))
    (or (apply fun args)
        '(0))))

(use-package diredfl
  :ensure t
  :after dired
  :config (diredfl-global-mode 1))

(use-package dired-rsync
  :ensure t
  :demand t
  :config
  ;; (setopt dired-rsync-options "-az --info=progress2")
  ;; (setopt dired-rsync-command "rsync.exe")
  (when (string-equal system-type 'windows-nt)
    ;; (setopt dired-rsync-options "")
    (setopt dired-rsync-command "rsync-win.exe")))

(use-package dired-rsync-transient
  :ensure t
  :demand t
  :bind (:map dired-mode-map
              ("C-c C-x" . dired-rsync-transient)))

(use-package dired-subtree
  :ensure t
  :demand t
  :bind ((:map dired-mode-map ([remap indent-for-tab-command] . #'dired-subtree-toggle)))) ; <TAB>

(use-package docker
  :ensure t
  :demand t
  :bind ("C-c d" . docker)
  :custom (docker-show-messages nil)
  :config
  (add-to-list 'display-buffer-alist
               '(;; Matcher
                 "\\*docker"
                 ;; List of display functions
                 (display-buffer-reuse-window
                  display-buffer-use-some-window)
                 ;; Parameters
                 (body-function . select-window))))

(use-package dockerfile-mode :ensure t)

(use-package drag-stuff
  :ensure t
  :demand t
  :delight
  :bind (("H-f" . drag-stuff-right)
         ("H-b" . drag-stuff-left)
         ("M-p" . drag-stuff-up)
         ("M-n" . drag-stuff-down))
  :config (drag-stuff-global-mode 1))

(use-package dumb-jump
  :ensure t
  :demand t
  :custom (xref-show-definitions-function #'xref-show-definitions-completing-read)
  :config (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

(use-package elfeed
  :disabled t
  :ensure t
  :demand t
  :custom (elfeed-search-filter "@12-months-ago")
  :config (load-file (expand-file-name "feeds.el" user-emacs-directory)))

(use-package elfeed-summary
  :disabled t
  :ensure t
  :demand t
  :bind ("<f2>" . elfeed-summary)
  :custom
  (elfeed-summary-width 95)
  (elfeed-summary-default-filter "@12-months-ago ") ; this has to end with space
  (elfeed-summary-settings
   '((group
      (:title . "Blogs")
      (:elements
       (group
        (:title . "IT")
        (:elements
         (query . (and blog it))))
       (group
        (:title . "InfoSec")
        (:elements
         (query . (and blog infosec))))
       (group
        (:title . "Geopolitics")
        (:elements
         (query . (and blog geopolitics))))
       (group
        (:title . "OSINT")
        (:elements
         (query . (and blog osint))))
       (group
        (:title . "Emacs")
        (:elements
         (query . (and blog emacs))))))
     (group
      (:title . "YouTube")
      (:elements
       (group
        (:title . "IT")
        (:elements
         (query . (and youtube it))))
       (group
        (:title . "InfoSec")
        (:elements
         (query . (and youtube infosec))))
       (group
        (:title . "Emacs")
        (:elements
         (query . (and youtube emacs))))
       (group
        (:title . "Geopolitics")
        (:elements
         (query . (and youtube geopolitics))))
       (group
        (:title . "Tennis")
        (:elements
         (query . (and youtube tennis))))
       (group
        (:title . "Dance")
        (:elements
         (query . (and youtube dance))))
       (group
        (:title . "Other")
        (:elements
         (query . (and youtube other))))))))
  :config
  (add-to-list 'display-buffer-alist
               '(;; Matcher
                 (or (derived-mode . elfeed-sumary-mode)
                     (derived-mode . elfeed-search-mode)
                     "\\*\\(elfeed-summary\\|elfeed-search\\)\\*")
                 ;; List of display functions
                 (display-buffer-reuse-window
                  display-buffer-use-some-window)
                 ;; Parameters
                 (body-function . select-window)))

  (setq elfeed-summary--search-show-read t))

(use-package elfeed-tube
  :ensure t
  :after elfeed
  :config (elfeed-tube-setup)
  :bind (:map elfeed-show-mode-map
              ("F" . elfeed-tube-fetch)
              ([remap save-buffer] . elfeed-tube-save)
              :map elfeed-search-mode-map
              ("F" . elfeed-tube-fetch)
              ([remap save-buffer] . elfeed-tube-save)))

(use-package elfeed-tube-mpv :ensure t :after elfeed-tube)

(use-package embark
  :ensure t
  :init (setq prefix-help-command #'embark-prefix-help-command)
  :bind (("C-." . embark-act)         ;; pick some comfortable binding
         ("C-;" . embark-dwim))        ;; good alternative: M-.
  :custom (embark-indicators '(embark--vertico-indicator embark-minimal-indicator embark-highlight-indicator embark-isearch-highlight-indicator))
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '(;; Matcher
                 (or (derived-mode . embark-collect-mode)
                     "\\`\\*Embark Collect \\(Live\\|Completions\\)\\*")
                 ;; List of display functions
                 nil
                 ;; Parameters
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :ensure t ; only need to install it, embark loads it after consult if found
  :hook (embark-collect-mode-hook . consult-preview-at-point-mode))

(use-package erc-hl-nicks
  :ensure t
  :after erc
  :config (add-to-list 'erc-hl-nicks-skip-faces "erc-current-nick-face" t))

(use-package exec-path-from-shell
  :when (memq window-system '(mac ns x))
  :ensure t
  :init (setopt exec-path-from-shell-arguments '("-l"))
  :config (exec-path-from-shell-initialize))

(use-package expand-region
  :ensure t
  :demand t
  :bind (("C-:" . er/expand-region)
         ("C-M-=" . er/contract-region))
  :custom (expand-region-smart-cursor t))

(use-package flymake-shellcheck
  :ensure t
  :after flymake
  :commands flymake-shellcheck-load
  :init (add-hook 'sh-mode-hook 'flymake-shellcheck-load))

(use-package forge
  :ensure t
  :after magit
  :custom (forge-owned-accounts '(("grolongo"))))

(use-package gnus-notify
  :ensure t
  :demand t
  :vc (:url "https://github.com/grolongo/gnus-notify"))

(use-package goto-chg
  :ensure t
  :demand t
  :bind ("C-," . 'goto-last-change))

(use-package gptel
  :disabled t
  :ensure t
  :demand t
  :custom (gptel-default-mode 'org-mode))

(use-package gt
  :ensure t
  :demand t
  :custom
  (gt-langs '(en fr ru uk))
  (gt-buffer-render-follow-p t)
  :config
  (setq gt-default-translator
        (gt-translator
         :engines (list (gt-google-engine))
         :render  (gt-buffer-render))))

(use-package highlight-indent-guides
  :disabled t
  :ensure t
  :demand t
  :delight
  :hook (prog-mode-hook . highlight-indent-guides-mode)
  :custom
  (highlight-indent-guides-method 'character)
  (highlight-indent-guides-delay 0)
  (highlight-indent-guides-responsive 'top))

(use-package kind-icon
  :disabled t
  :ensure t
  :demand t
  :custom
  (kind-icon-blend-background t)
  (kind-icon-default-face 'corfu-default) ; only needed with blend-background
  (kind-icon-use-icons nil)
  (kind-icon-extra-space t)
  (kind-icon-mapping
   '((array          "a"   :icon "symbol-array"       :face font-lock-type-face              :collection "vscode")
     (boolean        "b"   :icon "symbol-boolean"     :face font-lock-builtin-face           :collection "vscode")
     (color          "#"   :icon "symbol-color"       :face success                          :collection "vscode")
     (command        "cm"  :icon "chevron-right"      :face default                          :collection "vscode")
     (constant       "co"  :icon "symbol-constant"    :face font-lock-constant-face          :collection "vscode")
     (class          "c"   :icon "symbol-class"       :face font-lock-type-face              :collection "vscode")
     (constructor    "cn"  :icon "symbol-method"      :face font-lock-function-name-face     :collection "vscode")
     (enum           "e"   :icon "symbol-enum"        :face font-lock-builtin-face           :collection "vscode")
     (enummember     "em"  :icon "symbol-enum-member" :face font-lock-builtin-face           :collection "vscode")
     (enum-member    "em"  :icon "symbol-enum-member" :face font-lock-builtin-face           :collection "vscode")
     (event          "ev"  :icon "symbol-event"       :face font-lock-warning-face           :collection "vscode")
     (field          "fd"  :icon "symbol-field"       :face font-lock-variable-name-face     :collection "vscode")
     (file           "f"   :icon "symbol-file"        :face font-lock-string-face            :collection "vscode")
     (folder         "d"   :icon "folder"             :face font-lock-doc-face               :collection "vscode")
     (function       "f"   :icon "symbol-method"      :face font-lock-function-name-face     :collection "vscode")
     (interface      "if"  :icon "symbol-interface"   :face font-lock-type-face              :collection "vscode")
     (keyword        "kw"  :icon "symbol-keyword"     :face font-lock-keyword-face           :collection "vscode")
     (macro          "mc"  :icon "lambda"             :face font-lock-keyword-face)
     (magic          "ma"  :icon "lightbulb-autofix"  :face font-lock-builtin-face           :collection "vscode")
     (method         "m"   :icon "symbol-method"      :face font-lock-function-name-face     :collection "vscode")
     (module         "{"   :icon "file-code-outline"  :face font-lock-preprocessor-face)
     (numeric        "nu"  :icon "symbol-numeric"     :face font-lock-builtin-face           :collection "vscode")
     (operator       "op"  :icon "symbol-operator"    :face font-lock-comment-delimiter-face :collection "vscode")
     (param          "pa"  :icon "gear"               :face default                          :collection "vscode")
     (property       "pr"  :icon "symbol-property"    :face font-lock-variable-name-face     :collection "vscode")
     (reference      "rf"  :icon "library"            :face font-lock-variable-name-face     :collection "vscode")
     (snippet        "S"   :icon "symbol-snippet"     :face font-lock-string-face            :collection "vscode")
     (string         "s"   :icon "symbol-string"      :face font-lock-string-face            :collection "vscode")
     (struct         "%"   :icon "symbol-structure"   :face font-lock-variable-name-face     :collection "vscode")
     (text           "tx"  :icon "symbol-key"         :face font-lock-doc-face               :collection "vscode")
     (typeparameter  "tp"  :icon "symbol-parameter"   :face font-lock-type-face              :collection "vscode")
     (type-parameter "tp"  :icon "symbol-parameter"   :face font-lock-type-face              :collection "vscode")
     (unit           "u"   :icon "symbol-ruler"       :face font-lock-constant-face          :collection "vscode")
     (value          "v"   :icon "symbol-enum"        :face font-lock-builtin-face           :collection "vscode")
     (variable       "va"  :icon "symbol-variable"    :face font-lock-variable-name-face     :collection "vscode")
     (t              "."   :icon "question"           :face font-lock-warning-face           :collection "vscode")))
  :config
  (plist-put kind-icon-default-style :height 0.9)
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package lua-mode
  :ensure t
  :demand t)

(use-package magit
  :ensure t
  :demand t
  :hook (after-save-hook . magit-after-save-refresh-status)
  :bind (("C-x g" . magit-status)
         ([remap magit-section-cycle] . tab-next))
  :custom (magit-format-file-function #'magit-format-file-nerd-icons))

(use-package marginalia
  :ensure t
  :demand t
  :custom (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :config (marginalia-mode 1))

(use-package multiple-cursors
  :ensure t
  :demand t
  ;; C-' to hide unmatched lines
  :bind (([remap reposition-window] . mc/mark-next-like-this)
         ("C-c m a" . mc/mark-all-words-like-this))
  :custom
  (mc/always-repeat-command t)
  (mc/always-run-for-all t)
  :config
  (add-hook 'multiple-cursors-mode-enabled-hook (lambda () (corfu-mode -1)))
  (add-hook 'multiple-cursors-mode-disabled-hook (lambda () (corfu-mode 1))))

(use-package nerd-icons
  ;; M-x nerd-icons-install-fonts
  :ensure t
  :demand t
  :config (add-to-list 'nerd-icons-mode-icon-alist '(fundamental-mode nerd-icons-mdicon "nf-md-file")))

(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :config (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package nerd-icons-dired
  :ensure t
  :demand t
  :delight
  :hook (dired-mode-hook . nerd-icons-dired-mode))

(use-package nerd-icons-grep
  :ensure t
  :demand t
  :config (nerd-icons-grep-mode))

(use-package nerd-icons-ibuffer
  :ensure t
  :demand t
  :hook (ibuffer-mode-hook . nerd-icons-ibuffer-mode))

(use-package nerd-icons-mode-line
  :ensure t
  :demand t
  :vc (:url "https://github.com/grolongo/nerd-icons-mode-line")
  :config
  (when (eq system-type 'gnu/linux)
    (setopt nerd-icons-mode-line-v-adjust 0.0))
  (nerd-icons-mode-line-global-mode t))

(use-package tab-line-nerd-icons
  :ensure t
  :after tab-line
  :custom (tab-line-nerd-icons-space-width 0.3)
  :config (tab-line-nerd-icons-global-mode))

(use-package nerd-icons-xref
  :ensure t
  :demand t
  :config (nerd-icons-xref-mode))

(use-package orderless
  :ensure t
  :demand t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  ;; (completion-category-overrides '((eglot (styles orderless))))
  (completion-category-overrides nil))

(use-package org-appear
  :ensure t
  :demand t
  :hook (org-mode-hook . org-appear-mode)
  :custom (org-appear-autolinks t))

(use-package org-block-capf
  :ensure t
  :demand t
  :vc (:url "https://github.com/xenodium/org-block-capf")
  :custom
  (org-block-capf-edit-style 'inline)
  (org-block-capf-auto-indent nil))

(use-package org-table-highlight
  :ensure t
  :demand t
  :delight
  :hook (org-mode-hook . org-table-highlight-mode)
  :custom (org-table-highlight-metadata-file (expand-file-name "org-table-highlight-metadata.el" user-emacs-directory))
  :config (add-hook 'after-init-hook #'org-table-highlight--load-metadata))

(use-package paredit
  :ensure t
  :demand t
  :delight
  :hook (emacs-lisp-mode-hook . #'enable-paredit-mode))

(use-package powershell
  ;; M-x powershell-install-langserver for Eglot support
  :ensure t
  :demand t)

(use-package project-git-autofetch
  :ensure t
  :demand t
  :vc (:url "https://github.com/grolongo/project-git-autofetch")
  :delight
  :hook (project-git-autofetch-after-successful-fetch-hook . magit-refresh-all)
  :custom
  (project-git-autofetch-projects 'open)
  (project-git-autofetch-initial-delay 2)
  (project-git-autofetch-interval 15)
  :config (project-git-autofetch-mode 1))

(use-package rainbow-delimiters
  :ensure t
  :demand t
  :hook (prog-mode-hook . rainbow-delimiters-mode))

(use-package rainbow-mode
  :ensure t
  :demand t
  :delight
  :hook ((prog-mode-hook text-mode-hook) . rainbow-mode)
  :custom (rainbow-x-colors nil))

(use-package suggest :ensure t :demand t)

(use-package symbol-overlay
  :ensure t
  :demand t
  :delight
  :hook ((text-mode-hook prog-mode-hook fundamental-mode-hook) . symbol-overlay-mode)
  :custom (symbol-overlay-idle-time 0.2))

(use-package systemd :ensure t :demand t)

(use-package tramp-theme
  :ensure t
  :demand t
  :config (load-theme 'tramp :no-confirm))

(use-package verb
  :disabled t
  :ensure t
  :after org
  :config (define-key org-mode-map (kbd "C-c C-r") verb-command-map))

(use-package vertico
  :ensure t
  :demand t
  :custom
  (vertico-resize 'fixed)
  (vertico-group-format nil)
  (vertico-cycle t)
  (vertico-scroll-margin 0)
  :custom-face (vertico-group-title ((nil (:slant normal :weight bold))))
  :config
  ;; cursor on the left
  (defvar +vertico-current-arrow t)

  (cl-defmethod vertico--format-candidate :around
    (cand prefix suffix index start &context ((and +vertico-current-arrow
                                                   (not (bound-and-true-p vertico-flat-mode)))
                                              (eql t)))
    (setq cand (cl-call-next-method cand prefix suffix index start))
    (if (bound-and-true-p vertico-grid-mode)
        (if (= vertico--index index)
            (concat #(">" 0 1 (face vertico-current)) cand)
          (concat #("_" 0 1 (display " ")) cand))
      (if (= vertico--index index)
          (concat
           #(" " 1 0 (display (left-fringe right-triangle vertico-current)))
           cand)
        cand)))

  (vertico-multiform-mode t)
  (add-to-list 'vertico-multiform-categories '(embark-keybinding grid))

  (vertico-mouse-mode t)
  (vertico-mode 1))

(use-package whole-line-or-region
  :ensure t
  :demand t
  :delight (whole-line-or-region-local-mode)
  :config (whole-line-or-region-global-mode t))

(use-package winpulse
  :ensure t
  :demand t
  :vc (:url "https://github.com/xenodium/winpulse")
  :custom (winpulse-duration 0.4)
  :config (winpulse-mode 1))

(use-package yaml-mode
  :ensure t
  :demand t
  :config
  (add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
  (add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode)))

(use-package yasnippet
  :ensure t
  :delight (yas-minor-mode)
  :init (setopt yas-alias-to-yas/prefix-p nil)
  :preface
  (defun my/disable-yasnippet ()
    "Disable yas-minor-mode."
    (yas-minor-mode -1))
  :hook (org-capture-mode-hook . my/disable-yasnippet)
  :custom
  (yas-snippet-dirs (list (expand-file-name "templates/yasnippets" user-emacs-directory)))
  (yas-indent-line 'fixed)
  (yas-new-snippet-default "# -*- mode: snippet -*-\n\
# uuid: `(replace-regexp-in-string \"\n\\'\" \"\" (shell-command-to-string \"uuidgen\"))`\
# key: ${1:${2:$(yas--key-from-desc yas-text)}}\n\
# name: $2\n\
# --\n$0`(yas-escape-text yas-selected-text)`")
  :config (yas-global-mode 1))

(use-package yasnippet-capf :ensure t :demand t)

;;;;;;;;;;;;;;;;;;;;;;
;;; LOCAL PACKAGES ;;;
;;;;;;;;;;;;;;;;;;;;;;

(use-package extra :load-path "lisp/" :demand t)
;; (use-package nerd-icons-mode-line-v2 :load-path "lisp/" :demand t)
;; (use-package gnus-notify :load-path "~/git/gnus-notify/" :demand t)
;; (use-package project-git-autofetch :load-path "~/git/project-git-autofetch/" :demand t)
;; (use-package nerd-icons-mode-line :load-path "~/git/nerd-icons-mode-line/" :demand t)

;;; init.el ends here
