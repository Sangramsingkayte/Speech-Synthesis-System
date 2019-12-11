;;; Ensure this version of festival has been compiled with clunits module
(require_module 'clunits)
(require 'clunits) ;; runtime scheme support

;;; Try to find the directory where the voice is, this may be from
;;; .../festival/lib/voices/ or from the current directory
(if (assoc 'bamu_mar_sangram_clunits voice-locations)
    (defvar bamu_mar_sangram::dir 
      (cdr (assoc 'bamu_mar_sangram_clunits voice-locations)))
    (defvar bamu_mar_sangram::dir (string-append (pwd) "/")))

;;; Did we succeed in finding it
(if (not (probe_file (path-append bamu_mar_sangram::dir "festvox/")))
    (begin
     (format stderr "bamu_mar_sangram::clunits: Can't find voice scm files they are not in\n")
     (format stderr "   %s\n" (path-append  bamu_mar_sangram::dir "festvox/"))
     (format stderr "   Either the voice isn't linked in Festival library\n")
     (format stderr "   or you are starting festival in the wrong directory\n")
     (error)))

;;;  Add the directory contains general voice stuff to load-path
(set! load-path (cons (path-append bamu_mar_sangram::dir "festvox/") 
		      load-path))

;;; Voice specific parameter are defined in each of the following
;;; files
(require 'bamu_mar_sangram_phoneset)
(require 'bamu_mar_sangram_tokenizer)
(require 'bamu_mar_sangram_tagger)
(require 'bamu_mar_sangram_lexicon)
(require 'bamu_mar_sangram_phrasing)
(require 'bamu_mar_sangram_intonation)
(require 'bamu_mar_sangram_duration)
(require 'bamu_mar_sangram_f0model)
(require 'bamu_mar_sangram_other)
;; ... and others as required

;;;
;;;  Code specific to the clunits waveform synthesis method
;;;

;;; Flag to save multiple loading of db
(defvar bamu_mar_sangram::clunits_loaded nil)
;;; When set to non-nil clunits voices *always* use their closest voice
;;; this is used when generating the prompts
(defvar bamu_mar_sangram::clunits_prompting_stage nil)
;;; Flag to allow new lexical items to be added only once
(defvar bamu_mar_sangram::clunits_added_extra_lex_items nil)

;;; You may wish to change this (only used in building the voice)
(set! bamu_mar_sangram::closest_voice 'voice_kal_diphone_mar)

(set! mar_phone_maps
      '(
;        (M_t t)
;        (M_dH d)
        ))

(define (voice_kal_diphone_mar_phone_maps utt)
  (mapcar
   (lambda (s) 
     (let ((m (assoc_string (item.name s) mar_phone_maps)))
       (if m
           (item.set_feat s "us_diphone" (cadr m))
           (item.set_feat s "us_diphone"))))
   (utt.relation.items utt 'Segment))
  utt)

(define (voice_kal_diphone_mar)
  (voice_kal_diphone)
  (set! UniSyn_module_hooks (list voice_kal_diphone_mar_phone_maps ))

  'kal_diphone_mar
)

;;;  These are the parameters which are needed at run time
;;;  build time parameters are added to his list in bamu_mar_sangram_build.scm
(set! bamu_mar_sangram::dt_params
      (list
       (list 'db_dir bamu_mar_sangram::dir)
       '(name bamu_mar_sangram)
       '(index_name bamu_mar_sangram)
       '(f0_join_weight 0.0)
       '(join_weights
         (0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 ))
       '(trees_dir "festival/trees/")
       '(catalogue_dir "festival/clunits/")
       '(coeffs_dir "mcep/")
       '(coeffs_ext ".mcep")
       '(clunit_name_feat lisp_bamu_mar_sangram::clunit_name)
       ;;  Run time parameters 
       '(join_method windowed)
       ;; if pitch mark extraction is bad this is better than the above
;       '(join_method smoothedjoin)
;       '(join_method modified_lpc)
       '(continuity_weight 5)
;       '(log_scores 1)  ;; good for high variance joins (not so good for ldom)
       '(optimal_coupling 1)
       '(extend_selections 2)
       '(pm_coeffs_dir "mcep/")
       '(pm_coeffs_ext ".mcep")
       '(sig_dir "wav/")
       '(sig_ext ".wav")
;       '(pm_coeffs_dir "lpc/")
;       '(pm_coeffs_ext ".lpc")
;       '(sig_dir "lpc/")
;       '(sig_ext ".res")
;       '(clunits_debug 1)
))

(define (bamu_mar_sangram::nextvoicing i)
  (let ((nname (item.feat i "n.name")))
    (cond
;     ((string-equal nname "pau")
;      "PAU")
     ((string-equal "+" (item.feat i "n.ph_vc"))
      "V")
     ((string-equal (item.feat i "n.ph_cvox") "+")
      "CVox")
     (t
      "UV"))))

(define (bamu_mar_sangram::clunit_name i)
  "(bamu_mar_sangram::clunit_name i)
Defines the unit name for unit selection for mar.  The can be modified
changes the basic classification of unit for the clustering.  By default
this we just use the phone name, but you may want to make this, phone
plus previous phone (or something else)."
  (let ((name (item.name i)))
    (cond
     ((and (not bamu_mar_sangram::clunits_loaded)
	   (or (string-equal "h#" name) 
	       (string-equal "1" (item.feat i "ignore"))
	       (and (string-equal "pau" name)
		    (or (string-equal "pau" (item.feat i "p.name"))
			(string-equal "h#" (item.feat i "p.name")))
		    (string-equal "pau" (item.feat i "n.name")))))
      "ignore")
     ;; Comment out this if you want a more interesting unit name
     ((null nil)
      name)

     ;; Comment out the above if you want to use these rules
     ((string-equal "+" (item.feat i "ph_vc"))
      (string-append
       name
       "_"
       (item.feat i "R:SylStructure.parent.stress")
       "_"
       (bamu_mar_sangram::nextvoicing i)))
     ((string-equal name "pau")
      (string-append
       name
       "_"
       (bamu_mar_sangram::nextvoicing i)))
     (t
      (string-append
       name
       "_"
;       (item.feat i "seg_onsetcoda")
;       "_"
       (bamu_mar_sangram::nextvoicing i))))))

(define (bamu_mar_sangram::clunits_load)
  "(bamu_mar_sangram::clunits_load)
Function that actual loads in the databases and selection trees.
SHould only be called once per session."
  (set! dt_params bamu_mar_sangram::dt_params)
  (set! clunits_params bamu_mar_sangram::dt_params)
  (clunits:load_db clunits_params)
  (load (string-append
	 (string-append 
	  bamu_mar_sangram::dir "/"
	  (get_param 'trees_dir dt_params "trees/")
	  (get_param 'index_name dt_params "all")
	  ".tree")))
  (set! bamu_mar_sangram::clunits_clunit_selection_trees clunits_selection_trees)
  (set! bamu_mar_sangram::clunits_loaded t))

(define (bamu_mar_sangram::voice_reset)
  "(bamu_mar_sangram::voice_reset)
Reset global variables back to previous voice."
  (bamu_mar_sangram::reset_phoneset)
  (bamu_mar_sangram::reset_tokenizer)
  (bamu_mar_sangram::reset_tagger)
  (bamu_mar_sangram::reset_lexicon)
  (bamu_mar_sangram::reset_phrasing)
  (bamu_mar_sangram::reset_intonation)
  (bamu_mar_sangram::reset_duration)
  (bamu_mar_sangram::reset_f0model)
  (bamu_mar_sangram::reset_other)

  t
)

;; This function is called to setup a voice.  It will typically
;; simply call functions that are defined in other files in this directory
;; Sometime these simply set up standard Festival modules othertimes
;; these will be specific to this voice.
;; Feel free to add to this list if your language requires it

(define (voice_bamu_mar_sangram_clunits)
  "(voice_bamu_mar_sangram_clunits)
Define voice for mar."
  ;; *always* required
  (voice_reset)

  ;; Select appropriate phone set
  (bamu_mar_sangram::select_phoneset)

  ;; Select appropriate tokenization
  (bamu_mar_sangram::select_tokenizer)

  ;; For part of speech tagging
  (bamu_mar_sangram::select_tagger)

  (bamu_mar_sangram::select_lexicon)
  ;; For clunits selection you probably don't want vowel reduction
  ;; the unit selection will do that
  (if (string-equal "americanenglish" (Param.get 'Language))
      (set! postlex_vowel_reduce_cart_tree nil))

  (bamu_mar_sangram::select_phrasing)

  (bamu_mar_sangram::select_intonation)

  (bamu_mar_sangram::select_duration)

  (bamu_mar_sangram::select_f0model)

  ;; Waveform synthesis model: clunits

  ;; Load in the clunits databases (or select it if its already loaded)
  (if (not bamu_mar_sangram::clunits_prompting_stage)
      (begin
	(if (not bamu_mar_sangram::clunits_loaded)
	    (bamu_mar_sangram::clunits_load)
	    (clunits:select 'bamu_mar_sangram))
	(set! clunits_selection_trees 
	      bamu_mar_sangram::clunits_clunit_selection_trees)
	(Parameter.set 'Synth_Method 'Cluster)))

  ;; This is where you can modify power (and sampling rate) if desired
  (set! after_synth_hooks nil)
;  (set! after_synth_hooks
;      (list
;        (lambda (utt)
;          (utt.wave.rescale utt 2.1))))

  (set! current_voice_reset bamu_mar_sangram::voice_reset)

  (set! current-voice 'bamu_mar_sangram_clunits)
)

(define (is_pau i)
  (if (phone_is_silence (item.name i))
      "1"
      "0"))

(define (cg_break s)
  "(cg_break s)
0, if word internal, 1 if word final, 4 if phrase final, we ignore 
3/4 distinguinction in old syl_break"
  (let ((x (item.feat s "syl_break")))
    (cond
     ((string-equal "0" x)
      (string-append x)
      )
     ((string-equal "1" x)
      (string-append x)
      )
     ((string-equal "0" (item.feat s "R:SylStructure.parent.n.name"))
      "4")
     (t
      "3"))))

(provide 'bamu_mar_sangram_clunits)

