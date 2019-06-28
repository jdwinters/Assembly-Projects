; Macros.asm
; Mark Berrett
; 10/13/2015
;
; Macros used in Lab 9 Project
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MACROS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ShowMiliTime macro
;	text, offset of text to display
;
;	Displays text, offset specified in calling code
;	Then displays the current time in milliseconds
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ShowMiliTime macro mloops
LOCAL sString
LOCAL eString
LOCAL lString
LOCAL SHOWMILLITIME_END
LOCAL SHOWMILLITIME_DONE
.data
	sString	db "Sort starting at: ",0	; text to display starting time
	eString	db "Sort ended at:    ",0	; text to display ending time 
	lString db "Number of iterations: ",0; text to display loops

.code

	push	edx							; save edx

	cmp		mloops, 0					; is this display at the top of the sort?
	jg		SHOWMILLITIME_END			; yes, show eString
	mov		edx, OFFSET sString			; show sString
	call	WriteString					; display the string
	call	GetMseconds					; get the time
	call	WriteDec					; display the time in milliseconds
	jmp		SHOWMILLITIME_DONE			; jump around end

SHOWMILLITIME_END:
	mov		edx, OFFSET eString			; specified text (offset) into edx
	call	WriteString					; display the string
	call	GetMseconds					; get the time
	call	WriteDec					; display the time in milliseconds
	call	Crlf						; cr/lf
	mov		edx, OFFSET lString			; loops string
	call	WriteString					; display the string
	mov		eax, mloops					; # of loops
	call	WriteDec					; display #

SHOWMILLITIME_DONE:
	pop		edx							; restore edx
endm



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LoadWork macro
;	buffer, offset of source string
;	work, offset of destination string
;	location, pointer to start location in buffer
;	delimiter, stop character
;
;	Loads charactors from buffer
;		to work, 
;		staring at location, 
;		until delimiter is found
;		null terminates work
;	Returns length of work in eax
;		no emplty strings, eax will be 2 is no characters are copied
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LoadWork	macro buffer, work, location, delimiter
	invoke	ParseAString,			; copy a line of text from a buffer
			buffer,					; source
			OFFSET work,			; target
			delimiter,				; delimiter character
			location				; starting address in source

	invoke	Str_length,				; get length of line of text
			ADDR work
	add		buf_location, eax		; add length of work string to current buffer location
endm






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ShowProgress macro
;	buffer, string to display
;
;	Display test "Size: "
;	Then the length of the buffer
;	Then text " Text: "
;	Then the text of the buffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ShowProggress macro buffer
	LOCAL	string1
	LOCAL	string2
.data
	string1	db "Size: ",0			; display string
	string2	db " Text: ",0			; display string
.code
	pushAD							; save registers
	mov		edx, OFFSET string1		; display string1
	call	WriteString

	invoke	Str_length,				; get length of buffer
			ADDR buffer
	call	WriteInt				; display length of buffer

	mov		edx, OFFSET string2		; display string2
	call	WriteString

	mov		edx, OFFSET buffer		; display buffer
	call	WriteString
	call	Crlf
	popad							; restore registers
endm
