;;; 00-init.el --- 初期前提設定
;;; Commentary:

;;; Code:
(setq auto-coding-functions nil)                  ;; 文字コードの自動変換保存をしない
(setq completion-ignore-case t)                   ;; file名の補完で大文字小文字を区別しない
(setq auto-save-default nil)                      ;; オートセーブのファイルを作らない
(setq make-backup-files t)                        ;; Backup fileの場所指定
(setq gc-cons-threshold (* 10 gc-cons-threshold)) ;; GCを減らして軽くする
(setq message-log-max 10000)                      ;; ログの記録行数を増やす
(setq vc-follow-symlinks t)                       ;; symlinkは必ず追いかける
(setq backup-directory-alist
      (cons (cons "\\.*$" (expand-file-name "~/.emacs.d/.backup"))
            backup-directory-alist))              ;; バックアップの設定

(fset 'yes-or-no-p 'y-or-n-p)                     ;; yes-noの選択肢をy-nにする
(global-auto-revert-mode 1)                       ;; ファイルの自動再読み込み

(require 'server)
(unless (server-running-p) (server-start))        ;; サーバ起動

(when (eq system-type 'darwin)
  (mac-auto-ascii-mode 1)
  ;; 文字コードの設定
  (require 'ucs-normalize)
  (prefer-coding-system 'utf-8)
  (setq file-name-coding-system 'utf-8-hfs)
  (setq locale-coding-system 'utf-8-hfs))

(when (eq system-type 'gnu/linux)
  (setq x-alt-keysym 'meta)
  (setq x-super-keysym 'meta)
  ;; 文字コードの設定
  (prefer-coding-system 'utf-8)
  (setq file-name-coding-system 'utf-8)
  (setq locale-coding-system 'utf-8))

(use-package exec-path-from-shell
  :if (eq system-type 'darwin)
  :config
  (exec-path-from-shell-initialize))

;;; 00-init ends here
