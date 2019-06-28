; IO_Procs.inc
; Jonathan Winters
; 10/25/2015
;
; Prototypes for IO_Procs.asm
; for Assembly Project
;


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
ReadAFile	proto,					; read a file, success returned in EAX
			filename:PTR BYTE,		; path for filename
			buffer:PTR BYTE,		; buffer to fill
			numchars:DWORD,			; how many chars to read
			chars_read:PTR DWORD	; how many chars got read

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
MakeAFile	proto,					; create and write, success returned in EAX
			filename:PTR BYTE,		; path for filename
			buffer:PTR BYTE,		; buffer to write
			numchars:DWORD			; how many chars to wriet

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
ParseAString	proto,				; return a null terminated string from within a string
			string1:PTR BYTE,		; source string
			string2:PTR BYTE,		; destination string
			delimiter:BYTE,			; character that determines end of line in string1
			start:DWORD				; starting location of string1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Str_concat
;	Input: string1, source string, null terminated
;	Input: string2, destination string, null terminated
;
;	Appends string1 to the end of string2.
;	The first character of string1 is inserted at the null terminator of string2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Str_concat	proto,					; appends string1 to string2
			string1:PTR BYTE,		; source string
			string2:PTR BYTE		; destination
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Cnvrt_to_int
;	Input:	input string, 0 terminated
;	Input:	Input string, 0 terminated
;
;Turns characters into numbers and stores them into eax, adding using a loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Cnvrt_and_cmp	proto,				; Turn string into Integer
				string1:PTR BYTE,	; source string not modified
				string2:PTR BYTE	; source string not modified

