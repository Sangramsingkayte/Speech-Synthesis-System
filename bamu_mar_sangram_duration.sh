
;;; Duration model
;;;

;;; Load any necessary files here
(require 'bamu_mar_sangram_durdata)

(define (bamu_mar_sangram::select_duration)
  "(bamu_mar_sangram::select_duration)
Set up duration model."
  (set! duration_cart_tree bamu_mar_sangram::zdur_tree)
  (set! duration_ph_info bamu_mar_sangram::phone_durs)
  (Parameter.set 'Duration_Method 'Tree_ZScores)
  (Parameter.set 'Duration_Stretch 1.1)
)

(define (bamu_mar_sangram::reset_duration)
  "(bamu_mar_sangram::reset_duration)
Reset duration information."
  t
)

(provide 'bamu_mar_sangram_duration)
