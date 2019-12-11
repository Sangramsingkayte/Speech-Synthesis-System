;;; Load any necessary files here

(require 'phrase)

(defvar cg:phrasyn nil)
(defvar cg:phrasyn_mode 'gpos)
(defvar cg:phrasyn_grammar_ntcount 10)

(define (prob_cart_combined utt1)
  (mapcar 
   (lambda (w)
     (if (string-equal "punc" (item.feat w 'pos))
	 (item.relation.remove w 'Word)))
   (utt.relation.items utt1 'Word))
  (posmap utt1 cg:phrasyn_mode)
  (ProbParse utt1)
  (Classic_Phrasify utt1)
)

(define (bamu_mar_sangram::select_phrasing)
  (if cg:phrasyn
      (bamu_mar_sangram::select_phrasing_cart )
      (bamu_mar_sangram::select_phrasing_default )))

(define (bamu_mar_sangram::select_phrasing_cart)
  (Parameter.set 'Phrasify_Method 'prob_cart_combined)
  (Parameter.set 'Phrase_Method 'prob_cart_combined)
  (require 'phrasyn)
  (set! new_phr_break_params
	(list
	 ;; The name and filename off the ngram with the a priori ngram model
	 ;; for predicting phrase breaks in the Phrasify module.  This model should sB
	 ;; predict probability distributions for B and NB given some context of 
	 ;; part of  speech tags.
	 (list 'pos_ngram_name 'english_break_pos_ngram)
	 (list 'pos_ngram_filename 
	       (path-append pbreak_ngram_dir "sec.ts20.quad.ngrambin"))
	 ;; The name and filename of the ngram  containing the a posteriori ngram
	 ;; for predicting phrase breaks in the Phrasify module.  This module should
	 ;; predict probability distributions for B and NB given previous B and
	 ;; NBs.
	 (list 'break_ngram_name 'english_break_ngram)
	 (list 'break_ngram_filename 
	       (path-append pbreak_ngram_dir "sec.B.hept.ngrambin"))
	 ;; A weighting factor for breaks in the break/non-break ngram.
	 (list 'gram_scale_s 0.59)
	 ;; When Phrase_Method is prob_models, this tree, if set is used to 
	 ;; potentially predict phrase type.  At least some prob_models only
	 ;; predict B or NB, this tree may be used to change some Bs into
	 ;; BBs.  If it is nil, the pbreak value predicted by prob_models
	 ;; remains the same.
	 (list 'phrase_type_tree english_phrase_type_tree)
	 ;; A list of tags used in identifying breaks.  Typically B and NB (and
	 ;; BB).  This should be the alphabet of the ngram identified in
	 ;; break_ngram_name
	 (list 'break_tags '(B NB))
	 (list 'break_unigrams '(__BPROB__ __NBPROB__))
	 (list 'pos_map english_pos_map_wp39_to_wp20)
	 )
	"new_phr_break_params
        Parameters for New phrase break statistical model.")
  
  (set! phr_break_params new_phr_break_params)
  (set! scfg_grammar (load (format nil "syntax/grammar.%s.%s.out" cg:phrasyn_grammar_ntcount cg:phrasyn_mode) t))
  (set! phrase_cart_tree (load (format nil "syntax/break_prediction.%s.%s.tree" cg:phrasyn_grammar_ntcount cg:phrasyn_mode) t))
  )  

(set! bamu_mar_phrase_cart_tree
'
((lisp_token_end_punc in ("'" "\"" "?" "." "," ":" ";"))
  ((B))
  ((n.name is 0)
   ((B))
   ((NB)))))

(define (bamu_mar_sangram::select_phrasing_default)
  "(bamu_mar_sangram::select_phrasing)
Set up the phrasing module for English."
  (set! phrase_cart_tree bamu_mar_phrase_cart_tree)
  (Parameter.set 'Phrase_Method 'cart_tree)
)

(define (bamu_mar_sangram::reset_phrasing)
  "(bamu_mar_sangram::reset_phrasing)
Reset phrasing information."
  t
)

(provide 'bamu_mar_sangram_phrasing)
