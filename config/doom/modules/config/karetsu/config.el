;;; private/karetsu/config.el -*- lexical-binding: t; -*-

(if (featurep! +bindings) (load! +bindings))


;;
;; Plugins
;;

(after! epa
  (setq epa-file-encrypt-to (or epa-file-encrypt-to user-mail-address)
        ;; With GPG 2.1, this forces gpg-agendt to use the Emacs minibuffer to
        ;; prompt for the key passphrase.
        epa-pinentry-mode 'loopback))


(when (featurep 'evil)
  (when (featurep! +evil-commands)
    (load! +evil-commands))

  (when (featurep! +bindings)
    ;; Makes ; and , the universal repeat-keys in evil-mode
    (defmacro do-repeat! (command next-func prev-func)
      "Repeat motions with ;/,"
      (let ((fn-sym (intern (format "+evil*repeat-%s" command))))
        `(progn
           (defun ,fn-sym (&rest _)
             (define-key evil-motion-state-map (kbd ";") ',next-func)
             (define-key evil-motion-state-map (kbd ",") ',prev-func))
           (advice-add #',command :before #',fn-sym))))

    ;; n/N
    (do-repeat! evil-ex-search-next evil-ex-search-next evil-ex-search-previous)
    (do-repeat! evil-ex-search-previous evil-ex-search-next evil-ex-search-previous)
    (do-repeat! evil-ex-search-forward evil-ex-search-next evil-ex-search-previous)
    (do-repeat! evil-ex-search-backward evil-ex-search-next evil-ex-search-previous)

    ;; f/F/t/T/s/S
    (after! evil-snipe
      (setq evil-snipe-repeat-keys nil
            evil-snipe-override-evil-repeat-keys nil) ; causes problems with remapped ;

      (do-repeat! evil-snipe-f evil-snipe-repeat evil-snipe-repeat-reverse)
      (do-repeat! evil-snipe-F evil-snipe-repeat evil-snipe-repeat-reverse)
      (do-repeat! evil-snipe-t evil-snipe-repeat evil-snipe-repeat-reverse)
      (do-repeat! evil-snipe-T evil-snipe-repeat evil-snipe-repeat-reverse)
      (do-repeat! evil-snipe-s evil-snipe-repeat evil-snipe-repeat-reverse)
      (do-repeat! evil-snipe-S evil-snipe-repeat evil-snipe-repeat-reverse)
      (do-repeat! evil-snipe-x evil-snipe-repeat evil-snipe-repeat-reverse)
      (do-repeat! evil-snipe-X evil-snipe-repeat evil-snipe-repeat-reverse))

    ;; */#
    (after! evil-visualstar
      (do-repeat! evil-visualstar/begin-search-forward
                  evil-ex-search-next evil-ex-search-previous)
      (do-repeat! evil-visualstar/begin-search-backward
                  evil-ex-search-previous evil-ex-search-next))

    ;; lazy-load `evil-easymotion'
    (map! :m "gs" #'+default/easymotion)
    (defun +default/easymotion ()
      (interactive)
      (let ((prefix (this-command-keys)))
        (evilem-default-keybindings prefix)
        (map! :map evilem-map
              "n" (evilem-create #'evil-ex-search-next)
              "N" (evilem-create #'evil-ex-search-previous)
              "s" (evilem-create #'evil-snipe-repeat
                                 :pre-hook (save-excursion (call-interactively #'evil-snipe-s))
                                 :bind ((evil-snipe-scope 'buffer)
                                        (evil-snipe-enable-highlight)
                                        (evil-snipe-enable-incremental-highlight)))
              "S" (evilem-create #'evil-snipe-repeat-reverse
                                 :pre-hook (save-excursion (call-interactively #'evil-snipe-s))
                                 :bind ((evil-snipe-scope 'buffer)
                                        (evil-snipe-enable-highlight)
                                        (evil-snipe-enable-incremental-highlight))))
        (set-transient-map evilem-map)
        (which-key-reload-key-sequence prefix)))))



;; app/irc
;; +TODO: configure this
(after! circe
  (setq +irc-notifications-watch-strings '("karetsu"))

  (set! :irc "irc.freenode.org"
    `(:tls t
      :nick "karetsu"
      :port 6697
      :sasl-username ,(+pass-get-user "irc/snoonet.org")
      :sasl-password ,(+pass-get-secret "irc/snoonet.org")
      :channels (:after-auth "#haskell"))))


;; app/email
(after! mu4e
  (setq smtpmail-stream-type 'starttls
        smtpmail-default-smtp-server "smtp.gmail.com"
        smtpmail-smtp-server "smtp.gmail.com"
        smtpmail-smtp-service 587)

  (set! :email "gmail.com"
    '((mu4e-sent-folder       . "/gmail.com/Sent Mail")
      (mu4e-drafts-folder     . "/gmail.com/Drafts")
      (mu4e-trash-folder      . "/gmail.com/Trash")
      (mu4e-refile-folder     . "/gmail.com/All Mail")
      (smtpmail-smtp-user     . "myogibo")
      (user-mail-address      . "myogibo@gmail.com")
      (mu4e-compose-signature . "---\nkaretsu")))
    )

(defvar +org-dir (expand-file-name "~/.org/"))
