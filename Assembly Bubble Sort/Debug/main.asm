;TITLE MASM Template						(main.asm)

; Mark Berrett
;
; Description: Sample buble sort code
; 
; Revision date: 10/11/2015

INCLUDE Irvine32.inc	; include library
INCLUDE IO_Procs.inc	; procs library
INCLUDE Macros.inc		; macros for this project

.data

; CONSTANTS
	max_buf			equ 400h								; size of buffers
	prompt			db "Sorting 100 random numbers from the file " 
; starting message, not null terminated on purpose, so that next string will be written as well
	FileNameIn		db "E:\100_random_numbers.txt", 0		; name of input file to open (with full path)
	FileNameOut		db "E:\sorted.txt",0					; name of ouput file

; VARIABLES
	buffer1			db max_buf DUP (0)			; input buffer 1
	buffer2			db max_buf DUP (0)			; input buffer 2
	work1			db 0Ah DUP (0)				; line of text from buffer, 1
	work2			db 0Ah DUP (0)				; line of text from buffer, 2
	buffer_blnk	db	max_buf DUP (0)				; for blanking buffers
	char_read		dd ?						; # of chars read into buffer
	buf_location	dd ?						; current location in buffer (while parsing)
	dirty_bit		BYTE 0						; 1 if a swap (sort) occured, so need to run through buffer again
	loops			dd ?						; # of times the buffer was looped (how many sort iterations) used for display only
	INT1			dd 0						; 1st #
	INT2			dd 0						; 2nd # 	 
.code

main PROC

; display message
	mov		edx, OFFSET prompt
	call	WriteString
	call	Crlf
	call	Crlf

; show starting time
	ShowMiliTime loops				; show start time in console
	call	Crlf

; open the input file
	invoke	ReadAFile,				; read file into buffer
			OFFSET FileNameIn,		; path of file to read
			OFFSET buffer1,			; input buffer
			SIZEOF buffer1,			; # chars to read
			OFFSET char_read		; # chars that were read
	cmp		eax, 1					; eax = 1 if read successful
	jne		ALL_DONE				; not successful, do not continue


; start at top of buffer
	mov		esi, OFFSET buffer1		; initialize esi to sourse buffer
	mov		edi, OFFSET buffer2		; initialize edi to destination buffer
	mov		loops, 0				; how many loops (iterations through the buffer)

TOP_OF_BUFFER:
	mov		dirty_bit, 0			; no sorting has occured
	mov		buf_location, 0			; start at top of buffer

; fill work1
	LoadWork esi, work1, buf_location, 0Ah	; load work1 from esi at buf_location, buf_location advances
	cmp		eax, 2					; return code is length of string moved into work1
	jl		END_OF_BUFFER			; if empty string, then at end of buffer

;	ShowProggress work1				; macro that displays work1

GET_NEXT:
; fill work2
	LoadWork esi, work2, buf_location, 0Ah	; load work1 from esi at buf_location, buf_location advances
	cmp		eax, 2					; return code is length of string moved into work2
	jl		END_OF_BUFFER			; if empty string, then at end of buffer

;	ShowProggress work2				; macro that displays work2

	invoke	Cnvrt_to_int,			; Convert the work1 str into an int
			ADDR work1,				;
			INT1					;
	invoke	Cnvrt_to_int,			; Convert the work2 str into an int
			ADDR work2,				;
			INT2					;
;	push	eax
	mov		eax, INT2
	cmp		INT1, eax
;	pop		eax
	jb		WORK1_SMALLER			; if carry flag set, then 1st string is smaller

; work2 is smaller than work1

	invoke	Str_concat,				; append work2 string to buffer2
			ADDR work2,				; source
			edi						; destination

	mov		dirty_bit, 1			; a sort has occured, so will need to do big loop again

	jmp		GET_NEXT				; fill work2 with next line, leave work1 alone, it was bigger

WORK1_SMALLER:
; work1 is smaller than work2

	invoke	Str_concat,				; append work1 to buffer2
			ADDR work1,				; source
			edi						; destination

	invoke	Str_copy,				; move work2 into work1 for next comparison
			ADDR work2,				; source
			ADDR work1				; destination

	jmp		GET_NEXT				; fill work2 with next line

END_OF_BUFFER:

; if work1 was not appended to buffer2, do it here
	invoke	Str_concat,				; append work1 string to buffer2
			ADDR work1,				; source
			edi						; destination

	cmp		dirty_bit, 0			; if no sort happened this time, then there's no need to loop again
	je		WRITE_BUFFER			; jump out of loop

; perform end of loop functions, swap buffers so that the input is now the output, null the output, +1 loop counter
	xchg	esi, edi				; swap buffers, partially sorted buffer is now input buffer

	invoke	Str_copy,				; move nulls to the output buffer
			ADDR buffer_blnk,
			edi

	inc		loops					; add 1 to loop counter

	jmp		TOP_OF_BUFFER			; start the crawl through the buffer again

WRITE_BUFFER:
; write buffer2 to output file
	invoke	MakeAFile,				; create and write file
			OFFSET FileNameOut,		; output file name
			edi,					; points to buffer2
			char_read				; number of chars to write (shoudl be the same as chars read from the input file)

; show ending time
	ShowMiliTime loops				; show end time in console
	call	Crlf

ALL_DONE:

	call	WaitMsg					; pause before closing console
	ret

	exit
main ENDP


END main

