; ディスプレイの設定

;; themeを設定
;(load-theme 'monokai t)
(load-theme 'leuven t)  

;; 対応する括弧を光らせる。
(show-paren-mode t)

;; 選択部分のハイライト
(transient-mark-mode t)

;; 行間
(setq-default line-spacing 0)

;; 同じバッファ名の時 <2> とかではなく、ディレクトリ名で区別
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)

;; メニューバーにファイルパスを表示
(setq frame-title-format
      (format "%%f - Emacs@%s" (system-name)))

;; フォントロックモード
(global-font-lock-mode t)

;; windowの設定
(setq default-frame-alist
      (append (list
               '(width . 87)
               '(height . 50)
               '(top . 0)
               '(left . 0)
               '(alpha . (90 80)))
              default-frame-alist))

;; tool-bar使わない
(tool-bar-mode 0)

;; 画面端まで来たら折り返す
(setq truncate-lines nil)
(setq truncate-partial-width-windows nil)

;; スタートアップメッセージを非表示
(setq inhibit-startup-screen t)

;; scratchの初期メッセージ消去
(setq initial-scratch-message "")

;; init-loaderが失敗した時のみエラーメッセージを表示
(custom-set-variables
 '(init-loader-show-log-after-init 'error-only))

;; キーストロークをエコーエリアに早く表示する
(setq echo-keystrokes 0.1)

;; 行番号・桁番号を表示
(line-number-mode 1)
(column-number-mode 1)

;; 全角空白、タブ、行末の空白を目立たせる
(defface my-face-tab         '((t (:background "Yellow"))) nil :group 'my-faces)
(defface my-face-zenkaku-spc '((t (:background "LightBlue"))) nil :group 'my-faces)
(defface my-face-spc-at-eol  '((t (:foreground "Red" :underline t))) nil :group 'my-faces)
(defvar my-face-tab         'my-face-tab)
(defvar my-face-zenkaku-spc 'my-face-zenkaku-spc)
(defvar my-face-spc-at-eol  'my-face-spc-at-eol)
(defadvice font-lock-mode (before my-font-lock-mode ())
  (font-lock-add-keywords
   major-mode
   '(("\t" 0 my-face-tab append)
     ("¡¡" 0 my-face-zenkaku-spc append)
     ("[ \t]+$" 0 my-face-spc-at-eol append)
     )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)
(font-lock-fontify-buffer)

;; 編集行を目立たせる（現在行をハイライト表示する）
(defface hlline-face
  '((((class color)
      (background dark))
     (:background "#00070D"))
    (((class color)
      (background light))
     (:background  "#E1A9AB"))
    (t
     ()))
  "*Face used by hl-line.")
(setq hl-line-face 'hlline-face)
(global-hl-line-mode)

;; フォント設定
(let ((ws window-system))
  (cond ((eq ws 'w32)
         (set-face-attribute 'default nil
                             :family "Consolas"
                             :height 100)
         (set-fontset-font nil 'japanese-jisx0208 (font-spec :family "Consolas")))
        ((eq ws 'mac)
         (set-face-attribute 'default nil
                             :family "Source Code Pro"
                             :height 130)
         (set-fontset-font nil 'japanese-jisx0208 (font-spec :family "Source Code Pro")))))

;; whitespace-modeの設定
(use-package whitespace
             :config
             (setq whitespace-style '(face           ; faceで可化
                                      trailing       ; 行末
                                      tabs           ; タブ
                                      spaces         ; スペース
                                      empty          ; 先頭/末尾の空行
                                      space-mark     ; 表示のマッピング
                                      tab-mark
                                      ))

             (setq whitespace-display-mappings
                   '((space-mark ?\u3000 [?\u25a1])
                     ;; WARNING: the mapping below has a problem.
                     ;; When a TAB occupies exactly one column, it will display the
                     ;; character ?\xBB at that column followed by a TAB which goes to
                     ;; the next TAB column.
                     ;; If this is a problem for you, please, comment the line below.
                     (tab-mark ?\t [?\u00BB ?\t] [?\\ ?\t])))

             ;; スペースは全角のみを可視化
             (setq whitespace-space-regexp "\\(\u3000+\\)")

             (global-whitespace-mode 1)

             (defvar my/bg-color "#232323")
             (set-face-attribute 'whitespace-trailing nil
                                 :background my/bg-color
                                 :foreground "DeepPink"
                                 :underline t)
             (set-face-attribute 'whitespace-tab nil
                                 :background my/bg-color
                                 :foreground "LightSkyBlue"
                                 :underline t)
             (set-face-attribute 'whitespace-space nil
                                 :background my/bg-color
                                 :foreground "GreenYellow"
                                 :weight 'bold)
             (set-face-attribute 'whitespace-empty nil
                                 :background my/bg-color)
             )

;; スクロールバーをyascrollにする
(use-package yascroll
  :config
  (set-scroll-bar-mode 'nil)
  (global-yascroll-bar-mode 1)
  )

;; IMEのディスプレイの設定
(when (eq system-type 'darwin)
  (defun mac-selected-keyboard-input-source-change-hook-func ()
    ;; 入力モードが英語の時はカーソルの色をfirebrickに、日本語の時はblackにする
    (set-cursor-color (if (or
                          (string-match "com.google.inputmethod.Japanese.Roman" (mac-input-source))
                          (string-match "\\.US$" (mac-input-source)))
                      "PaleVioletRed1" "powder blue")
    ))

  (add-hook 'mac-selected-keyboard-input-source-change-hook
            'mac-selected-keyboard-input-source-change-hook-func)
  )
