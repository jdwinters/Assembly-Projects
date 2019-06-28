// assemble.cpp
// 
// inline assembly for Lab 12
//                     CIS020
//                     Fall, 2015
//
// Student Name: 
//
//

#include "stdafx.h"
//#include "assemble.h"

DWORD DoAssembly(DWORD dwDiameter)
{
	// declare your variables here, using C++ conventions
	DWORD ReturnValue;						// value returned to dialong box callback
	int FOUR = 4;
	int FIFTY = 50;

	__asm {
		pushad

			finit
			fild		dwDiameter				; load diameter into ST(0)
			fimul		dwDiameter				; ST(0) = ST(0) * dwDiameter
			fidiv		FOUR					; ST(0) = ST(0) / 4
			fldpi								; load pi onto the register stack, ST(0) = pi, ST(1) = #
			fmul		ST(0), ST(1)			; ST(0) = some number * pi
			fidiv		FIFTY					; ST(0) = ST(0) / 50
			fisttp		ReturnValue				; ReturnValue = ST(0), store ST(0) into ReturnValue

		popad	
	}
	
	return ReturnValue;
}



