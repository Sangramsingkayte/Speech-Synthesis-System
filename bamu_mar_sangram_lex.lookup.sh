

;These are the lists which contain phone list, vowels, long vowels, max phone length & anuswara etc.
(set! phHash '(aa ai au a bh b~ b chh ch~ ch d:h d:~ dh d: d~ d ei e gh g~ g h ii i jh j~ j kh k~ k lx~ lx l: l m ng~ nj~ nd~ n: n oo o ph p~ p rx~ rx r: r shh sh s t:h t:~ th t: t~ t uu u v y : qs~ tra t:ra h: o~ e~))
(set! vls '(a aa i ii u uu rx rx~ lx lx~ e ei ai o oo au e~))
(set! long-vls '(aa ii uu rx~ lx~ ei ai oo au))
(set! MaxLength 4)

;This function returns the phone sequence for the ginkn word.
(define phonify
	(lambda (word)
		(let ((wLength (string-length word)) (k 0) (phones '()))
		(while (< k wLength)
			(let ((j MaxLength) (Flag 1))
			(while (equal? Flag 1)
				(set! mem (member_string (substring word k j) phHash))
				(if (not (equal? mem 'nil))
					(begin
						(set! phones (append phones (list (car mem)) ))
						(set! k (+ k j))
						(set! Flag 0)))
				(set! j (- j 1)))))
		(define out phones))))

; This function returns the Phone type i.e VOW or CON
(define getPhoneType
        (lambda (ph)
                (set! mem  (member_string ph vls))
                (if(equal?  mem 'nil)
                        (set! retFlag '(CON))
                        (set! retFlag '(VOW)))))

; This returns the syllables when the word's phone sequence when start & ending of the syllable are ginkn
(define getSyllable
	(lambda (phones i j)
		(let ((l (+ j 1)) ( syll '()))
		(while (< i l)
			(set! syll (append syll (list(car (nth_cdr i phones)))))
			(set! i (+ i 1)))
		(define out syll))))

;This will assign the Stress Marks for the syllables
(define getSyllStress
	(lambda (ph)
		(if(equal? (isLongVowel ph) 1)
			(set! stressFlag 1)
			(set! stressFlag 0))
		(define out stressFlag)))

;This function returns 1 if the input phone is long vowel, else returns 0 .
(define isLongVowel
	(lambda (ph)
	(set! mem  (member_string ph long-vls))
		(if(equal?  mem 'nil)
			(set! retFlag 0)
			(set! retFlag 1))))

; This is the Syllabificationfunction which returns the syllables with stress marks if the phone sequence is ginkn
(define syllibify
	(lambda (phones)
		(let ((k 0) (phTypes '()) (syllStruct '()) (prev 0) (flagK 0) (syllno 0) (noOfPhones (length phones)) )

		; getting the phone types
		(while (< k noOfPhones)
			(set! phTypes (append phTypes (getPhoneType (car (nth_cdr k phones)))))
			(set! k (+ k 1)))
		(set! k 0)

		; Syllibifing
		(while (< k noOfPhones)
			(set! current (car (nth_cdr k phTypes)))
			(set! next (car (nth_cdr (+ k 1) phTypes)))
			(set! nextNext (car (nth_cdr (+ k 2) phTypes)))

			; Syllibifaction Rules
			(if (equal? (car (nth_cdr k phTypes)) 'VOW) ;if kth phone is VOW 
				(cond
					((and (equal? next 'CON) (equal? nextNext 'CON)) ;if (k+1)th & (k+2)th phones are CON
						(set! flagK 1)
						(if (equal? k (- noOfPhones 3)) ;if k = noOfPhones - 3
							(set! k (+ k 2))
							(set! k (+ k 1))))
					((and (equal? next 'CON) (equal? nextNext 'VOW)) ;if (k+1)th is CON & (k+2)th is VOW
						(set! flagK 1))
					((equal? next 'CON) ;if (k+1)th is CON
						(set! flagK 1)
						(set! k (+ k 1)))
					((set! flagK 1)))) ;else

			; Putting the stress marks
			(if (equal? flagK 1)
			(begin
				(if (not (equal? syllno 0))
					(set! stressFlag (getSyllStress (car (nth_cdr (+ prev 1) phones))))
					(set! stressFlag 1))
				(set! syllStruct (append syllStruct (list (list (getSyllable phones prev k) stressFlag))))
				(set! prev (+ k 1))
				(set! syllno (length syllStruct))
				(set! flagK 0)))
			(set! k (+ k 1)))
		(set! out syllStruct))))

; This is the main function which calls the phonify & syllibify for the word input
(define bamu_lex.lookup
	(lambda (word)
		(let ((syllStruct '()))
		(set! phones (phonify word))
		(set! syll (syllibify phones))
		(set! syllStruct ( append (append (append syllStruct (list word)) '(nil)) syll)))))
