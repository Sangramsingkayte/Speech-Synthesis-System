

(define (Int_Targets_Tree utt)
  "(Int_Targets_Tree utt)
For each syllable in a phrase add start mid and end F0 targets."
  (utt.relation.create utt 'Target)
  (mapcar
   (lambda (syl)
     (Tree_Predict_Targets utt syl))
   (utt.relation.items utt 'Syllable))
  utt)

(define (Tree_Predict_Targets utt syl)
  "(Tree_Predict_Targets utt syl)
Add targets to start (if immediately after a pause) mid vowel
and end for this syllable."
  (if (tpt_after_pause syl)
      (tpt_add_target
       utt
       (item.relation.daughter1 syl 'SylStructure)
       0
       (wagon_predict syl F0start_tree)))
  (tpt_add_target utt (tpt_find_syl_vowel syl) 50
	      (wagon_predict syl F0mid_tree))
  (tpt_add_target utt (item.relation.daughtern syl 'SylStructure) 100
	      (wagon_predict syl F0end_tree)))

(define (tpt_after_pause syl)
  "(tpt_after_pause syl)
Returns t if segment immediately before this is a pause (or utterance
start).  nil otherwise."
  (let ((pseg (item.relation.prev (item.relation.daughter1 syl 'SylStructure)
				  'Segment)))
    (if (or (not pseg)
	    (member_string
	     (item.name pseg)
	     (car (cdr (car (PhoneSet.description '(silences)))))))
	t
	nil)))

(define (tpt_find_syl_vowel syl)
  "(tpt_find_syl_vowel syl)
Find the item that is the vowel in syl."
  (let ((v (item.relation.daughtern syl 'SylStructure)))
    (mapcar
     (lambda (s)
       (if (string-equal "+" (item.feat s "ph_vc"))
	   (set! v s)))
     (item.relation.daughters syl 'SylStructure))
    v))

(define (tpt_f0_map_value value)
  "(tpt_f0_map_value value)
Map F0 vlaue through means and standard deviations in int_params."
  (let ((target_f0_mean (get_param 'target_f0_mean int_params 110))
	(target_f0_stddev (get_param 'target_f0_stddev int_params 15))
	(model_f0_mean (get_param 'model_f0_mean int_params 110))
	(model_f0_stddev (get_param 'model_f0_stddev int_params 15)))
    (+ (* (/ (- value model_f0_mean) model_f0_stddev)
	  target_f0_stddev) target_f0_mean)))

(define (tpt_add_target utt seg pos value)
  "(tpt_add_target utt seg pos value)
Add Target at pos and value related to seg."
  (let ((tseg (item.relation seg 'Target))
	(ntarg))
    (if (null tseg)
	(set! tseg (utt.relation.append utt 'Target seg)))
    (set! ntarg (item.append_daughter tseg))
    (item.set_feat ntarg 'f0 (tpt_f0_map_value value))
    (item.set_feat ntarg 'pos 
		   (+ (item.feat seg "segment_start")
		      (* (/ pos 100) (item.feat seg "segment_duration"))))))

(provide 'tree_f0)
