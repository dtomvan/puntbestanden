(setq gc-cons-threshold most-positive-fixnum
	  gc-cons-percentage 0.6
	  vc-handled-backends '(Git))

;; Hack to avoid being flashbanged
(defun emacs-solo/avoid-initial-flash-of-light ()
  "Avoid flash of light when starting Emacs."
  (setq mode-line-format nil)
  (set-face-attribute 'default nil :background "#292D3E" :foreground "#292D3E"))

(emacs-solo/avoid-initial-flash-of-light)

;; Better Window Management handling
(setq frame-resize-pixelwise t
	  frame-inhibit-implied-resize t
	  frame-title-format '("Emacs"))

(setq inhibit-compacting-font-caches t)

;; Disables unused UI Elements
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)

(setq frame-inhibit-implied-resize t
	  frame-resize-pixelwise t)

(provide 'early-init)
;;; early-init.el ends here
