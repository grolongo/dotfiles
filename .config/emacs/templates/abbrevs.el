;;; Abbrev --- definitions
;;; Commentary:
;;; list of abbrev definitions for global and specific modes

;;; Code:

;; GLOBAL
(clear-abbrev-table global-abbrev-table)

(define-abbrev-table 'global-abbrev-table
  '(("bc" "because")
    ("hw" "however")
    ("zwspace" "​")))

;; ESHELL
(when (boundp 'eshell-mode-abbrev-table)
  (clear-abbrev-table eshell-mode-abbrev-table))

(define-abbrev-table 'eshell-mode-abbrev-table
  '(("snipExif" "" snip-exif-remove-meta)
    ("snipFlip" "" snip-flip-image)))

(provide 'abbrevs)

;;; abbrevs.el ends here
