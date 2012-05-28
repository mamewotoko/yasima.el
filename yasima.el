;;; yasima.el
;;; dagezi@gmail.com 2011-03-25 (Fri)
;;; Do as you like.

;;; patched only for XEmacs 21.4 (patch 22) on Ubuntu or Mac
;;; mamewo@dk9.so-net.ne.jp 2011-03-25

; usage; write following code in init.el
; (require 'yasima)
; (yasima-mode t)

(require 'url)

(defconst yasima-interval (* 12 60))
(defconst yasima-tepco-usage-api-url "http://tepco-usage-api.appspot.com/latest.json")

(defvar yasima-timer nil)
(defvar yasima-string nil "")
(defvar yasima-buffer " *yasima*")
  
(defun yasima-update ()
  (let (usage capacity)
    (goto-char (point-min))
    (or (and (re-search-forward "\"usage\":\\s +\\([0-9]+\\)" nil t)
	     (setq usage (string-to-number (match-string 1)))
	     (progn (goto-char (point-min)) t)
	     (re-search-forward "\"capacity\":\\s +\\([0-9]+\\)" nil t)
	     (setq capacity (string-to-number (match-string 1)))
	     (setq yasima-string 
		   (format "%2d%%" (/ (* usage 100) capacity))))
	(setq yasima-string "%%%")))
  (force-mode-line-update)
  (sit-for 0))

(defun yasima-event-handler ()
  (let ((url-working-buffer yasima-buffer))
    (save-excursion
      (url-retrieve yasima-tepco-usage-api-url)
      (set-buffer yasima-buffer)
      (yasima-update))))

;;;###autoload
(define-minor-mode yasima-mode
  "Show power usage of Tokyo Denryoku in modeline"
  :global t
  (and yasima-timer (delete-itimer yasima-timer))
  (setq yasima-timer nil)
  (setq yasima-string "")
  (or global-mode-string (setq global-mode-string '("")))
  (if yasima-mode
      (progn
	(or (memq 'yasima-string global-mode-string)
	    (setq global-mode-string
		  (append global-mode-string '(yasima-string))))
	(setq yasima-timer
	      (run-with-timer 0.001 yasima-interval 'yasima-event-handler)))))

(provide 'yasima)
