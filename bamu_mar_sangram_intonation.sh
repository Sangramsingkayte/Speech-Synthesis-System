
;;;
;;; Intonation for mar
;;;

;;; Load any necessary files here


;;; Intonation
(set! bamu_mar_accent_cart_tree
  '
  (
   (R:SylStructure.parent.gpos is content)
    ( (stress is 1)
       ((Accented))
       ((NONE))
    )
  )
)

(define (bamu_mar_sangram::select_intonation)
  "(bamu_mar_sangram::select_intonation)
Set up intonation for mar."
  (set! int_accent_cart_tree bamu_mar_accent_cart_tree)
  (Parameter.set 'Int_Target_Method 'Simple)

)

(define (bamu_mar_sangram::reset_intonation)
  "(bamu_mar_sangram::reset_intonation)
Reset intonation information."
  t
)

(provide 'bamu_mar_sangram_intonation)
