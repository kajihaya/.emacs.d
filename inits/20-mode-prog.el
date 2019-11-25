;;; 20-mode-prog.el --- プログラム用メジャーモード設定
;;; Commentary:

;;; Code:
;; lsp-mode
(use-package lsp-mode
  :commands lsp
  :custom ((lsp-auto-guess-root t)
           (lsp-document-sync-method 'incremental) ;; always send incremental document
           (lsp-response-timeout 5)
           (lsp-enable-completion-at-point nil)
           (lsp-inhibit-message t)
           (lsp-message-project-root-warning t)
           ;; dont use flymake and flycheck on lsp-mode and lsp-ui.
           (lsp-prefer-flymake nil)
           (create-lockfiles nil))
  :hook ((dart-mode . lsp)))

(use-package lsp-ui
  :after lsp-mode
  :bind
  (:map lsp-mode-map
        ("M-." . lsp-ui-peek-find-references)
        ("M-?" . lsp-ui-peek-find-definitions)
        ("C-c d"   . toggle-lsp-ui-doc))
  :custom ((scroll-margin 0)
           (lsp-ui-imenu-enable nil)
           (lsp-ui-sideline-enable nil)
           ;; lsp-ui-peek
           (lsp-ui-peek-enable t)
           (lsp-ui-peek-peek-height 20)
           (lsp-ui-peek-list-width 50)
           (lsp-ui-peek-fontify 'on-demand) ;; never, on-demand, or always
           ;; lsp-ui-doc
           (lsp-ui-doc-enable t)
           (lsp-ui-doc-header nil)
           (lsp-ui-doc-include-signature t)
           (lsp-ui-doc-position 'at-point) ;; top, bottom, or at-point
           (lsp-ui-doc-max-width 150)
           (lsp-ui-doc-max-height 30)
           (lsp-ui-doc-use-childframe t)
           (lsp-ui-doc-use-webkit t)
           ;; lsp-ui-flycheck
           ;; don't use flycheck on lsp-mode and lsp-ui
           (lsp-ui-flycheck-enable t))
  :hook   (lsp-mode . lsp-ui-mode)
  :preface
  (defun toggle-lsp-ui-doc ()
    (interactive)
    (if lsp-ui-doc-mode
        (progn
          (lsp-ui-doc-mode -1)
          (lsp-ui-doc--hide-frame))
      (lsp-ui-doc-mode 1))))

(use-package company-lsp
  :after (lsp-mode company yasnippet)
  :defines company-backends
  :init (push 'company-lsp company-backends))

;; emacs-lisp
(use-package lispxmp :defer t
  :bind (:map emacs-lisp-mode-map
              ("C-c C-e" . lispxmp )))

;; Haskell
(use-package haskell-mode
  :mode (("\\.hs$" . haskell-mode)
         ("\\.lhs$" . literate-haskell-mode)))

;; HTML
(use-package web-mode
  :after (add-node-modules-path)
  :mode (("\\.phtml\\'" . web-mode)
         ("\\.tpl\\.php\\'" . web-mode)
         ("\\.[gj]sp\\'" . web-mode)
         ("\\.as[cp]x\\'" . web-mode)
         ("\\.erb\\'" . web-mode)
         ("\\.mustache\\'" . web-mode)
         ("\\.djhtml\\'" . web-mode)
         ("\\.html?\\'" . web-mode)
         ("\\.tsx\\'" . web-mode))
  :custom
  (web-mode-indent-style 2)
  (web-mode-markup-indent-offset 2)
  (web-mode-css-indent-offset 2)
  (web-mode-code-indent-offset 2)
  (web-mode-enable-auto-pairing t)
  (web-mode-enable-auto-quoting nil)
  (web-mode-enable-css-colorization t)
  (web-mode-enable-current-element-highlight t)
  (web-mode-enable-current-column-highlight t)
  (web-mode-enable-auto-quoting nil)
  (web-mode-content-types-alist '(("jsx" . "\\.[t|j]s[x]?\\'")))
  (web-mode-comment-formats
   '(("javascript" . "//")
     ("jsx" .  "//")
     ("php" . "/*")))
  :config
  (add-hook 'web-mode-hook
            (lambda ()
              (when (equal web-mode-content-type "jsx")
                (add-to-list 'web-mode-indentation-params '("lineup-args" . nil))
                (add-to-list 'web-mode-indentation-params '("lineup-calls" . nil))
                (add-to-list 'web-mode-indentation-params '("lineup-concats" . nil))
                (add-to-list 'web-mode-indentation-params '("lineup-ternary" . nil))
                (flycheck-add-mode 'javascript-eslint 'web-mode)
                (lsp)
                (flycheck-add-next-checker 'lsp-ui 'javascript-eslint)
                (flycheck-mode t)))))

(use-package slim-mode)
(use-package haml-mode)

;; CSS
(use-package css-mode
  :straight nil
  :custom
  (css-indent-offset 2))
(use-package scss-mode :custom (scss-indent-offset 2))
(use-package sass-mode)
(use-package sws-mode) ;; Stylus

;; javascript
(use-package js2-mode :defer t
  :mode (("\.js$" . js2-mode))
  :custom
  ((js-indent-level 2)
   (js-switch-indent-offset 2)
   (js2-basic-offset 2)
   (js2-strict-missing-semi-warning nil))
  :config
  (add-hook 'js2-mode-hook
            (lambda ()
              (lsp)
              (flycheck-add-next-checker 'lsp-ui 'javascript-eslint)
              (flycheck-mode t))))

(use-package typescript-mode
  :custom (typescript-indent-level 2)
  :config
  (add-hook 'typescript-mode-hook
            (lambda ()
              (lsp)
              (flycheck-add-next-checker 'lsp-ui 'javascript-eslint)
              (flycheck-mode t))))

(use-package coffee-mode
  :custom (coffee-tab-width 2))

(use-package nodejs-repl
  :after js2-mode
  :bind (:map js2-mode-map
              ("C-x C-e" . nodejs-repl-send-last-expression)
              ("C-c C-j" . nodejs-repl-send-line)
              ("C-c C-r" . nodejs-repl-send-region)
              ("C-c C-l" . nodejs-repl-load-file)
              ("C-c C-z" . nodejs-repl-switch-to-repl)))

(use-package add-node-modules-path
  :config
  (add-hook 'js2-mode-hook #'add-node-modules-path)
  (add-hook 'web-mode-hook #'add-node-modules-path)
  (add-hook 'typescript-mode-hook #'add-node-modules-path)
  (add-hook 'scss-mode-hook #'add-node-modules-path))

;; Dart
(use-package dart-mode
  :custom
  (dart-format-on-save nil)
  (dart-enable-analysis-server nil)
  (dart-sdk-path "~/repos/github.com/flutter/flutter/bin/cache/dart-sdk/"))

(use-package flutter
  :after dart-mode
  :bind (:map dart-mode-map
              ("C-M-x" . #'flutter-run-or-hot-reload))
  :custom
  (flutter-sdk-path "~/repos/github.com/flutter/flutter/"))

;; Python
(use-package python :defer t
  :custom((indent-tabs-mode nil)
          (tab-width 4)))

(use-package anaconda-mode
  :after company
  :hook ((python-mode . anaconda-mode)
         (python-mode . anaconda-eldoc-mode))
  :config
  (use-package company-anaconda)
  (add-hook 'python-mode-hook 'anaconda-mode)
  (add-to-list 'company-backends 'company-anaconda))

;; Swift
(use-package swift-mode :defer t
  :after flycheck
  :config
  (add-to-list 'flycheck-checkers 'swift)
  (use-package company-sourcekit)
  (add-to-list 'company-backends 'company-sourcekit))

;; Ruby
(use-package ruby-mode :defer t
  :mode (("\\.rb\\'" . ruby-mode)
         ("Capfile$" . ruby-mode)
         ("Gemfile$" . ruby-mode)
         ("[Rr]akefile$" . ruby-mode))
  :interpreter "pry"
  :config (require 'smartparens-ruby))

(use-package inf-ruby
  :bind (:map inf-ruby-minor-mode-map
              ("C-c C-b" . ruby-send-buffer)
              ("C-c C-l" . ruby-send-line))
  :init
  (defalias 'pry 'inf-ruby)
  :custom
  (inf-ruby-default-implementation "pry")
  (inf-ruby-eval-binding "Pry.toplevel_binding"))

(use-package robe :defer t
  :after company
  :hook ((ruby-mode . robe-mode)
         (inf-ruby-mode . robe-mode))
  :config
  (add-to-list 'company-backends 'company-robe))

;; PHP
(use-package php-mode)

;; SQL
(use-package sql
  :mode (("\.sql$" . sql-mode))
  :config
  (add-hook 'sql-interactive-mode-hook
            (lambda ()
              (buffer-face-set 'variable-pitch)
              (toggle-truncate-lines t))))

(use-package sqlup-mode
  :commands (sqlup-mode)
  :hook ((sql-mode . sqlup-mode)
         (sql-interactive-mode . sqlup-mode)))

(use-package sqlformat
  :ensure-system-package ((sqlformat . "brew install sqlparse")))

;; Java
(add-hook 'java-mode-hook
          (lambda ()
            (message "hook")
            (setq tab-width 4)
            (setq indent-tabs-mode t)
            (setq c-basic-offset 4)))

;; Docker
(use-package dockerfile-mode)
(use-package docker-compose-mode)

;; Git
(use-package gitconfig-mode)
(use-package gitignore-mode)

;; Nginx
(use-package nginx-mode)

;; go
(use-package go-mode
  :config
  (add-hook 'go-mode-hook 'flycheck-mode)
  (use-package company-go))

;; elixir
(use-package elixir-mode
  :config
  (use-package alchemist)
  (use-package flycheck-elixir))

;; R
(use-package ess)

;; Scala
(use-package scala-mode :interpreter ("scala" . scala-mode))
(use-package sbt-mode :commands sbt-start sbt-command)
(use-package scala-bootstrap
  :straight (scala-bootstrap.el :type git :host github :repo "tarao/scala-bootstrap-el")
  :config
  (add-hook 'scala-mode-hook
            '(lambda ()
               (scala-bootstrap:with-metals-installed
                (scala-bootstrap:with-bloop-server-started
                 (lsp))))))

;; fish
(use-package fish-mode)

;;; 20-mode-prog ends here
