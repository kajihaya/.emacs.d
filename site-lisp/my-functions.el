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
    (ov (point-min) (point-max) 'face '(:family "Ricty Diminished")))

  (defun my/buffer-cica-face ()
    "Rictyoise current buffer."
    (interactive)
    (ov (point-min) (point-max) 'face '(:family "Cica"))
    (ov (point-min) (point-max) 'face '(:height 102)))

  (defun my/font-size (height-num)
    "Change font size current buffer"
    (interactive "nFontsize:")
    (ov (point-min) (point-max) 'face '(:height height-num))))

(defun my/set-alpha (alpha-num)
  "set frame parameter 'alpha"
  (interactive "nAlpha: ")
  (set-frame-parameter nil 'alpha (cons alpha-num '(90))))

(setq my/current-screen-geometry
      (cl-loop for x in (display-monitor-attributes-list)
               when (> (length (assoc 'frames x)) 1)
               return (cons (nth 3 (assoc 'geometry x)) (nth 4 (assoc 'geometry x)))))

(defun my/resize-frame (w h x y frame)
  "Set frame W (width), H (height), X (position left) and Y (position top) on FRAME."
  (set-frame-width frame (- w 20) nil 'pixelwise)
  (set-frame-height frame (- h 10) nil 'pixelwise)
  (set-frame-position frame x y))

(defun my/fullscreen ()
  "Set frame maxmize."
  (interactive)
  (let ((frame (selected-frame))
        (width (car my/current-screen-geometry))
        (height (cdr my/current-screen-geometry)))
    (my/resize-frame width height 0 0 frame)))

(defun my/halfscreen ()
  "Set frame half."
  (interactive)
  (let ((frame (selected-frame))
        (width (car my/current-screen-geometry))
        (height (cdr my/current-screen-geometry)))
    (my/resize-frame (/ width 2) height 0 0 frame)))

(defun my/halfscreen-right ()
  "Set frame half."
  (interactive)
  (let ((frame (selected-frame))
        (width (car my/current-screen-geometry))
        (height (cdr my/current-screen-geometry)))
    (my/resize-frame (/ width 2) height (/ width 2) 0 frame)))

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
           (concat  (make-string (- level 1) ? ) (string (org-bullets-level-char level)) " "))))
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
           (concat  (make-string (- level 1) ? ) (string (org-bullets-level-char level)) " "))))
      (clipboard-kill-ring-save (point-min) (point-max)))))


(defun char-unicode (char) (encode-char char 'ucs))
(defun unicode-char (code) (decode-char 'ucs code))

;; ユニコードエスケープシーケンスを解除する
(defun my/unicode-decode-region (start end)
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
(defun my/unicode-encode-region (&optional start end)
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

(defun my/uniq-lines (beg end)
  "Unique lines in region.
Called from a program, there are two arguments:
BEG and END (region to sort)."
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)
      (goto-char (point-min))
      (while (not (eobp))
        (kill-line 1)
        (yank)
        (let ((next-line (point)))
          (while
              (re-search-forward
               (format "^%s" (regexp-quote (car kill-ring))) nil t)
            (replace-match "" nil nil))
          (goto-char next-line))))))

(defun my/connect-db-via-ssh-tunneling(db host dbport)
  "Connect DB via ssh tunneling."
  (let ((port (car (cdr (assoc 'sql-port (assoc db sql-connection-alist)))))
        (password (car (cdr (assoc 'sql-password (assoc db sql-connection-alist))))))
    (start-process-shell-command "DBProxy" "*Proxy*" (concat "ssh -N -L " (number-to-string port) ":localhost:" dbport " " host))
    (setenv "PGPASSWORD" password))
  (sleep-for 1.5)
  (sql-connect db))

(defun my/reopen-with-sudo-tramp ()
  "Reopen current buffer-file with sudo using tramp."
  (interactive)
  (let ((file-name (buffer-file-name)))
    (string-match ":\\(.*\\):" file-name)
    (if file-name
        (find-alternate-file (replace-regexp-in-string ":.*:" (concat ":" (match-string 1 file-name) "|sudo:root" ":") file-name))
      (error "Cannot get a file name"))))

(defun my/copy-buffer-name-clipboard ()
  (interactive)
  (kill-new buffer-file-name))

(defun my/sql-indent-region (beg end)
  "Indent the SQL statement in the region."
  (interactive "*r")
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)
      (sql-indent-buffer))))

(defun my/move-or-rename-this-file (new-file-name)
  (interactive "Fnewfile name: ")
  (let* ((current-file-name (buffer-name)))
    (rename-file current-file-name new-file-name)
    (find-file new-file-name)
    (kill-buffer current-file-name)))

(defun my/delete-or-remove-this-file ()
  (interactive)
  (let* ((current-file-name (buffer-name)))
    (movep-file-to-trash current-file-name)
    (kill-buffer current-file-name)))

(defun my/dired-this-buffer ()
  (interactive)
  (dired
   (file-name-directory (expand-file-name (buffer-name)))))

(defun my/eslint-fix-file ()
  (interactive)
  (message "eslint --fixing the file" (buffer-file-name))
  (shell-command (concat "npx eslint --fix " (buffer-file-name))))

;; kill buffer
(defun my/close-and-kill-this-pane ()
  "If there are multiple windows, then close this pane and kill the buffer in it also."
  (interactive)
  (kill-this-buffer)
  (if (not (one-window-p))
      (delete-window)))
(bind-key (kbd "C-x k") 'my/close-and-kill-this-pane)

(defun my/kill-other-buffers ()
  "Kill all other buffers."
  (interactive)
  (cl-loop for buf in (buffer-list)
           unless (or
                   (get-buffer-window buf)
                   (string= (substring (buffer-name buf) 0 1) " ")
                   (get-buffer-process buf)
                   (member (buffer-name buf) ;; 消さないバッファ名を指定
                           '("*Messages*" "*Compile-Log*" "*Help*"
                             "*scratch*" "*init log*")))
           do (kill-buffer buf)))

;; reload buffer
(defun my/revert-buffer-no-confirm ()
  "Revert buffer without confirmation."
  (interactive)
  (revert-buffer t t))

;; indent buffer
(defun my/buffer-indent ()
  (interactive)
  (let ((point (point)))
    (mark-whole-buffer)
    (indent-region (region-beginning)(region-end))
    (goto-char point)))

;; custom keyboard quit
(defun my/keyboard-quit ()
  (interactive)
  (if (active-minibuffer-window)
      (minibuffer-keyboard-quit)
    (keyboard-quit)))

(provide 'my-functions)

;;; my-functions.el ends here
