;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                                                                       ;;
;;;                Centre for Speech Technology Research                  ;;
;;;                     University of Edinburgh, UK                       ;;
;;;                         Copyright (c) 2002                            ;;
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
;;;                         Author: 
;;;                         Date:  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; British English language description
;;
;;

(define (language_british_english)
"(language_british_english)
Set up language parameters for British English."

  (let ( (mydefault_voices (language.get_voices 'british_english))
         (mymalevoices nil)
         (myfemalevoices nil)
       )
  (set! mymalevoices (cadr (assoc 'male mydefault_voices)))
  (if (> (length mymalevoices) 0)
    (set! male1 (lambda () (voice.select (nth 0 mymalevoices))))
    (set! male1 nil)
  )
  (if (> (length mymalevoices) 1)
    (set! male2 (lambda () (voice.select (nth 1 mymalevoices))))
    (set! male2 nil)
  )
  (if (> (length mymalevoices) 2)
    (set! male3 (lambda () (voice.select (nth 2 mymalevoices))))
    (set! male3 nil)
  )
  (if (> (length mymalevoices) 3)
    (set! male4 (lambda () (voice.select (nth 3 mymalevoices))))
    (set! male4 nil)
  )


  (set! myfemalevoices (cadr (assoc 'female mydefault_voices)))
  (if (> (length myfemalevoices) 0)
    (set! female1 (lambda () (voice.select (nth 0 myfemalevoices))))
    (set! female1 nil)
  )
  
  (if (null male1)
     (if (null female1)
        (format t "Not a british English voice installed")
        (female1)
     )
     (male1)
  )
  (Param.set 'Language 'britishenglish)
nil
  )
)

(proclaim_language
 'british_english
 '((language english)
   (dialect british)
   (default_male (list rab_diphone don_diphone gsw_diphone gsw_450))
   (default_female nil)
   (aliases (list britishenglish))
  ))

