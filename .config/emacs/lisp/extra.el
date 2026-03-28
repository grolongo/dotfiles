;;; extra.el --- -*- lexical-binding: t -*-

;;; Commentary:
;; extra code

;;; Code:

(defun my/disable-ipv6 ()
  "Disable ipv6 using sysctl on Linux."
  (interactive)
  (if (eq system-type 'gnu/linux)
      (progn
        (call-process "sysctl" nil nil nil "-w" "net.ipv6.conf.all.disable_ipv6=0")
        (call-process "sysctl" nil nil nil "-w" "net.ipv6.conf.default.disable_ipv6=0")
        (call-process "sysctl" nil nil nil "-w" "net.ipv6.conf.lo.disable_ipv6=0"))
    (error "Not running Linux")))

(provide 'extra)
;;; extra.el ends here
