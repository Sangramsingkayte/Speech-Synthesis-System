;;; Phonset for bamu_mar
;;;

;;;  Feeel free to add new feature values, or new features to this
;;;  list to make it more appropriate to your language

;; This is where it'll fall over if you haven't defined a 
;; a phoneset yet, if you have, delete this, if you haven't
;; define one then delete this error message
;(error "You have not yet defined a phoneset for mar (and others things ?)\n            Define it in festvox/bamu_mar_sangram_phoneset.scm\n")

(defPhoneSet
  bamu_mar
  ;;;  Phone Features
  (;; vowel or consonant
   (clst + -)
   (vc + -)  
   ;; vowel length: short long dipthong schwa
   (vlng s l d a 0)
   ;; vowel height: high mid low
   (vheight 1 2 3 0 -)
   ;; vowel frontness: front mid back
   (vfront 1 2 3 0 -)
   ;; lip rounding
   (vrnd + - 0)
   ;; consonant type: stop fricative affricative nasal liquid
   (ctype s f a n l r 0)
   ;; place of articulation: labial alveolar palatal labio-dental
   ;;                         dental velar
   (cplace l a p b d v g 0)
   ;; consonant voicing
   (cvox + - 0)
   (asp + - 0)
   (nuk + - 0)
   )
  (
;   (pau  - 0 - - - 0 0 -)  ;; slience ... 

  (SIL    - -       0    0    0    -    0    0    0    0    0)  ;; slience ...
   (a      - +       s    2    2    -    0    0    0    -    0)
   (tra    + +       s    2    2    -    s    d    +    -    0)
   (t:ra   + +       s    2    2    -    s    b    +    -    0)
   (h:     - +       s    2    2    -    f    0    -    +    0)
   (aa     - +       l    3    2    -    0    0    0    -    0)
   (i      - +       s    1    1    -    0    0    0    -    0)
   (ii     - +       l    1    1    -    0    0    0    -    0)
   (u      - +       s    1    3    +    0    0    0    -    0)
   (uu     - +       l    1    3    +    0    0    0    -    0)
   (rx     - +       s    1    3    +    0    0    0    -    0)
   (ei     - +       l    2    1    -    0    0    0    -    0)
   (ai     - +       d    2    1    -    0    0    0    -    0)
   (oo     - +       l    2    3    +    0    0    0    -    0)
   (au     - +       d    1    3    +    0    0    0    -    0)
   (k      - -       0    0    0    0    s    v    -    -    -)
   (kh     - -       0    0    0    0    s    v    -    +    -)
   (g      - -       0    0    0    0    s    v    +    -    -)
   (gh     - -       0    0    0    0    s    v    +    +    -)
   (ng~    - -       0    0    0    0    n    v    +    -    -)
   (ch     - -       0    0    0    0    a    p    -    -    -)
   (chh    - -       0    0    0    0    a    p    -    +    -)
   (j      - -       0    0    0    0    a    p    +    -    -)
   (jh     - -       0    0    0    0    a    p    +    +    -)
   (nj~    - -       0    0    0    0    n    p    +    -    -)
   (t      - -       0    0    0    0    s    d    -    -    -)
   (th     - -       0    0    0    0    s    d    -    +    -)
   (d      - -       0    0    0    0    s    d    +    -    -)
   (dh     - -       0    0    0    0    s    d    +    +    -)
   (n      - -       0    0    0    0    n    d    +    -    -)
   (t:     - -       0    0    0    0    s    a    -    -    -)
   (t:h    - -       0    0    0    0    s    a    -    +    -)
   (d:     - -       0    0    0    0    s    a    +    -    -)
   (d:h    - -       0    0    0    0    s    a    +    +    -)
   (nd~    - -       0    0    0    0    n    a    +    -    -)
   (p      - -       0    0    0    0    s    l    -    -    -)
   (ph     - -       0    0    0    0    s    l    -    +    -)
   (b      - -       0    0    0    0    s    l    +    -    -)
   (bh     - -       0    0    0    0    s    l    +    +    -)
   (m      - -       0    0    0    0    n    l    +    -    -)
   (y      - -       0    0    0    0    l    v    +    -    -)
   (r      - -       0    0    0    0    l    p    +    -    -)
   (l      - -       0    0    0    0    l    d    +    -    -)
   (l:     - -       0    0    0    0    l    p    +    -    -)
   (v      - -       0    0    0    0    l    d    +    -    -)
   (sh     - -       0    0    0    0    f    v    -    +    -)
   (shh    - -       0    0    0    0    f    p    +    +    -)
   (s      - -       0    0    0    0    f    d    -    -    -)
   (h      - -       0    0    0    0    f    v    -    +    -)
   (r:     - -       0    0    0    0    l    p    +    -    -)
   (n:     - -       0    0    0    0    n    d    +    -    -)
   (e~     - +       s    2    1    -    0    0    0    -    -)
   (o~     - +       s    2    3    +    0    0    0    -    -)

   ;; insert the phones here, see examples in 
   ;; festival/lib/*_phones.scm

  )
)

(PhoneSet.silences '(SIL))

(define (bamu_mar_sangram::select_phoneset)
  "(bamu_mar_sangram::select_phoneset)
Set up phone set for bamu_mar."
  (Parameter.set 'PhoneSet 'bamu_mar)
  (PhoneSet.select 'bamu_mar)
)

(define (bamu_mar_sangram::reset_phoneset)
  "(bamu_mar_sangram::reset_phoneset)
Reset phone set for bamu_mar."
  t
)

(provide 'bamu_mar_sangram_phoneset)
