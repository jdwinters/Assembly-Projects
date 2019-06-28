// assemble.cpp
// 
// inline assembly for Lab 11
//                     CIS020
//                     Fall, 2015
//
// Student Name: 
//
//

#include "stdafx.h"
//#include "assemble.h"

DWORD DoAssembly(DWORD dwInputX, DWORD dwInputY)
{
	// declare your variables here, using C++ conventions
	DWORD ReturnValue;								// value returned to dialong box callback

	__asm {
		pushad

			mov		eax, dwInputX			; replace this code, how about nah
			mul		dwInputY				; multiply the sides, x value stored in eax. [dwInputX * dwInputY = eax]
			mov		ReturnValue, eax		;


		popad	
	}
	
	return ReturnValue;
}



