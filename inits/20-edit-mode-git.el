(use-package magit
  :config
  (global-set-key (kbd "C-c g") 'magit-status)

  (set-face-background 'magit-item-highlight "#202020")
  (set-face-foreground 'magit-diff-add "green")
  (set-face-foreground 'magit-diff-del "red")
  (set-face-foreground 'magit-diff-file-header "blue")

  (defun my/magit-quit-session ()
    (interactive)
    (kill-buffer)
    (delete-window))

  (define-key magit-status-mode-map (kbd "q") 'my/magit-quit-session)

  ;; 読んだ
  (setq magit-last-seen-setup-instructions "1.4.0")
  )

(use-package git-gutter
  :config
  (global-git-gutter-mode +1)
  )


