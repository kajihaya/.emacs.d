;;; my-functions.el --- 自作elisp
;;; Commentary:
;;; 自作elispを乱雑に配置する。今後整理するかも。

;;; Code:
;; bufferを一時的にRictyフォントに変更
(use-package ov
  :init
  (defun my/buffer-ricty-face ()
    "Rictyoise current buffer."
    (interactive)
    (ov (point-min) (point-max) 'face '(:family "Ricty Diminished"))))

(defun my/set-alpha (alpha-num)
  "set frame parameter 'alpha"
  (interactive "nAlpha: ")
  (set-frame-parameter nil 'alpha (cons alpha-num '(90))))

(defun my/full-screen ()
  "set frame maxmize"
  (interactive)
  (toggle-frame-maximized))

(defun my/org-bullets-export (path)
  "Export to bullets style text file."
  (interactive "FExport file: ")
  (let* ((current-buffer-string (buffer-string)))
    (with-temp-buffer
      (insert current-buffer-string)
      (goto-char (point-min))
      (while (re-search-forward "^\\*+ " nil t)
        (let ((level (- (match-end 0) (match-beginning 0) 1)))
          (replace-match
           (concat (string (org-bullets-level-char level)) " "))))
      (write-file path))))

(defun my/org-bullets-export-region-clipboard (start end)
  (interactive "*r")
  (let* ((current-buffer-string (buffer-substring start end)))
    (with-temp-buffer
      (insert current-buffer-string)
      (goto-char (point-min))
      (while (re-search-forward "^\\*+" nil t)
        (let ((level (- (match-end 0) (match-beginning 0))))
          (replace-match
           (concat (string (org-bullets-level-char level)) " "))))
      (clipboard-kill-ring-save (point-min) (point-max)))))

;; ユニコードエスケープシーケンスを解除する
;; https://gist.github.com/kosh04/568800#file-emacs-xyzzy-unicode-un-escape-region
(defun my/unicode-unescape-region (start end)
  "指定した範囲のUnicodeエスケープ文字(\\uXXXX)をデコードする."
  (interactive "*r")
  (save-restriction
    (narrow-to-region start end)
    (goto-char (point-min))
    (while (re-search-forward "\\\\u\\([[:xdigit:]]\\{4\\}\\)" nil t)
      (replace-match (string (unicode-char
                              (string-to-number (match-string 1) 16)))
                     nil t))))

;; ユニコードエスケープシーケンスをする
(defun my/unicode-escape-region (&optional start end)
  "指定した範囲の文字をUnicodeエスケープする."
  (interactive "*r")
  (save-restriction
    (narrow-to-region start end)
    (goto-char (point-min))
    (while (re-search-forward "." nil t)
      (replace-match (format "\\u%04x"
                             (char-unicode
                              (char (match-string 0) 0)))
                     nil t))))

(defun char-unicode (char) (encode-char char 'ucs))
(defun unicode-char (code) (decode-char 'ucs code))

;; 文字列をURLエンコードする
(defun url-encode-string (str &optional sys)
  (let ((sys (or sys 'utf-8)))
    (url-hexify-string (encode-coding-string str sys))))

;; URLエンコードを文字列にデコードする
(defun url-decode-string (str &optional sys)
  (let ((sys (or sys 'utf-8)))
    (decode-coding-string (url-unhex-string str) sys)))

(defun my/url-decode-region (beg end)
  (interactive "r")
  (let ((pos beg)
        (str (buffer-substring beg end)))
    (goto-char beg)
    (delete-region beg end)
    (insert (url-decode-string str 'utf-8))))

(defun my/url-encode-region (beg end)
  (interactive "r")
  (let ((pos beg)
        (str (buffer-substring beg end)))
    (goto-char beg)
    (delete-region beg end)
    (insert (url-encode-string str 'utf-8))))

(provide 'my-functions)

;;; my-functions.el ends here