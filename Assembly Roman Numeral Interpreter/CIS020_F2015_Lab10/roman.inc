; roman.inc
; Mark Berrett
; 10/19/2015
;
; Prototypes for roman.asm
; for CIS020, F2015, Lab 10
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CalculateRoman
;	intIn, integer input in main.asm, betwen 1 - 400
;	output, output string 
;
;	Converts the input integer, intIn to a Roman numeral
;	Returns the Roman numeral as a string in output
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CalculateRoman	proto,					; calculate roman numeral 
			intIn:DWORD,				; input integer
			output:PTR BYTE				; return string

