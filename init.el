;; Turn off mouse interface early in startup to avoid momentary display
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; No splash screen please ... jeez
(setq inhibit-startup-message t)

;; Set path to dependencies
(setq site-lisp-dir
      (expand-file-name "site-lisp" user-emacs-directory))

;; Set up load path
(add-to-list 'load-path user-emacs-directory)
(add-to-list 'load-path site-lisp-dir)

;; Keep emacs Custom-settings in separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

(server-start)

(put 'set-goal-column 'disabled nil)

(set-default-font "-misc-fixed-medium-r-*-*-15-*-*-*-*-*-*")

;; Scrolling and indenting

(setq scroll-conservatively 50)
(setq scroll-up-agressively 0)
(setq scroll-down-agressively 0)
(global-set-key "\r" 'newline-and-indent)

;; whitespaces
(add-hook 'before-save-hook 'delete-trailing-whitespace)


;; tabbar
(if (eq window-system 'x)
    (progn 
      (require 'tabbar)
      (tabbar-mode t)
      (global-set-key (kbd "\e]") 'tabbar-forward)
      (global-set-key (kbd "\e[") 'tabbar-backward)
      )
  )


;; session
(require 'session)
(add-hook 'after-init-hook 'session-initialize)


;; cedet
;;(setq semantic-load-turn-useful-things-on t)
;;(require 'cedet)
;;(global-set-key (kbd "\C-c SPC") 'semantic-ia-complete-symbol)
(require 'ecb)
(global-set-key (kbd "\e\ee") 'ecb-activate)


;; Compilation

;; general compile function call "make all"
(defun user-save-and-make()
  "save and call shell command: make all"
  (interactive)
  (save-buffer)
  (compile compile-command)
  (message (concat compile-command " executed!")))

;; general compile function call "make all"
(defun user-save-and-make-clean ()
  "save and call shell command: make all"
  (interactive)
  (save-buffer)
  (compile "make -k clean")
  (message "make -k clean executed!"))

;; general compile function call "make all"
(defun user-save-and-make-build ()
  "save and call shell command: make all"
  (interactive)
  (save-buffer)
  (compile "make -k clean all")
  (message "make -k clean all executed!"))

;; compilation window shall scroll down
(setq compilation-scroll-output 1)

(global-set-key (kbd "\e\em") 'user-save-and-make)
(global-set-key [f9] 'user-save-and-make)
(global-set-key (kbd "\e\ec") 'user-save-and-make-clean)
(global-set-key (kbd "\e\eb") 'user-save-and-make-build)
(global-set-key (kbd "\e\ek") 'kill-compilation)


;; C/C++
(defun linux-c-mode-hook()
  "C mode with adjusted defaults for use with the Linux kernel."
  (c-set-style "K&R")
  (setq tab-width 8)
  (setq indent-tabs-mode t)
  (setq c-basic-offset 8)
  (make-variable-buffer-local 'c-macro-cppflags)
)

(add-hook 'c-mode-common-hook 'linux-c-mode-hook)

(defvar pkg-config-cflags)

(setq pkg-config-cflags "`pkg-config --cflags dbus-1 dbus-glib-1 glib-2.0 gtk+-2.0`")

(defun c++-cpp-hook()
  "C++ mode with nice preprocessor."
  (setq c-macro-cppflags (concat pkg-config-cflags " -x c++")))

(add-hook 'c++-mode-hook 'c++-cpp-hook)

(defun c-cpp-hook ()
  "C mode with nice preprocessor."
  (setq c-macro-cppflags pkg-config-cflags))

(add-hook 'c-mode-hook 'c-cpp-hook)


;; ASM
(defun asm-mode-set-comment-hook()
  (setq asm-comment-char 35))


;; JSON
(add-to-list 'auto-mode-alist '("\\.json$" . javascript-mode))


;; TEX
(add-hook 'tex-mode-hook (function (lambda () (setq ispell-parser 'tex))))


;; Python

(when (load "flymake" t)
      (defun flymake-pylint-init ()
        (let* ((temp-file (flymake-init-create-temp-buffer-copy
                           'flymake-create-temp-inplace))
               (local-file (file-relative-name
                            temp-file
                            (file-name-directory buffer-file-name))))
          (list "epylint" (list local-file))))
      (add-to-list 'flymake-allowed-file-name-masks
                   '("\\.py\\'" flymake-pylint-init)))

(defun my-flymake-show-help ()
  (when (get-char-property (point) 'flymake-overlay)
    (let ((help (get-char-property (point) 'help-echo)))
      (if help (message "%s" help)))))

(add-hook 'post-command-hook 'my-flymake-show-help)
;(add-hook 'python-mode-hook 'flymake-mode)

;; Jinja
(autoload 'jinja2-mode "jinja2-mode" nil t)
(add-to-list 'auto-mode-alist '("\.jinja2$" . jinja2-mode))
(add-to-list 'auto-mode-alist '("templates/.*\.html$" . jinja2-mode))

;; Lisp
(add-to-list  'load-path  "/usr/share/emacs/site-lisp/slime/")
(require 'slime)
(slime-setup)
