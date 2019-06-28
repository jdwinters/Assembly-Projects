; IO_Procs.asm
; Mark Berrett
; 10/8/2015
;
; Invokable I/O procedures for Assemlby Project
;

INCLUDE Irvine32.inc


.data
	fileHandle	dd ?	; file handle
	fileIOokay	dd	0	; set if file io went okay, 0 if problem

.code

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
;	string1, source string, null terminated
;	string2, destination string, null terminated
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
; Str_sub
;	source, source string
;	dest, destination string
;	startPos, start postion (offset)
;	subLen, number of characters to copy
;
;	Copies characters from source to dest
;		copy starts are location startPos
;		and copies subLen number of characters
;	Inserts null (0) at end of dest
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Str_sub			proc,					; return a substring of a string
				source:PTR BYTE,		; source string
				dest:PTR BYTE,			; destination string
				startPos:DWORD,			; start at this character
				subLen:DWORD			; get this many characters

	pushad								; store registers
	
	mov			ecx, subLen				; loop counter
	mov			ebx, startPos			; string offset

	mov			esi, source				; move address of source to esi
	add			esi, startPos			; move esi forward to start postion

	mov			edi, dest				; move address of destination to edi

LOOPTop:

	mov			al, [esi]				; get a character from the source
	mov			[edi], al				; move it to the destination

	inc			esi						; next char in source
	inc			edi						; next location in destination
	loop		LOOPTop					; goto top of loop (decrament ecx)

	mov			BYTE PTR [edi],0		; insert null terminator in destination

	popad								; restore
	ret
Str_sub			endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Str_search
;	source, source string
;	search, string to search for
;
;	Searches source string to find search string
;	Returns location of search string if found in EAX
;	Return -1 if search string not found
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Str_search		proc,					; searches for a sub string, returns location in eax
				source:PTR BYTE,		; source string
				search:PTR BYTE			; search string

.data
	returnVal	dd -1					; -1 = not found, returned in eax
	sourceLen	dd ?					; length of source string
	searchLen	dd ?					; length of search string
	lastPos		dd ?					; last pos to offset when looking for search string
	testStr		db 7Fh dup (0)			; substring of source, returned in Str_sub

.code

	pushad								; save registers

	invoke		Str_length,				; find length of the source string
				source					; source string
	mov			sourceLen, eax			; save length

	invoke		Str_length,				; find length of the search string
				search					; search string
	mov			searchLen, eax			; save length

	cmp			eax, sourceLen			; compare the lengths of the two strings
	jg			DONE					; search is larger than source, cannot be found

	mov			eax, sourceLen			; lastPos = length of source string - length of search string
	sub			eax, searchLen			; lastPos is the last offset that we will use to 
	mov			lastPos, eax			;	look for the search string

	xor			ebx, ebx				; initialize loop counter

SEARCHLOOP:

	invoke		Str_sub,				; return a substring of a string
				source,					; source string
				ADDR testStr,			; destination string
				ebx,					; start at this character
				searchLen				; get this many characters

	invoke		Str_compare,			; compare substring of source with search string
				ADDR testStr,			; substring
				search					; search string
	je			FOUND					; they match!

	inc			ebx						; next char in source
	cmp			ebx, lastPos			; are we at the end of the sourse string?
	jg			DONE					; if at end of source, we didn't find a match
	jmp			SEARCHLOOP				; goto top of loop

FOUND:
	mov			returnVal, ebx			; return where we found the match	

DONE:

	popad								; restore
	mov			eax, returnVal			; return value
	ret
Str_search		endp


END

