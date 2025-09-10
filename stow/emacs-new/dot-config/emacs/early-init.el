(setq frame-resize-pixelwise t
      frame-inhibit-implied-resize 'force
      frame-title-format '("%b")
      ring-bell-function 'ignore
      use-dialog-box t ; only for mouse events, which I seldom use
      use-file-dialog nil
      use-short-answers t
      inhibit-splash-screen t
      inhibit-startup-screen t
      inhibit-x-resources t
      inhibit-startup-echo-area-message user-login-name ; read the docstring
      inhibit-startup-buffer-menu t)

;; Disable the various graphical modes that I do not want, should save
;; some time when used in early-init
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode -1)
(fringe-mode 0)

;; Start as fullscreen
(modify-all-frames-parameters
 `((fullscreen . fullboth)))

;; Stolen from prot, but cut down. This just sets it to the dark
;; modus-vivendi colors, so it can either load a light theme or the
;; rest of the dark theme. I don't mind the "dark flash", just the
;; light flash.
(setq mode-line-format nil)
(set-face-attribute 'default nil :background "#0d0e1c" :foreground "#ffffff")
(set-face-attribute 'mode-line nil :background "#292d48" :foreground "#969696" :box "#979797")

;; Temporarily increase the garbage collection threshold.  These
;; changes help shave off about half a second of startup time.  The
;; `most-positive-fixnum' is DANGEROUS AS A PERMANENT VALUE.  See the
;; `emacs-startup-hook' a few lines below for what I actually use.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.5)

;; Same idea as above for the `file-name-handler-alist' with regard to
;; startup speed optimisation.  Here I am storing the default value
;; with the intent of restoring it via the `emacs-startup-hook'.
;; EDIT 2025-08-23: you cannot do it for `vc-handled-backends' anymore
;; if you use it inside of init.el to clone packages with
;; `(use-package :vc)'
(defvar prot-emacs--file-name-handler-alist file-name-handler-alist)

(setq file-name-handler-alist nil)

(add-hook 'emacs-startup-hook
	  (lambda ()
	    (setq gc-cons-threshold (* 100 100 8)
		  gc-cons-percentage 0.1
		  file-name-handler-alist prot-emacs--file-name-handler-alist)))

;; Initialise installed packages at this early stage, by using the
;; available cache.  I had tried a setup with this set to nil in the
;; early-init.el, but (i) it ended up being slower and (ii) various
;; package commands, like `describe-package', did not have an index of
;; packages to work with, requiring a `package-refresh-contents'.
(setq package-enable-at-startup t)
