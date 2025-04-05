(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
    "straight/repos/straight.el/bootstrap.el"
    (or (bound-and-true-p straight-base-dir)
        user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
    (url-retrieve-synchronously
     "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
     'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq straight-use-package-by-default 1)

; set font and fix annoyances
(use-package emacs
  :ensure nil
  :hook
  (prog-mode . (lambda ()
                 (setq display-line-numbers 'relative)
                 (indent-tabs-mode -1)))
  :init
  (set-face-attribute 'default nil :font "Afio" :height 120)
  (add-to-list 'default-frame-alist '(font . "Afio"))
  (add-to-list 'default-frame-alist '(height . "140"))
  :custom
  (inhibit-startup-message t)
  (initial-scratch-message "")
  (startup-screen-inhibit-startup-screen t)
  (create-lockfiles nil)   ; No backup files
  (make-backup-files nil)  ; No backup files
  (backup-inhibited t)     ; No backup files
  (pixel-scroll-precision-mode t)
  (pixel-scroll-precision-use-momentum nil)
  (tab-always-indent 'complete)
  (tab-width 4)
  (tab-bar-close-button-show nil)
  (tab-bar-new-button-show nil)
  (tab-bar-tab-hints t)
  (treesit-font-lock-level 4)
  (truncate-lines t)
  (undo-limit (* 13 160000))
  (undo-strong-limit (* 13 240000))
  (undo-outer-limit (* 13 24000000))
  (use-dialog-box nil)
  (use-file-dialog nil)
  (use-short-answers t)
  (visible-bell nil)
  :init
  (global-auto-revert-mode 1)
  (when scroll-bar-mode
    (scroll-bar-mode -1))
  (ido-mode t)
  (menu-bar-mode -1)
  (tool-bar-mode -1))

(use-package compile
  :ensure nil
  :hook
  ((compilation-start . (lambda () (setq compilation-in-progress nil))))
  :custom
  (compilation-always-kill t)
  (compilation-scroll-output t)
  (ansi-color-for-compilation-mode t)
  :config
  (add-hook 'compilation-filter-hook #'ansi-color-compilation-filter))

(use-package whitespace
  :ensure nil
  :defer t
  :hook (before-save . whitespace-cleanup))

(use-package minibuffer
  :ensure nil
  :straight nil
  :custom
  (completion-styles '(substring basic))
  (completion-ignore-case t)
  (completion-show-help t)
  (completions-max-height 20)
  (completions-format 'one-column)
  (enable-recursive-minibuffers t)
  (read-file-name-completion-ignore-case t)
  (read-buffer-completion-ignore-case t)
  :config
  ;; Keep the cursor out of the read-only portions of the.minibuffer
  (setq minibuffer-prompt-properties
        '(read-only t intangible t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Keep minibuffer lines unwrapped, long lines like on M-y will be truncated
  (add-hook 'minibuffer-setup-hook
            (lambda () (setq truncate-lines t)))

  (minibuffer-depth-indicate-mode 1)
  (minibuffer-electric-default-mode 1))

(use-package elec-pair
  :ensure nil
  :defer
  :hook (after-init . electric-pair-mode))

(use-package paren
  :ensure nil
  :hook (after-init . show-paren-mode)
  :custom
  (show-paren-delay 0)
  (show-paren-style 'mixed)
  (show-paren-context-when-offscreen t))

                    ; add vim keybindings
(setq evil-want-keybinding nil)
(setq evil-want-C-u-scroll 1)
(use-package goto-chg)
(use-package evil
  :init
  (evil-mode 1))

(use-package evil-commentary
  :init (evil-commentary-mode))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package evil-collection
  :init
  (evil-collection-init))

                    ; which key
(use-package which-key
  :ensure nil
  :commands (which-key-mode)
  :init
  (which-key-mode))

                    ; add LSP
(use-package flymake
  :init
  (add-hook 'prog-mode-hook
            (lambda ()
              ;; (unless (string-match-p (rx (and ".el" eol)) (buffer-file-name (current-buffer)))
                (flymake-mode)
                (evil-local-set-key 'normal (kbd "]d") 'flymake-goto-next-error)
                (evil-local-set-key 'normal (kbd "[d") 'flymake-goto-prev-error)))); )

(use-package eglot
  :init
  (add-hook 'prog-mode-hook (lambda ()
                  (eglot-ensure)
                  (evil-local-set-key 'normal (kbd "SPC c a") 'eglot-code-actions)
                  (evil-local-set-key 'normal (kbd "SPC c o") 'eglot-code-actions-organize-imports)
                  (evil-local-set-key 'normal (kbd "SPC c r") 'eglot-rename)
                  (evil-local-set-key 'normal (kbd "SPC c f") 'eglot-format))))

(use-package company
  :ensure t
  :commands (global-company-mode)
  :init
  (global-company-mode)
  :custom
  (company-tooltip-align-annotations 't)
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.1))

(use-package eldoc
  :init
  (global-eldoc-mode))

                    ; git support
(use-package vc)
(use-package magit)

                    ; set the theme
(use-package catppuccin-theme
  :init
  (load-theme 'catppuccin :no-confirm))

(use-package emacs-solo-mode-line
  :ensure nil
  :no-require t
  :defer t
  :straight nil
  :init
  ;; Shorten big branches names
  (defun emacs-solo/shorten-vc-mode (vc)
    "Shorten VC string to at most 20 characters.
 Replacing `Git-' with a branch symbol."
    (let* ((vc (replace-regexp-in-string "^ Git[:-]" "  " vc))) ;; Options:   ᚠ ⎇
      (if (> (length vc) 20)
          (concat (substring vc 0 20) "…")
        vc)))

  ;; Formats Modeline
  (setq-default mode-line-format
                '("%e" "  "
                  ;; (:propertize " " display (raise +0.1)) ;; Top padding
                  ;; (:propertize " " display (raise -0.1)) ;; Bottom padding
                  (:propertize "λ  " face font-lock-keyword-face)

                  (:propertize
                   ("" mode-line-mule-info mode-line-client mode-line-modified mode-line-remote))

                  mode-line-frame-identification
                  mode-line-buffer-identification
                  "   "
                  mode-line-position
                  mode-line-format-right-align
                  "  "
                  (project-mode-line project-mode-line-format)
                  "  "
                  (vc-mode (:eval (emacs-solo/shorten-vc-mode vc-mode)))
                  "  "
                  mode-line-modes
                  mode-line-misc-info
                  "  ")
                project-mode-line t
                mode-line-buffer-identification '(" %b")
                mode-line-position-column-line-format '(" %l:%c"))

  ;; Provides the Diminish functionality
  (defvar emacs-solo-hidden-minor-modes
    '(abbrev-mode
      eldoc-mode
      flyspell-mode
      flymake-mode
      evil-collection-unimpaired-mode
      smooth-scroll-mode
      outline-minor-mode
      which-key-mode))

  (defun emacs-solo/purge-minor-modes ()
    (interactive)
    (dolist (x emacs-solo-hidden-minor-modes nil)
      (let ((trg (cdr (assoc x minor-mode-alist))))
        (when trg
          (setcar trg "")))))

  (add-hook 'after-change-major-mode-hook 'emacs-solo/purge-minor-modes))

(use-package vertico
  :init
  (vertico-mode))

(require 'vc)
(defun user/affe-find-root ()
  (interactive)
  (affe-find (vc-root-dir)))

(defun user/affe-find-here ()
  (interactive)
  (affe-find default-directory))

; This is the helix/nvim-telescope replacement cheatcode together with vertico
(use-package affe
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :config
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
  :preview-key '(:debounce 0.4 any))
  :bind (:map evil-normal-state-map
              ("SPC f" . user/affe-find-root)
              ("SPC F" . user/affe-find-here)
              ("SPC s" . consult-imenu)
              ("SPC b" . consult-buffer)
              ("C-p" . affe-grep)
              ("SPC d" . consult-flymake)))

;; FILETYPES
(use-package treesit-langs
  :straight (treesit-langs :type git :host github :repo "emacs-tree-sitter/treesit-langs"))

(require 'treesit-langs)
(treesit-langs-major-mode-setup)

(use-package clojure-mode)
