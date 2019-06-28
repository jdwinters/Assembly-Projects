; IO_Procs.asm
; Mark Berrett
; 10/8/2015
;
; Invokable I/O procedures for Assembly Project
;

INCLUDE Irvine32.inc


.data
	fileHandle	dd ?	; file handle
	fileIOokay	dd	0	; set if file io went okay, 0 if problem

.code



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INVOKED PROCEDURES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ReadAFile
;	filename, string containing path of file to open
;	buffer, space to load characters read from file
;	numchars, max number of characters to read from file (typically length of buffer)
;	chars_read, returns number of characters read from file and inserted into buffer
;
;	Opens, reads, and closes file designated by filename 
;	Inserts characters read into buffer up to numchars
;	Returns the number of characters read from file and placed in buffer in chars_read
;	Sets EAX to 1 of operation successful, 0 if error
;	Calls WriteWindowsMsg if an error occurs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ReadAFile	proc,						; read a file, success returned in EAX
			filename:PTR BYTE,			; path for filename
			buffer:PTR BYTE,			; buffer to fill
			numchars:DWORD,				; how many chars to read
			chars_read:PTR DWORD		; how many chars got read

	pushad								; push registers onto stack
	mov			fileIOokay, 1			; everything is working okay so far

	mov			edx, filename			; file name into edx
	call		OpenInputFile			; open file to read
	mov			fileHandle, eax			; save the file handle
	cmp			eax, INVALID_HANDLE_VALUE; did we get a bad handle?
	je			RAF_BAD_FILE			; yes, error message

	mov			eax, fileHandle			; file handle to eax
	mov			edx, buffer				; buffer address to edx
	mov			ecx, numchars			; chars to read in ecx
	call		ReadFromFile			; read the file
	jc			RAF_BAD_FILE			; carry bit is set, so error

	mov			eax, fileHandle			; file handle to eax
	call		CloseFile				; close the file
	cmp			eax, 1					; 1 means successful
	jne			RAF_BAD_FILE			; no? error message

	jmp			RAF_DONE				; jump around error

RAF_BAD_FILE:
	call		WriteWindowsMsg			; show Windows error message
	mov			fileIOokay, 0			; return code to error

RAF_DONE:

	invoke		Str_length,				; how long is the buffer?
				buffer					; value in eax
	mov			esi, chars_read			; store address of chars_read into esi
	mov			DWORD PTR [esi], eax	; store characters read into chars_read
	
	popad								; restore registers
	mov			eax, fileIOokay			; set return code in eax

	ret
ReadAFile	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MakeAFile
;	filename, string containing path of file to create
;	buffer, string to be written to the file
;	numchars, number of characters to write to the file (typically length of buffer)
;
;	Opens (creates), writes, and closes file designated by filename 
;	Writes characters from buffer into file
;	Sets EAX to 1 of operation successful, 0 if error
;	Calls WriteWindowsMsg if an error occurs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MakeAFile	proc,						; create and write, success returned in EAX
			filename:PTR BYTE,			; path for filename
			buffer:PTR BYTE,			; buffer to write
			numchars:DWORD				; how many chars to write

	pushad								; store registers on stack
	mov			fileIOokay, 1			; so far, everything okay

	mov			edx, fileName			; file to create
	call		CreateOutputFile		; create the file
	mov			fileHandle, eax			; save the file handle
	cmp			eax, INVALID_HANDLE_VALUE; good file open?
	je			MAF_BAD_FILE			; no, error

	mov			eax, fileHandle			; file handle to eax
	mov			edx, buffer				; buffer address to edx
	mov			ecx, numchars			; # chars to write
	call		WriteToFile				; write buffer to file
	cmp			eax, 0					; 0 means bad write
	je			MAF_BAD_FILE			; 0, error

	mov			eax, fileHandle			; file handle to eax
	call		CloseFile				; close the file
	cmp			eax, 1					; 1 means successful
	jne			MAF_BAD_FILE			; no? error message

	jmp			MAF_DONE				; jump around error

MAF_BAD_FILE:
	call		WriteWindowsMsg			; show Windows error message
	mov			fileIOokay, 0			; file io failure

MAF_DONE:

	popad								; restore registers
	mov			eax, fileIOokay			; return 1 = ok, 0 = failure

	ret
MakeAFile	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ParseAString
;	string1, source string
;	string2, destination string
;	delimiter, character to look for that will end the copy
;	start, starting location in string1
;
;	Copies characters from string1 into string2 until delimiter is found.
;	Delimiter is copied to string2, then string2 is appended with a NULL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ParseAString	proc,					; return a null terminated string from within a string
				string1:PTR BYTE,		; source string
				string2:PTR BYTE,		; destination string
				delimiter:BYTE,			; character that determines end of line in string1
				start:DWORD				; starting location of string1

	pushad								; push all registers to the stack (no operand required)
	mov			esi, string1			; use esi to reference string1
	mov			edi, string2			; use edi to reference string2
	add			esi, start				; offset pointer to string1 to start

PAS1:
	mov			al, [esi]				; grab first char in string1
	cmp			al, 0					; is this char NULL? (end of input string1)
	je			PAS2					; yes, finish
	mov			BYTE PTR [edi], al		; move current char in buffer to string2
	cmp			al, delimiter			; is this char the delimiter?
	je			PAS2					; yes, finish
	inc			esi						; next char in string1
	inc			edi						; next place in string2
	jmp			PAS1					; loop again

PAS2:
	inc			edi						; one past end of string2
	mov			al, 00h					; null terminate
	mov			BYTE PTR [edi], al		; insert into string2
	POPAD								; pop all registers from the stack

	ret
ParseAString	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Str_concat
;	Input: string1, source string, null terminated
;	Input: string2, destination string, null terminated
;
;	Appends string1 to the end of string2.
;	The first character of string1 is inserted at the null terminator of string2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Str_concat		proc,					; append string1 to string2
				string1:PTR BYTE,		; source string not modified
				string2:PTR BYTE		; destination buffer, returns modified

	pushad								; push all registers to the stack (no operand required)
	mov			esi, string1			; reference string1 using ESI
	mov			edi, string2			; reference string2 using EDI

	invoke		Str_length,				; get length of string2
				edi						;	to determine where the end is
	add			edi, eax				; moves pointer to string2 to end of string

	invoke		Str_copy,				; copy string1 to string2
				esi,					; source string
				edi						; to appended location of destination string

	POPAD								; pop all registers from the stack

	ret
Str_concat		endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Cnvrt_to_int
;	Input:	input string, 0 terminated
;	Input:	Input integer, 0 initialized 
;
;Turns characters into numbers and stores them into eax, adding using a loop
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Cnvrt_to_int	proc,				; Turn string into Integer
				string1: PTR BYTE,	; source string not modified
				Integer: DWORD		; destination variable, returns modified

	pushad						; save registers

	mov 	edx, 0	 			; initialize ebx to 0

DOSOMETHING:
	xor 	eax, eax 			; zero a "result so far"

TOP:
	mov 	ecx, string1+[edx] 	; get a character
	inc 	edx 				; ready for next one
	cmp 	ecx, 30h 			; valid?
	jb	DONE

	cmp 	ecx, 39h
	ja 	DONE

	sub 	ecx, 30h 			; "convert" character to number
	imul 	eax, 10 			; multiply "result so far" by ten
	add 	eax, ecx 			; add in current digit
	jmp 	TOP 				; until done

DONE:

	mov	Integer, eax			; put result into this integer
	popad					; restore registers

	ret
Cnvrt_to_int	endp


END

