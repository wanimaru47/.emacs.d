;;;;;;;;;;;;;;;;; not create tempolary file ;;;;;;;;;;
(setq backup-inhibited t)
(setq delete-auto-save-files t)
(setq auto-save-default nil)
(setq auto-save-list-file-name nil)
(setq auto-save-list-file-prefix nil)
(setq make-backup-files nil)

;;;;;;;;;;;;;;;;; load path ;;;;;;;;;;;;;;;;;;;;;;;;;
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory (expand-file-name (concat user-emacs-directory path))))
	(add-to-list 'load-path default-directory)
	(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
	    (normal-top-level-add-subdirs-to-load-path))))))

;;;;;;;;;;;;;;;;;;;keybind;;;;;;;;;;;;;;;;;;;;
(global-set-key "\C-h" 'delete-backward-char)

(defface hlline-face
  '((((class color)
      (background dark))
     (:background "gray20"))
    (((class color)
      (background light))
     (:background "ForestGreen"))
    (t
     ()))
  "*Face used by hl-line.")
;;(setq hl-line-face 'hlline-face)
(setq hl-line-face 'underline) ; 下線
(global-hl-line-mode)

;;;;;;;;;;;;;;;;;;;;Package;;;;;;;;;;;;;;;;;;;;
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)

(setup-flycheck-d-unittest)

;; elpa
(add-to-load-path "elpa")

;; Emacs directory
(when load-file-name
  (setq user-emacs-directory (file-name-directory load-file-name)))

(defun package-install-with-refresh (package)
  (unless (assq package package-alist)
    (package-refresh-contents))
  (unless (package-installed-p package)
        (package-install package)))

;;;;;;;;;;;;;;;;;;;;Auto-Complete;;;;;;;;;;;;;;;;;;;;
(require 'auto-complete-config)
(ac-config-default)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/elpa/auto-complete-1.4/dict")

;; C++ style
(add-hook 'c++-mode-hook
	  '(lambda ()
	     (define-key c-mode-base-map "\C-m" 'newline-and-indent)
	     (c-set-style "stroustrup")
	     (setq indent-tabs-mode nil)
	     ))
(put 'upcase-region 'disabled nil)

(add-to-list 'exec-path (expand-file-name "/usr/bin/dmd"))

;; D Programming Language Style
(add-hook 'd-mode-hook
	  (lambda ()
	    ;;(c-toggle-auto-hungry-state 1)
	    (define-key c-mode-base-map "\C-m" 'newline-and-indent)
	    (c-set-style "python")
	    (setq c-basic-offset 4)
	    (setq indent-tabs-mode nil)
	    (local-set-key  (kbd "C-c C-p") 'flycheck-previous-error)
	                (local-set-key  (kbd "C-c C-n") 'flycheck-next-error)))

;;TEX設定
;;YaTeX の設定適用
(setq auto-mode-alist
      (cons (cons "\.tex$" 'yatex-mode) auto-mode-alist))
(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
;; YaTeX のパスを通す(app 名は適宜変更)
(add-to-list 'load-path "/Applications/Emacs.app/Contents/Resources/site-lisp/yatex")
(setq YaTeX-dvipdf-command "/usr/texbin/dvipdfmx ")
(setq tex-command "platex ")
;; (setq dvi2-command "dvipdfmx ")
(setq dvi2-command "/usr/bin/open -a Preview ")
(setq tex-pdfview-command "/usr/bin/open -a Preview ")
;; (setq tex-pdfview-command "/usr/bin/open -a Adobe\ Acrobat\ Reader\ DC")
;; (setq tex-pdfview-command "/usr/bin/open -a \"Adobe Acrobat Reader DC\" `echo %s | gsed -e \"s/\\.[^.]*$/\\.pdf/\"`")

;; Haskell Mode ;;;;;;
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
(add-hook 'haskell-mode-hook 'font-lock-mode)
(add-hook 'haskell-mode-hook 'imenu-add-menubar-index)

;; Processing Mode ;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq processing-location "/usr/bin/processing-java")
(setq processing-application-dir "/Applications/Processing.app")
(setq processing-sketch-dir "~/Documents/Processing")

;; markdown-mode
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.txt\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
(setq markdown-command "/opt/local/bin/multimarkdown")

;; SSH
(require 'tramp)
(setq tramp-default-method "ssh")

;; Install evil
(package-install-with-refresh 'evil)

;; Enable evil
(require 'evil)
(evil-mode 0)

;; Show Git branch information to mode-line
(let ((cell (or (memq 'mode-line-position mode-line-format)
		(memq 'mode-line-buffer-identification mode-line-format)))
      (newcdr '(:eval (my/update-git-branch-mode-line))))
  (unless (member newcdr mode-line-format)
    (setcdr cell (cons newcdr (cdr cell)))))

(defun my/update-git-branch-mode-line ()
  (let* ((branch (replace-regexp-in-string
		  "[\r\n]+\\'" ""
		  (shell-command-to-string "git symbolic-ref -q HEAD")))
	 (mode-line-str (if (string-match "^refs/heads/" branch)
			    (format "[%s]" (substring branch 11))
			  "[Not Repo]")))
    (propertize mode-line-str
		'face '((:foreground "Dark green" :weight bold)))))
