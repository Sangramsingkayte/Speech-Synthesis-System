;;; Lexicon, LTS and Postlexical rules for bamu_mar
;;;

;;; Load any necessary files here
(load "festvox/bamu_mar_sangram_lex.lookup.scm")

(define (bamu_mar_addenda)
  "(bamu_mar_addenda)
Basic lexicon should (must ?) have basic letters, symbols and punctuation."

;;; Pronunciation of letters in the alphabet
;(lex.add.entry '("a" nn (((a) 0))))
;(lex.add.entry '("b" nn (((b e) 0))))
;(lex.add.entry '("c" nn (((th e) 0))))
;(lex.add.entry '("d" nn (((d e) 0))))
;(lex.add.entry '("e" nn (((e) 0))))
; ...

;;; Symbols ...
;(lex.add.entry 
; '("*" n (((a s) 0) ((t e) 0) ((r i1 s) 1)  ((k o) 0))))
;(lex.add.entry 
; '("%" n (((p o r) 0) ((th i e1 n) 1) ((t o) 0))))

;; Basic punctuation must be in with nil pronunciation
(lex.add.entry '("." punc nil))
;(lex.add.entry '("." nn (((p u1 n) 1) ((t o) 0))))
(lex.add.entry '("'" punc nil))
(lex.add.entry '(":" punc nil))
(lex.add.entry '(";" punc nil))
(lex.add.entry '("," punc nil))
;(lex.add.entry '("," nn (((k o1) 1) ((m a) 0))))
(lex.add.entry '("-" punc nil))
(lex.add.entry '("\"" punc nil))
(lex.add.entry '("`" punc nil))
(lex.add.entry '("?" punc nil))
(lex.add.entry '("!" punc nil))
)

(require 'lts)

;;;  Function called when word not found in lexicon
;;;  and you've trained letter to sound rules
(define (bamu_mar_lts_function word features)
  "(bamu_mar_lts_function WORD FEATURES)
Return pronunciation of word not in lexicon."
  (let ((dword (downcase word)) (phones) (syls))
    ;(format t "%s\t" dword)
    (set! phones (phonify dword))
    ;(format t "%s\t%l\n" dword phones)
    (set! syls (syllibify phones))
    ;(format t "%l\t%l\n" phones syls)
    ;(set! wordstruct syls)
    (list word nil syls))
    ;(format t "%l\n" word)
;  (if (not boundp 'bamu_mar_lts_rules)
 ;     (require 'bamu_mar_lts_rules))
;  (let ((dword (downcase word)) (phones) (syls))
;    (set! phones (lts_predict dword bamu_mar_lts_rules))
 ;   (set! syls (bamu_mar_lex_syllabify_phstress phones))
;    (list word features syls))


)

;; utf8 letter based one
;(define (bamu_mar_lts_function word features)
;  "(bamu_mar_lts_function WORD FEATURES)
;Return pronunciation of word not in lexicon."
;  (let ((dword word) (phones) (syls))
;    (set! phones (utf8explode dword))
;    (set! syls (bamu_mar_lex_syllabify_phstress phones))
;    (list word features syls)))

(define (bamu_mar_is_vowel x)
  (string-equal "+" (phone_feature x "vc")))

(define (bamu_mar_contains_vowel l)
  (member_string
   t
   (mapcar (lambda (x) (bamu_mar_is_vowel x)) l)))

(define (bamu_mar_lex_sylbreak currentsyl remainder)
  "(bamu_mar_lex_sylbreak currentsyl remainder)
t if this is a syl break, nil otherwise."
  (cond
   ((not (bamu_mar_contains_vowel remainder))
    nil)
   ((not (bamu_mar_contains_vowel currentsyl))
    nil)
   (t
    ;; overly naive, I mean wrong
    t))
)

(define (bamu_mar_lex_syllabify_phstress phones)
 (let ((syl nil) (syls nil) (p phones) (stress 0))
    (while p
     (set! syl nil)
     (set! stress 0)
     (while (and p (not (bamu_mar_lex_sylbreak syl p)))
       (if (string-matches (car p) "xxxx")
           (begin
             ;; whatever you do to identify stress
             (set! stress 1)
             (set syl (cons (car p-stress) syl)))
           (set! syl (cons (car p) syl)))
       (set! p (cdr p)))
     (set! syls (cons (list (reverse syl) stress) syls)))
    (reverse syls)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; OR: Hand written letter to sound rules
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ;;;  Function called when word not found in lexicon
; (define (bamu_mar_lts_function word features)
;   "(bamu_mar_lts_function WORD FEATURES)
; Return pronunciation of word not in lexicon."
;   (format stderr "failed to find pronunciation for %s\n" word)
;   (let ((dword (downcase word)))
;     ;; Note you may need to use a letter to sound rule set to do
;     ;; casing if the language has non-ascii characters in it.
;     (if (lts.in.alphabet word 'bamu_mar)
; 	(list
; 	 word
; 	 features
; 	 ;; This syllabification is almost certainly wrong for
; 	 ;; this language (its not even very good for English)
; 	 ;; but it will give you something to start off with
; 	 (lex.syllabify.phstress
; 	   (lts.apply word 'bamu_mar)))
; 	(begin
; 	  (format stderr "unpronouncable word %s\n" word)
; 	  ;; Put in a word that means "unknown" with its pronunciation
; 	  '("nepoznat" nil (((N EH P) 0) ((AO Z) 0) ((N AA T) 0))))))
; )

; ;; You may or may not be able to write a letter to sound rule set for
; ;; your language.  If its largely lexicon based learning a rule
; ;; set will be better and easier that writing one (probably).
; (lts.ruleset
;  bamu_mar
;  (  (Vowel WHATEVER) )
;  (
;   ;; LTS rules 
;   ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Postlexical Rules 
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (bamu_mar::postlex_rule1 utt)
  "(bamu_mar::postlex_rule1 utt)
A postlexical rule form correcting phenomena over word boundaries."
  (mapcar
   (lambda (s)
     ;; do something
     )
   (utt.relation.items utt 'Segment))
   utt)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Lexicon definition
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(lex.create "bamu_mar")
(lex.set.phoneset "bamu_mar")
(lex.set.lts.method 'bamu_mar_lts_function)
(if (probe_file (path-append bamu_mar_sangram::dir "festvox/bamu_mar_lex.out"))
    (lex.set.compile.file (path-append bamu_mar_sangram::dir 
                                       "festvox/bamu_mar_lex.out")))
(bamu_mar_addenda)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Lexicon setup
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (bamu_mar_sangram::select_lexicon)
  "(bamu_mar_sangram::select_lexicon)
Set up the lexicon for bamu_mar."
  (lex.select "bamu_mar")

  ;; Post lexical rules
  (set! postlex_rules_hooks (list bamu_mar::postlex_rule1))
)

(define (bamu_mar_sangram::reset_lexicon)
  "(bamu_mar_sangram::reset_lexicon)
Reset lexicon information."
  t
)

(provide 'bamu_mar_sangram_lexicon)
