
;;;   A hand specified tree to predict zcore durations
;;;
;;;

(set! bamu_mar_sangram::zdur_tree 
 '
   ((R:SylStructure.parent.R:Syllable.p.syl_break > 1 ) ;; clause initial
    ((1.5))
    ((R:SylStructure.parent.syl_break > 1)   ;; clause final
     ((1.5))
     ((1.0)))))

(set! bamu_mar_sangram::phone_durs
 ;; should be hand specified
 ;; '(
 ;;   (pau 0.0 0.250)
 ;;   ...  ;; the other phones
 ;;  )
 ;; But this will fake it until you build a duration model 
 (mapcar
  (lambda (p)
    (list (car p) 0.0 0.100))
  (cadr (assoc_string 'phones (PhoneSet.description ))))
)

(provide 'bamu_mar_sangram_durdata)
