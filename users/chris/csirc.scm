;; csi's init file, loaded on every start -- including non-interactive ones.
;;
;; The prelude that home-manager prepends to this extends the egg repository
;; path, because breadline does not live in CHICKEN's own store path. See
;; chicken.nix for why that is done here rather than by exporting
;; CHICKEN_REPOSITORY_PATH.

(import (chicken load))
(load-verbose #f)

(let ()
  (import (chicken format))
  (import (chicken port))
  (import (chicken process-context))
  (import (chicken process signal))

  ;; Readline only when there is a terminal to drive it.
  ;;
  ;; make-readline-port writes cursor-control sequences as it redraws the
  ;; line. Down a pipe there is nothing to interpret them, so they end up in
  ;; the output as literal escapes -- which is exactly what anything driving
  ;; csi programmatically reads back as the REPL's answer. Conjure's Scheme
  ;; client does this, as do plain shell pipelines.
  ;;
  ;; Emacs is checked separately: comint gives its inferior process a pty, so
  ;; the terminal test passes there while readline still fights it for
  ;; control of the line.
  (when (and (terminal-port? (current-input-port))
             (not (get-environment-variable "INSIDE_EMACS")))
    (import breadline)
    (import breadline-scheme-completion)

    (history-file (format "~a/.csi_history" (get-environment-variable "HOME")))
    (stifle-history! 10000)

    (completer-word-break-characters-set! "\"\'`;|()[] ")
    (completer-set! scheme-completer)
    (basic-quote-characters-set! "\"|")

    (variable-bind! "blink-matching-paren" "on")
    (paren-blink-timeout-set! 200000)

    ;; Leave the terminal usable if the REPL is interrupted or exits: readline
    ;; puts it in raw mode and will not restore it on its own.
    (let ((handler (signal-handler signal/int)))
      (set-signal-handler! signal/int
                           (lambda (s)
                             (cleanup-after-signal!)
                             (reset-after-signal!)
                             (handler s))))
    (on-exit reset-terminal!)

    (current-input-port (make-readline-port))))
