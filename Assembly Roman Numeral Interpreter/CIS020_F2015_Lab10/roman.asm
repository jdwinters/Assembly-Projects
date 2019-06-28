; roman.asm
; Mark Berrett
; 10/19/2015
;
; Prototypes for roman.asm
; for CIS020, F2015, Lab 10
;

INCLUDE Irvine32.inc
INCLUDE IO_Procs.inc

.data
	errorMsg1	db "ERROR ",0					; return message until procedure completed
	errorMsg2	db ": Value not calculated",0	; return message until procedure completed


	One			db "I",0						; Roman numeral 1
	Five		db "V",0						; Roman numeral 5
	Ten			db "X",0						; Roman numeral 10
	Fifty		db "L", 0						; Roman numeral 50
	Hundred		db "C",0						; Roman numeral 100

.code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CalculateRoman
;	intIn, integer input in main.asm, betwen 1 - 400
;	output, output string 
;
;	Converts the input integer, intIn to a Roman numeral
;	Returns the Roman numeral as a string in output
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


CalculateRoman	proc,					; calculate roman numeral 
			intIn:DWORD,				; input integer
			output:PTR BYTE				; return string
			
	pushad								; save registers

	xor		ebx, ebx					; clear register
	xor		eax, eax					; clear register
	xor		edx, edx					; clear register
	mov		ebx, 100

	mov		eax, intIn					; move intIn into eax
HUNDREDSPLACE:
	div		ebx							; divide eax by 100 [ebx]
	cmp		eax, 0						; is there no hundreds place?
	je		TENSPLACE					; then move on to the tenths place
	mov		ecx, eax					; put the number of hundreds into ecx for the loop
HUNDREDSLOOP:
	invoke	Str_concat,					; append a string to another
			ADDR Hundred,				; source 'C'
			output						; destination string
	Loop	HUNDREDSLOOP				; loop until ecx == 0
TENSPLACE:
	xor		ebx, ebx					; clear register ebx
	xor		eax, eax					; clear register eax
	mov		ebx, 10						; move 10 into ebx for division
	mov		eax, edx					; put what's in edx, the remainder, into eax
	xor		edx, edx					; clear edx, the remainder
	div		ebx							; divide eax by 10 [ebx]

	cmp		eax, 0						; is there no tenths place?
	je		ONESPLACE					; then move on to the ones place
	cmp		eax, 5						; is it 50 or greater?
	jge		ABOVEFIFTY					; then go put an L and then some Xs
	jmp		BELOWFIFTY
ABOVEFIFTY:
	cmp		eax, 9						; is it 90?
	je		SPECIALNINETY				; then go put XC
	mov		ecx, eax					; move eax into ecx
	sub		ecx, 5						; subtract 5 from ecx setting the loop counter
	invoke	Str_concat,					; append a string to another
			ADDR Fifty,					; source 'L'
			output						; destination string
	cmp		ecx, 0						; is there no ones to put?
	je		ONESPLACE					; then we're done here, go to onesplace
TENSLOOPONE:
	invoke	Str_concat,					; append a string to another
			ADDR TEN,					; source 'X'
			output						; destination string
	Loop	TENSLOOPONE					; loop until ecx == 0
	jmp		ONESPLACE					; done, go to onesplace 
SPECIALNINETY:
	invoke	Str_concat,					; append a string to another
			ADDR Ten,					; source 'X'
			output						; destination string
	invoke	Str_concat,					; append a string to another
			ADDR Hundred,				; source 'X'
			output						; destination string
	jmp		ONESPLACE					; go to ones place
BELOWFIFTY:
	cmp		eax, 4						; is it 40?
	je		SPECIALFORTY				; then go put XL
	mov		ecx, eax					; move eax into ecx
TENSLOOPTWO:
	invoke	Str_concat,					; append a string to another
			ADDR TEN,					; source 'X'
			output						; destination string
	Loop	TENSLOOPTWO					; loop until ecx == 0
	jmp		ONESPLACE					; done, go to onesplace
SPECIALFORTY:
	invoke	Str_concat,					; append a string to another
			ADDR Ten,					; source 'X'
			output						; destination string
	invoke	Str_concat,					; append a string to another
			ADDR Fifty,					; source 'L'
			output						; destination string
ONESPLACE:
	xor		ebx, ebx					; clear ebx
	xor		eax, eax					; clear eax
	mov		eax, edx					; put what's in edx, the remainder, into eax
	xor		edx, edx					; clear remainder

	cmp		eax, 0						; is there no ones place?
	je		DONEWITHIT					; then we're done
	cmp		eax, 5						; is it 5 or greater?
	jge		ABOVEFIVE					; then go put an V and then some Is
	jmp		BELOWFIVE					; otherwise go put some Is

ABOVEFIVE:
	cmp		eax, 9						; is it 9?
	je		SPECIALNINE					; then go put XC
	mov		ecx, eax					; move eax into ecx
	sub		ecx, 5						; subtract 5 from ecx setting the loop counter
	invoke	Str_concat,					; append a string to another
			ADDR Five,					; source 'L'
			output						; destination string
	cmp		ecx, 0
	je		DONEWITHIT
ONESLOOP_ONE:
	invoke	Str_concat,					; append a string to another
			ADDR One,					; source 'X'
			output						; destination string
	Loop	ONESLOOP_ONE				; loop until ecx == 0
	jmp		DONEWITHIT					; done, go to onesplace 
SPECIALNINE:
	invoke	Str_concat,					; append a string to another
			ADDR One,					; source 'I'
			output						; destination string
	invoke	Str_concat,					; append a string to another
			ADDR Ten,					; source 'X'
			output						; destination string
	jmp		DONEWITHIT					; go to ones place
BELOWFIVE:
	cmp		eax, 4						; is it 4?
	je		SPECIALFOUR					; then go put IV
	mov		ecx, eax					; move eax into ecx
ONESLOOP_TWO:
	invoke	Str_concat,					; append a string to another
			ADDR One,					; source 'I'
			output						; destination string
	Loop	ONESLOOP_TWO				; loop until ecx == 0
	jmp		DONEWITHIT					; done, go to onesplace
SPECIALFOUR:
	invoke	Str_concat,					; append a string to another
			ADDR One,					; source 'X'
			output						; destination string
	invoke	Str_concat,					; append a string to another
			ADDR Five,					; source 'L'
			output						; destination string

DONEWITHIT:
	popad								; restore


	ret
CalculateRoman	endp



END