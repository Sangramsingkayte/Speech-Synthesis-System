

;;; Try to find the directory where the voice is, this may be from
;;; .../festival/lib/voices/ or from the current directory
(if (assoc 'bamu_mar_sangram_cg voice-locations)
    (defvar bamu_mar_sangram::dir 
      (cdr (assoc 'bamu_mar_sangram_cg voice-locations)))
    (defvar bamu_mar_sangram::dir (string-append (pwd) "/")))

;;; Did we succeed in finding it
(if (not (probe_file (path-append bamu_mar_sangram::dir "festvox/")))
    (begin
     (format stderr "bamu_mar_sangram::clustergen: Can't find voice scm files they are not in\n")
     (format stderr "   %s\n" (path-append  bamu_mar_sangram::dir "festvox/"))
     (format stderr "   Either the voice isn't linked in Festival library\n")
     (format stderr "   or you are starting festival in the wrong directory\n")
     (error)))

;;;  Add the directory contains general voice stuff to load-path
(set! load-path (cons (path-append bamu_mar_sangram::dir "festvox/") 
		      load-path))

(require 'clustergen)  ;; runtime scheme support

;;; Voice specific parameter are defined in each of the following
;;; files
(require 'bamu_mar_sangram_phoneset)
(require 'bamu_mar_sangram_tokenizer)
(require 'bamu_mar_sangram_tagger)
(require 'bamu_mar_sangram_lexicon)
(require 'bamu_mar_sangram_phrasing)
(require 'bamu_mar_sangram_intonation)
(require 'bamu_mar_sangram_durdata_cg) 
(require 'bamu_mar_sangram_f0model)
(require 'bamu_mar_sangram_other)

(require 'bamu_mar_sangram_statenames)
;; ... and others as required

;;;
;;;  Code specific to the clustergen waveform synthesis method
;;;

;(set! cluster_synth_method 
;  (if (boundp 'mlsa_resynthesis)
;      cg_wave_synth
;      cg_wave_synth_external ))

;;; Flag to save multiple loading of db
(defvar bamu_mar_sangram::cg_loaded nil)
;;; When set to non-nil clunits voices *always* use their closest voice
;;; this is used when generating the prompts
(defvar bamu_mar_sangram::clunits_prompting_stage nil)

;;; You may wish to change this (only used in building the voice)
(set! bamu_mar_sangram::closest_voice 'voice_kal_diphone_mar)

(set! mar_phone_maps
      '(
;        (M_t t)
;        (M_dH d)
;        ...
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
;;;  build time parameters are added to this list from build_clunits.scm
(set! bamu_mar_sangram_cg::dt_params
      (list
       (list 'db_dir 
             (if (string-matches bamu_mar_sangram::dir ".*/")
                 bamu_mar_sangram::dir
                 (string-append bamu_mar_sangram::dir "/")))
       '(name bamu_mar_sangram)
       '(index_name bamu_mar_sangram)
       '(trees_dir "festival/trees/")
       '(clunit_name_feat lisp_bamu_mar_sangram::cg_name)
))

;; So as to fit nicely with existing clunit voices we check need to 
;; prepend these params if we already have some set.
(if (boundp 'bamu_mar_sangram::dt_params)
    (set! bamu_mar_sangram::dt_params
          (append 
           bamu_mar_sangram_cg::dt_params
           bamu_mar_sangram::dt_params))
    (set! bamu_mar_sangram::dt_params bamu_mar_sangram_cg::dt_params))

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

(define (bamu_mar_sangram::cg_name i)
  (let ((x nil))
  (if (assoc 'cg::trajectory clustergen_mcep_trees)
      (set! x i)
      (set! x (item.relation.parent i 'mcep_link)))

  (let ((ph_clunit_name 
         (bamu_mar_sangram::clunit_name_real
          (item.relation
           (item.relation.parent x 'segstate)
           'Segment))))
    (cond
     ((string-equal ph_clunit_name "ignore")
      "ignore")
     (t
      (item.name i)))))
)

(define (bamu_mar_sangram::clunit_name_real i)
  "(bamu_mar_sangram::clunit_name i)
Defines the unit name for unit selection for mar.  The can be modified
changes the basic classification of unit for the clustering.  By default
this we just use the phone name, but you may want to make this, phone
plus previous phone (or something else)."
  (let ((name (item.name i)))
    (cond
     ((and (not bamu_mar_sangram::cg_loaded)
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

(define (bamu_mar_sangram::cg_load)
  "(bamu_mar_sangram::cg_load)
Function that actual loads in the databases and selection trees.
SHould only be called once per session."
  (set! dt_params bamu_mar_sangram::dt_params)
  (set! clustergen_params bamu_mar_sangram::dt_params)
  (if cg:multimodel
      (begin
        ;; Multimodel: separately trained statics and deltas
        (set! bamu_mar_sangram::static_param_vectors
              (track.load
               (string-append 
                bamu_mar_sangram::dir "/"
                (get_param 'trees_dir dt_params "trees/")
                (get_param 'index_name dt_params "all")
                "_mcep_static.params")))
        (set! bamu_mar_sangram::clustergen_static_mcep_trees
              (load (string-append 
                     bamu_mar_sangram::dir "/"
                     (get_param 'trees_dir dt_params "trees/")
                     (get_param 'index_name dt_params "all")
                     "_mcep_static.tree") t))
        (set! bamu_mar_sangram::delta_param_vectors
              (track.load
               (string-append 
                bamu_mar_sangram::dir "/"
                (get_param 'trees_dir dt_params "trees/")
                (get_param 'index_name dt_params "all")
                "_mcep_delta.params")))
        (set! bamu_mar_sangram::clustergen_delta_mcep_trees
              (load (string-append 
                     bamu_mar_sangram::dir "/"
                     (get_param 'trees_dir dt_params "trees/")
                     (get_param 'index_name dt_params "all")
                     "_mcep_delta.tree") t))
        (set! bamu_mar_sangram::str_param_vectors
              (track.load
               (string-append
                bamu_mar_sangram::dir "/"
                (get_param 'trees_dir dt_params "trees/")
                (get_param 'index_name dt_params "all")
                "_str.params")))
        (set! bamu_mar_sangram::clustergen_str_mcep_trees
              (load (string-append
                     bamu_mar_sangram::dir "/"
                     (get_param 'trees_dir dt_params "trees/")
                     (get_param 'index_name dt_params "all")
                     "_str.tree") t))
        (if (null (assoc 'cg::trajectory bamu_mar_sangram::clustergen_static_mcep_trees))
            (set! bamu_mar_sangram::clustergen_f0_trees
                  (load (string-append 
                          bamu_mar_sangram::dir "/"
                          (get_param 'trees_dir dt_params "trees/")
                          (get_param 'index_name dt_params "all")
                          "_f0.tree") t)))
        )
      (begin
        ;; Single joint model 
        (set! bamu_mar_sangram::param_vectors
              (track.load
               (string-append 
                bamu_mar_sangram::dir "/"
                (get_param 'trees_dir dt_params "trees/")
                (get_param 'index_name dt_params "all")
                "_mcep.params")))
        (set! bamu_mar_sangram::clustergen_mcep_trees
              (load (string-append 
                      bamu_mar_sangram::dir "/"
                      (get_param 'trees_dir dt_params "trees/")
                      (get_param 'index_name dt_params "all")
                      "_mcep.tree") t))
        (if (null (assoc 'cg::trajectory bamu_mar_sangram::clustergen_mcep_trees))
            (set! bamu_mar_sangram::clustergen_f0_trees
                  (load (string-append 
                         bamu_mar_sangram::dir "/"
                         (get_param 'trees_dir dt_params "trees/")
                         (get_param 'index_name dt_params "all")
                         "_f0.tree") t)))))

  (set! bamu_mar_sangram::cg_loaded t)
)

(define (bamu_mar_sangram::voice_reset)
  "(bamu_mar_sangram::voice_reset)
Reset global variables back to previous voice."
  (bamu_mar_sangram::reset_phoneset)
  (bamu_mar_sangram::reset_tokenizer)
  (bamu_mar_sangram::reset_tagger)
  (bamu_mar_sangram::reset_lexicon)
  (bamu_mar_sangram::reset_phrasing)
  (bamu_mar_sangram::reset_intonation)
  (bamu_mar_sangram::reset_f0model)
  (bamu_mar_sangram::reset_other)

  t
)

;; This function is called to setup a voice.  It will typically
;; simply call functions that are defined in other files in this directory
;; Sometime these simply set up standard Festival modules othertimes
;; these will be specific to this voice.
;; Feel free to add to this list if your language requires it

(define (voice_bamu_mar_sangram_cg)
  "(voice_bamu_mar_sangram_cg)
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

  (bamu_mar_sangram::select_phrasing)

  (bamu_mar_sangram::select_intonation)

  ;; For CG voice there is no duration modeling at the seg level
  (Parameter.set 'Duration_Method 'Default)
  (set! duration_cart_tree_cg bamu_mar_sangram::zdur_tree)
  (set! duration_ph_info_cg bamu_mar_sangram::phone_durs)
  (Parameter.set 'Duration_Stretch 1.0)

  (bamu_mar_sangram::select_f0model)

  ;; Waveform synthesis model: cluster_gen
  (set! phone_to_states bamu_mar_sangram::phone_to_states)
  (if (not bamu_mar_sangram::clunits_prompting_stage)
      (begin
	(if (not bamu_mar_sangram::cg_loaded)
	    (bamu_mar_sangram::cg_load))
        (if cg:multimodel
            (begin
              (set! clustergen_param_vectors bamu_mar_sangram::static_param_vectors)
              (set! clustergen_mcep_trees bamu_mar_sangram::clustergen_static_mcep_trees)
              (set! clustergen_delta_param_vectors bamu_mar_sangram::delta_param_vectors)
              (set! clustergen_delta_mcep_trees bamu_mar_sangram::clustergen_delta_mcep_trees)
              (set! clustergen_str_param_vectors bamu_mar_sangram::str_param_vectors)
              (set! clustergen_str_mcep_trees bamu_mar_sangram::clustergen_str_mcep_trees)

              )
            (begin
              (set! clustergen_param_vectors bamu_mar_sangram::param_vectors)
              (set! clustergen_mcep_trees bamu_mar_sangram::clustergen_mcep_trees)
              ))
        (if (boundp 'bamu_mar_sangram::clustergen_f0_trees)
            (set! clustergen_f0_trees bamu_mar_sangram::clustergen_f0_trees))
	(Parameter.set 'Synth_Method 'ClusterGen)
      ))

  ;; This is where you can modify power (and sampling rate) if desired
  (set! after_synth_hooks nil)
;  (set! after_synth_hooks
;      (list
;        (lambda (utt)
;          (utt.wave.rescale utt 2.1))))

  (set! current_voice_reset bamu_mar_sangram::voice_reset)

  (set! current-voice 'bamu_mar_sangram_cg)
)

(define (is_pau i)
  (if (phone_is_silence (item.name i))
      "1"
      "0"))

(provide 'bamu_mar_sangram_cg)

