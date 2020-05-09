;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
LAB3	mov.w	#5, R4	; Set up the initial a value in R4
		clr.w	R5		; Clear all used registers
		clr.w	R6
		clr.w	R7
		clr.w	R8
		clr 	R9

XCALC	mov.w	R4, R5		; Copy the a value into R5

		call	#ABSOL		; Compute the absolute value of a in R5
							; The X calculation part of your program
							; 	taking the value of R4 as an input
							; 	and returning result X in R5

SUM		mov.w 	R5, R6		; Start sum with limit in R6
		mov		R5, R9		; using R9 as a counter for the factorial summation
		call 	#FACTO		; Get the factorial value of R6 and save in R6
		rla	R6				; Finish XCALC by doubling the value and adding it to accumulator R8
		add	R6, R8			; R8 will be where the factorials are added
		dec R9				; R9 is the counter for index of the summation
		mov R9, R5			; this is to insure the correct factorial is used in FACTO
		cmp #-1, R9			; since index starts at 0, R9 is checked at the next lowest number
		jne SUM
		mov		R8, R5		; Save the XCALC results in R5

FCALC	mov.w 	R5, R7		; Start F calculation
		rla R7				; the equation is 2*X
		add #55, R7			; Finish Fcalc by adding the constant 55 and dividing by 4
		rra R7				;(hint shift twice to the right with carry=0)
		rra R7				;divion or mulitiplcation of two in binary is just shifting digits
HALT	jmp 	HALT		;loop in place


; Absolute subroutine takes a value from R5 and converts it to its absolute value
ABSOL:
			tst 	R5
			jn		twoscompl
			ret
twoscompl	inv 	R5
			inc		R5
ABSOLend	ret


; Factorial subroutine takes number n from R6 and compute/save n! in R6
; You need to replace the NOP with your actual n! calculation as given in class
; You must push/pop all registers
FACTO:
			tst R5
			jz ZERO
			jn NEG
LOOP		dec R5
			jz FACTOend
			call #MULT
			jmp LOOP
FACTOend	ret

ZERO	mov #1, R6
		jmp FACTOend
NEG		mov #0, R6
		jmp FACTOend

; The multiplier subroutine based on shift and add
; It takes R5 as the multiplier and R6 as the multiplicand
; To avoid multiplication overflow, both R5 and R6 should be limited
; 	to one byte and thus ANDed with 0X00FF
; But due to factorial calculation, we will not mask R6 to let it grow beyond 255
MULT:
			push.w	R5
			push.w	R7
			push.w 	R8
			mov.w	#8, R8		; 8 bit multiplication, so we loop 8 times
			clr.w	R7			; Additive accumulator should start with zero
			and.w	#0x00FF, R5	; Clear upper 8 bits of multiplier
			;and.w 	#0x00FF, R6	; Clear upper 8 bits of multiplicand

nextbit		rrc.w	R5			; Shift multiplier bits one at a time to the carry
			jnc		twice		; If no carry skip the add
addmore		add.w	R6, R7		; Add a copy of the multiplicand to the accumulator
twice		add.w	R6, R6		; Multiplicand times 2, (shifted 1 bit left)
			dec.w 	R8			; Decrement loop counter
			jnz		nextbit		; Jump to check next bit of the multiplier
			mov.w 	R7, R6		; Save the result in R6

			pop.w	R8
			pop.w	R7
			pop.w 	R5

MULTend		ret

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
