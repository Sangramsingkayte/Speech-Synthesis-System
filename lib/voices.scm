;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                                                                       ;;
;;;                Centre for Speech Technology Research                  ;;
;;;                     University of Edinburgh, UK                       ;;
;;;                       Copyright (c) 1996,1997                         ;;
;;;                        All Rights Reserved.                           ;;
;;;                                                                       ;;
;;;  Permission is hereby granted, free of charge, to use and distribute  ;;
;;;  this software and its documentation without restriction, including   ;;
;;;  without limitation the rights to use, copy, modify, merge, publish,  ;;
;;;  distribute, sublicense, and/or sell copies of this work, and to      ;;
;;;  permit persons to whom this work is furnished to do so, subject to   ;;
;;;  the following conditions:                                            ;;
;;;   1. The code must retain the above copyright notice, this list of    ;;
;;;      conditions and the following disclaimer.                         ;;
;;;   2. Any modifications must be clearly marked as such.                ;;
;;;   3. Original authors' names are not deleted.                         ;;
;;;   4. The authors' names are not used to endorse or promote products   ;;
;;;      derived from this software without specific prior written        ;;
;;;      permission.                                                      ;;
;;;                                                                       ;;
;;;  THE UNIVERSITY OF EDINBURGH AND THE CONTRIBUTORS TO THIS WORK        ;;
;;;  DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING      ;;
;;;  ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT   ;;
;;;  SHALL THE UNIVERSITY OF EDINBURGH NOR THE CONTRIBUTORS BE LIABLE     ;;
;;;  FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES    ;;
;;;  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN   ;;
;;;  AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,          ;;
;;;  ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF       ;;
;;;  THIS SOFTWARE.                                                       ;;
;;;                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Prepare to access voices. Searches down a path of places.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define current-voice nil
  "current-voice
   The name of the current voice.")

;; The path to search for voices is created from the load-path with
;; an extra list of directories appended.

(defvar system-voice-path '( )
  "system-voice-path
   Additional directory not near the load path where voices can be
   found, this can be redefined in lib/sitevars.scm if desired.")

(defvar system-voice-path-multisyn '( )
  "system-voice-path-multisyn
   Additional directory not near the load path where multisyn voices can be
   found, this can be redefined in lib/sitevars.scm if desired.")

(defvar voice-path 
  (remove-duplicates
   (append (mapcar (lambda (d) (path-append d "voices/")) load-path)
	   (mapcar (lambda (d) (path-as-directory d)) system-voice-path)
	   ))

  "voice-path
   List of places to look for voices. If not set it is initialised from
   load-path by appending \"voices/\" to each directory with 
   system-voice-path appended.")

(defvar voice-path-multisyn 
  (remove-duplicates
   (append (mapcar (lambda (d) (path-append d "voices-multisyn/")) load-path)
	   (mapcar (lambda (d) (path-as-directory d)) system-voice-path-multisyn)
	   ))

  "voice-path-multisyn
   List of places to look for multisyn voices. If not set it is initialised from
   load-path by appending \"voices-multisyn/\" to each directory with 
   system-voice-path-multisyn appended.")


;; Declaration of voices. When we declare a voice we record the
;; directory and set up an autoload for the voice-selecting function

(defvar voice-locations ()
  "voice-locations
   Association list recording where voices were found.")

(defvar voice-location-trace nil
  "voice-location-trace
   Set t to print voice locations as they are found")

(define (voice-location name dir doc)
  "(voice-location NAME DIR DOCSTRING)
   Record the location of a voice. Called for each voice found on voice-path.
   Can be called in site-init or .festivalrc for additional voices which
   exist elsewhere."
  (let ((func_name (intern (string-append "voice_" name)))
	)

    (set! name (intern name))
    (set! voice-locations (cons (cons name dir) voice-locations))
    (eval (list 'autoload func_name (path-append dir "festvox/" name) doc))
    (if voice-location-trace
	(format t "Voice: %s %s\n" name dir)
	)
    )
  )

(define (voice-location-multisyn name rootname dir doc)
  "(voice-location NAME ROOTNAME DIR DOCSTRING)
   Record the location of a voice. Called for each voice found on voice-path.
   Can be called in site-init or .festivalrc for additional voices which
   exist elsewhere."
  (let ((func_name (intern (string-append "voice_" name)))
	)

    (set! name (intern name))
    (set! voice-locations (cons (cons name dir) voice-locations))
    (eval (list 'autoload func_name (path-append dir "festvox/" rootname) doc))
    (if voice-location-trace
	(format t "Voice: %s %s\n" name dir)
	)
    )
  )



(define (current_voice_reset)
"(current_voice_reset)
This function is called at the start of defining any new voice.
It is design to allow the previous voice to reset any global
values it has messed with.  If this variable value is nil then
the function wont be called.")

(define (voice_reset)
"(voice_reset)
This resets all variables back to acceptable values that may affect
voice generation.  This function should always be called at the
start of any function defining a voice.  In addition to reseting
standard variables the function current_voice_reset will be called.
This should always be set by the voice definition function (even
if it does nothing).  This allows voice specific changes to be reset
when a new voice is selection.  Unfortunately I can't force this
to be used."
   (Param.set 'Duration_Stretch 1.0)
   (set! after_synth_hooks default_after_synth_hooks)

   ;; The follow are reset to allow existing voices to continue
   ;; to work, new voices should be setting these explicitly
   (Param.set 'Text_Method 'Text_int)
   (Param.set 'Token_Method 'Token_English)
   (Param.set 'POS_Method Classic_POS)
   (Param.set 'Phrasify_Method Classic_Phrasify)
   (Param.set 'Word_Method Classic_Word)
   (Param.set 'Pause_Method Classic_Pauses)
   (Param.set 'PostLex_Method Classic_PostLex)
   ;; From pos.scm:
   (set! pos_p_start_tag "punc")
   (set! pos_pp_start_tag "nn")
   (set! pos_supported nil)
   (set! pos_ngram_name nil)
   (set! pos_map nil)

   (set! diphone_module_hooks nil)
   (set! UniSyn_module_hooks nil)

   (if current_voice_reset
       (current_voice_reset))
   (set! current_voice_reset nil)
)


(defvar Voice_descriptions nil
  "Internal variable containing list of voice descriptions as
decribed by proclaim_voice.")

(define (proclaim_voice name description)
"(proclaim_voice NAME DESCRIPTION)
Describe a voice to the systen.  NAME should be atomic name, that
conventionally will have voice_ prepended to name the basic selection
function.  OPTIONS is an assoc list of feature and value and must
have at least features for language, gender, dialect and 
description.  The first there of these are atomic, while the description
is a text string describing the voice."
  (let ((voxdesc (assoc name Voice_descriptions)))
    (if voxdesc
	(set-car! (cdr voxdesc) description)
	(set! Voice_descriptions 
	      (cons (list name description) Voice_descriptions))))
)

(define (voice.description name)
"(voice.description NAME)
Output description of named voice.  If the named voice is not yet loaded
it is loaded."
  (let ((voxdesc (assoc name Voice_descriptions))
	(cv current-voice))
    (if (null voxdesc)
	(unwind-protect
	 (begin 
	   (voice.select name)
	   (voice.select cv) ;; switch back to current voice
	   (set! voxdesc (assoc name Voice_descriptions)))))
    (if voxdesc
       voxdesc
       (begin
	 (format t "SIOD: unknown voice %s\n" name)
	 nil))))

(define (voice.select name)
"(voice.select NAME)
Call function to set up voice NAME.  This is normally done by 
prepending voice_ to NAME and call it as a function."
  (eval (list (intern (string-append "voice_" name)))))

(define (voice.describe name)
"(voice.describe NAME)
Describe voice NAME by saying its description.  Unfortunately although
it would be nice to say that voice's description in the voice itself
its not going to work cross language.  So this just uses the current
voice.  So here we assume voices describe themselves in English 
which is pretty anglo-centric, shitsurei shimasu."
  (let ((voxdesc (voice.description name)))
    (let ((desc (car (cdr (assoc 'description (car (cdr voxdesc)))))))
      (cond
       (desc (tts_text desc nil))
       (voxdesc 
	(SayText 
	 (format nil "A voice called %s exist but it has no description"
		 name)))
       (t
	(SayText 
	 (format nil "There is no voice called %s defined" name)))))))

(define (voice.list)
"(voice.list)
List of all (potential) voices in the system.  This checks the voice-location
list of potential voices found be scanning the voice-path at start up time.
These names can be used as arguments to voice.description and
voice.describe."
   (mapcar car voice-locations))

(define (voice.find parameters)
"(voice.find PARAMETERS)
List of the (potential) voices in the system that match the PARAMETERS described
in the proclaim_voice description fields."
  (let ((voices (eval (list voice.list)))
        (validvoices nil)
        (voice nil)
       )
    (while parameters
      (while voices
        (set! voice (car voices))
;;I believe the next line should be improved. equal? doesn't work always.
        (if (equal? (list (cadr (assoc (caar parameters)
                                       (cadr (assoc voice Voice_descriptions))
                                ))) (cdar parameters))
            (begin
              (set! validvoices (append (list voice) validvoices))
            )
        )
        (set! voices (cdr voices))
      )
      (set! voices validvoices)
      (set! validvoices nil)
      (set! parameters (cdr parameters))
    )
  voices
  )
)

;; Voices are found on the voice-path if they are in directories of the form
;;		DIR/LANGUAGE/NAME

(define (search-for-voices)
  "(search-for-voices)
   Search down voice-path to locate voices."

  (let ((dirs voice-path)
	(dir nil)
	languages language
	voices voicedir voice voice_proclaimed
	)
    (while dirs
     (set! dir (car dirs))
     (setq languages (directory-entries dir t))
     (while languages
       (set! language (car languages))
       (set! voice_proclaimed nil) ; flag to mark if proclaim_voice is found
       (set! voices (directory-entries (path-append dir language) t))
       (while voices
	 (set! voicedir (car voices))
	 (set! voice (path-basename voicedir))
	 (if (or (string-matches voicedir ".*\\..*") 
             (not (probe_file (path-append dir language voicedir "festvox" (string-append voicedir ".scm"))))
             );; if directory is \.. or voice description doesn't exist, then do nothing. Else, load voice
	     nil
             (begin
	       ;; Do the voice proclamation: load the voice definition file.
	       (set! voice-def-file (load (path-append dir language voicedir "festvox" 
						       (string-append voicedir ".scm")) t))
	       ;; now find the "proclaim_voice" lines and register these voices.
	       (mapcar
		(lambda (line)
		  (if (string-matches (car line) "proclaim_voice")
                    (begin
		                (voice-location (intern (cadr (cadr line)))
                                    (path-as-directory (path-append dir language voicedir)) "registered voice")
                      (eval line)
                    (set! voice_proclaimed t)
                    )
                  )
                )
		voice-def-file)
               (if (not voice_proclaimed) ;proclaim_voice is missing. Use old voice location method
                 (voice-location voice
                  (path-as-directory (path-append dir language voicedir))
                    "voice found on path")
               )
             )
	 )
	 (set! voices (cdr voices))
	 )
       (set! languages (cdr languages))
       )
     (set! dirs (cdr dirs))
     )
    )
  )

;; A single file is allowed to define multiple multisyn voices, so this has
;; been adapted for this. Rob thinks this is just evil, but couldn't think
;; of a better way.
(define (search-for-voices-multisyn)
  "(search-for-voices-multisyn)
   Search down multisyn voice-path to locate multisyn voices."
  (let ((dirs voice-path-multisyn)
	(dir nil)
	languages language
	voices voicedir voice voice-list
	)
    (while dirs
     (set! dir (car dirs))
     (set! languages (directory-entries dir t))
     (while languages
       (set! language (car languages))
       (set! voices (directory-entries (path-append dir language) t))
       (while voices
	 (set! voicedir (car voices))
	 (set! voice (path-basename voicedir))
	 (if (or (string-matches voicedir ".*\\..*") 
                 (not (probe_file (path-append dir language voicedir "festvox" (string-append voicedir ".scm"))))
             );; if directory is \.. or voice description doesn't exist, then do nothing. Else, load voice
	     nil
	     (begin
	       ;; load the voice definition file, but don't evaluate it!
	       (set! voice-def-file (load (path-append dir language voicedir "festvox" 
						       (string-append voicedir ".scm")) t))
	       ;; now find the "proclaim_voice" lines and register these voices.
	       (mapcar
		(lambda (line)
		  (if (string-matches (car line) "proclaim_voice")
                    (begin
		      (voice-location-multisyn (intern (cadr (cadr line)))  voicedir (path-append dir language voicedir) "registerd multisyn voice")
                      (eval line)
                    )
                  )
                )
		voice-def-file)
	     ))
	 (set! voices (cdr voices)))
       (set! languages (cdr languages)))
     (set! dirs (cdr dirs)))))

(search-for-voices)
(search-for-voices-multisyn)

;; We select the default voice from a list of possibilities. One of these
;; had better exist in every installation.

(define (no_voice_error)
  (format t "\nWARNING\n")
  (format t "No default voice found in %l\n" voice-path)
  (format t "either no voices unpacked or voice-path is wrong\n")
  (format t "Scheme interpreter will work, but there is no voice to speak with.\n")
  (format t "WARNING\n\n"))

(defvar voice_default 'no_voice_error
 "voice_default
A variable whose value is a function name that is called on start up to
the default voice. [see Site initialization]")

(defvar default-voice-priority-list 
  (reverse (remove-duplicates (reverse 
  (append 
    (list
      ; A default hardcoded list with higher priority
      'kal_diphone
      'cmu_us_slt_cg
      'cmu_us_rms_cg
      'cmu_us_bdl_cg
      'cmu_us_jmk_cg
      'cmu_us_awb_cg
      'cstr_rpx_nina_multisyn       ; restricted license (lexicon)
      'cstr_rpx_jon_multisyn       ; restricted license (lexicon)
      'cstr_edi_awb_arctic_multisyn ; restricted license (lexicon)
      'cstr_us_awb_arctic_multisyn
      'nitech_us_slt_arctic_hts
      'nitech_us_awb_arctic_hts
      'nitech_us_bdl_arctic_hts
      'nitech_us_clb_arctic_hts
      'nitech_us_jmk_arctic_hts
      'nitech_us_rms_arctic_hts
      'ked_diphone
      'don_diphone
      'rab_diphone
      'en1_mbrola
      'us1_mbrola
      'us2_mbrola
      'us3_mbrola
      'gsw_diphone  ;; not publically distributed
      'el_diphone
      'ked_diphone
      'cstr_us_awb_arctic_multisyn
      'cstr_us_jmk_arctic_multisyn
    )
    ; Any clustergen voice
    (voice.find (list (list 'engine 'clustergen)))
    ; Any hts voice
    (voice.find (list (list 'engine 'hts)))
    ; Any multisyn voice
    (voice.find (list (list 'engine 'multisyn)))
    ; Any diphone voice
    (voice.find (list (list 'engine 'diphone)))
    ; Any clunits voice
    (voice.find (list (list 'engine 'clunits)))
    ; Any voice
    (voice.list)
  ))))
  "default-voice-priority-list
   List of voice names. The first of them available becomes the default voice.")


(define (voice.remove_unavailable voices)
 "voice.remove_unavailable VOICES takes a list of voice names and returns
a list with the voices in VOICES available."
  (let ((output (mapcar (lambda(x) (if (assoc (intern x) voice-locations ) (intern x))) voices)))
    (while (member nil output)
       (set! output (remove nil output))
    )
  output
  )
)



(define (set_voice_default voices)
 "set_voice_default VOICES sets as voice_default the first voice available from VOICES list"
  (let ( (avail_voices (voice.remove_unavailable voices))
       )
       (if avail_voices
         (begin
           (set! voice_default (intern (string-append "voice_" (car avail_voices))))
          t
         )
         (begin 
           (print "Could not find any of these voices:")
           (print voices)
           nil
         )
       )
  )
)


(set_voice_default default-voice-priority-list)
(provide 'voices)
