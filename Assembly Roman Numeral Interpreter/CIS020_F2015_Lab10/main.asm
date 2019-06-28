TITLE MASM Template						(main.asm)

; Mark Berrett
;
; Description: Roman Numeral Interpreter
;  CIS020, Fall 2015, Lab 10
;
; Revision date: 10/19/2015

INCLUDE Irvine32.inc
INCLUDE IO_Procs.inc
INCLUDE roman.inc

.data
	BUFF_SIZE	equ 7Fh					; size of buffer

	intIn		DWORD ?					; input integer
	bufferOut	db BUFF_SIZE DUP(0)		; output string
	errorMsg	db "Input out of range. Enter a number between 1 and 399 or 0 to quit",0 ; INPUT_ERROR message

.code

main	PROC

	call	SetScreenDisplay			; set screen display

	call	ReadInt						; read an integer from the console (-2,147,483,648 to +2,147,483,647)
	cmp		eax, 0						; compare to 0
	je		DONE						; 0 entered, quit (also quits is nothing entered)
	cmp		eax, 0						; compare to 0
	jle		INPUT_ERROR					; must be greater than 0
	cmp		eax, 0190h					; compare to 400
	jge		INPUT_ERROR					; must not be greater than or equal to 400

	mov		intIn, eax					; move input into variable

	invoke	CalculateRoman,				; calculate roman numeral 
			eax,						; based on input integer
			ADDR bufferOut				; returning string

	mov		dh, 07h						; row 7
	mov		dl, 28h						; column 40
	call	GotoXY						; move cursure (center text)

	mov		edx,  OFFSET bufferOut		; move output buffer to dx
	call	WriteString					; write the string returned from CalculateRoman

	jmp		CONTINUE					; skip error message

INPUT_ERROR:
	mov		dh, 09h						; row 9
	mov		dl, 00h						; column 0
	call	GotoXY						; move cursure (center text)
	mov		edx, OFFSET errorMsg		; display errorMsg
	call	WriteString					;


CONTINUE:
	mov		dh, 0Bh						; row 11
	mov		dl, 00h						; column 0
	call	GotoXY						; move cursure (center text)
	call	WaitMsg						; wait
	call	main						; start over


DONE:
		exit
main	ENDP


SetScreenDisplay	proc
.data
	title1		db "ROMAN NUMERAL CONVERTER",0						; top line of console title
	title2		db "Converts Arabic numbers to Roman numerals",0	; sub title
	prompt1		db "Enter an integer (1 - 399):",0					; prompt for input
	prompt2		db "Converted to Roman numerals:",0					; output prompt
	prompt3		db "Enter 0 to end program",0						; quit prompt
.code
	pushad								; save registers

	mov		eax, black + (white SHL 4)	; set text color black over white
	call	SetTextColor				;
	call	Clrscr						; set the screen to white

	mov		dh, 02h						; row 2
	mov		dl, 1Dh						; column 29
	call	GotoXY						; move cursure (center text)
	mov		edx, OFFSET title1			; display title1
	call	WriteString					;

	mov		dh, 03h						; row 3
	mov		dl, 14h						; column 20
	call	GotoXY						; move cursure (center text)
	mov		edx, OFFSET title2			; display title2
	call	WriteString					;

	mov		dh, 05h						; row 5
	mov		dl, 0Ah						; column 10
	call	GotoXY						; move cursure (center text)
	mov		edx, OFFSET prompt1			; display prompt1
	call	WriteString					;

	mov		dh, 07h						; row 7
	mov		dl, 09h						; column 9
	call	GotoXY						; move cursure (center text)
	mov		edx, OFFSET prompt2			; display prompt2
	call	WriteString					;

	mov		dh, 09h						; row 7
	mov		dl, 1Dh						; column 29
	call	GotoXY						; move cursure (center text)
	mov		edx, OFFSET prompt3			; display prompt3
	call	WriteString					;

	mov		dh, 05h						; row 5
	mov		dl, 28h						; column
	call	GotoXY						; leave the curser at the input point

	popad								; restore

	ret
SetScreenDisplay	endp

END		main