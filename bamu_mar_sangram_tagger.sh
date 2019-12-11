;;; POS tagger for mar
;;;

;;; Load any necessary files here


(set! bamu_mar_guess_pos 
'((fn
    ;; function words 
  )
  ;; Or split them into sub classes (but give them meaningful names)
  ; (pos_0 .. .. .. ..)
  ; (pos_1 .. .. .. ..)
  ; (pos_2 .. .. .. ..)
))

(define (bamu_mar_sangram::select_tagger)
  "(bamu_mar_sangram::select_tagger)
Set up the POS tagger for mar."
  (set! pos_lex_name nil)
  (set! guess_pos bamu_mar_guess_pos) 
)

(define (bamu_mar_sangram::reset_tagger)
  "(bamu_mar_sangram::reset_tagger)
Reset tagging information."
  t
)

(provide 'bamu_mar_sangram_tagger)
