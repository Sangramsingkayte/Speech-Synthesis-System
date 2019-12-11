
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Tokenizer for mar
;;;
;;;  To share this among voices you need to promote this file to
;;;  to say festival/lib/bamu_mar/ so others can use it.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Load any other required files

;; Punctuation for the particular language
(set! bamu_mar_sangram::token.punctuation "\"'`.,;!?(){}[]")
(set! bamu_mar_sangram::token.prepunctuation "\"'`({[")
(set! bamu_mar_sangram::token.whitespace " \t\n\r")
(set! bamu_mar_sangram::token.singlecharsymbols "")

;;; Voice/mar token_to_word rules 
(define (bamu_mar_sangram::token_to_words token name)
  "(bamu_mar_sangram::token_to_words token name)
Specific token to word rules for the voice bamu_mar_sangram.  Returns a list
of words that expand given token with name."
  (cond
   ((string-matches name "[1-9][0-9]+")
    (bamu_mar::number token name))
   (t ;; when no specific rules apply do the general ones
    (list name))))

(define (bamu_mar::number token name)
  "(bamu_mar::number token name)
Return list of words that pronounce this number in mar."

  (error "bamu_mar::number to be written\n")

)

(define (bamu_mar_sangram::select_tokenizer)
  "(bamu_mar_sangram::select_tokenizer)
Set up tokenizer for mar."
  (Parameter.set 'Language 'bamu_mar)
  (set! token.punctuation bamu_mar_sangram::token.punctuation)
  (set! token.prepunctuation bamu_mar_sangram::token.prepunctuation)
  (set! token.whitespace bamu_mar_sangram::token.whitespace)
  (set! token.singlecharsymbols bamu_mar_sangram::token.singlecharsymbols)

  (set! token_to_words bamu_mar_sangram::token_to_words)
)

(define (bamu_mar_sangram::reset_tokenizer)
  "(bamu_mar_sangram::reset_tokenizer)
Reset any globals modified for this voice.  Called by 
(bamu_mar_sangram::voice_reset)."
  ;; None

  t
)

(provide 'bamu_mar_sangram_tokenizer)
