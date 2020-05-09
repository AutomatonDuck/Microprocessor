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
; "Allocate" memory for input and sorted arrays. Note the arrays are 16 bits
; apart in memory, giving ample room for the 10 values you need to sort plus the
; size.
ARY1		.set	0x0200					; Label address 0x0200 as ARY1
ARY1S		.set	0x0210					; Label address 0x0210 as ARY1S
ARY2		.set	0x0220					; Label address 0x0220 as ARY2
ARY2S		.set	0x0230					; Label address 0x0230 as ARY2S

; Clear all registers before using them. This is good practice.
			clr		R4
			clr		R5
			clr		R6
			clr		R7
			clr		R8
			clr		R9
			clr		R10
			clr		R11
			clr		R12
			; Clear any other registers you are using

SORT1		mov.w	#ARY1, R4				; Initialize R4 as a pointer to ARY1
			mov.w	#ARY1S, R6				; Initialize R6 as a pointer to ARY1S
			call	#ArraySetup1			; Call the ArraySetup1 subroutine
			call	#COPY					; Copy elements from ARY1 to ARY1S
			call	#SORT					; Sort elements in ARY1S

SORT2		mov.w	#ARY2, R4				; Initialize R4 as a pointer to ARY2
			mov.w	#ARY2S, R6				; Initialize R6 as a pointer to ARY2S
			call	#ArraySetup2			; Call the ArraySetup2 subroutine
            call    #COPY                   ; Copy elements from ARY2 to ARY2S
			call	#SORT					; Sort elements in ARY2S

Mainloop	jmp		Mainloop				; Halt execution (Infinite loop)

; ARY1 element initialization subroutine
ArraySetup1	mov.b	#10, 0(R4)				; Define the number of elements
			mov.b	#34, 1(R4)				; Store the first element
			mov.b	#-18, 2(R4)				; Store the second element
			mov.b	#87, 3(R4)				; Store the third element
			mov.b	#-65, 4(R4)
			mov.b	#28, 5(R4)
			mov.b	#-15, 6(R4)
			mov.b	#-49, 7(R4)
			mov.b	#61, 8(R4)
			mov.b	#-77, 9(R4)
			mov.b	#45, 10(R4)
			ret

; ARY2 element initialization subroutine
ArraySetup2	mov.b	#10, 0(R4)				; Define the number of elements
			mov.b	#90, 1(R4)				; Store the first element
			mov.b	#46, 2(R4)				; Store the second element
			mov.b	#16, 3(R4)				; Store the third element
			mov.b	#-55, 4(R4)
			mov.b	#-39, 5(R4)
			mov.b	#32, 6(R4)
			mov.b	#38, 7(R4)
			mov.b	#12, 8(R4)
			mov.b	#54, 9(R4)
			mov.b	#23, 10(R4)
			ret

; Copy original array to allocated sorted space
COPY		mov.b	0(R4), R10				; Save the number of elements in R10
			inc.b	R10						; Increment by 1 to account for n
			mov.w	R4, R5					; Copy R4 to R5 so we maintain R4
			mov.w	R6, R7					; Copy R6 to R7 so we maintain R6
LP			mov.b	@R5+, 0(R7)				; Copy elements using R5/R7 pointers
			inc.w 	R7
			dec		R10
			jnz	LP
			ret

; Sort the copy of the array saved in ARY#S space while maintaining the original
; array. Replace the following lines with your actual sorting algorithm.

SORT		mov.b 0(R4), R10 ;Number of elements stored in R6
			inc R10			;will increment R6 for use in loops
			mov R10, R8      ;move number of elements to R8, counting outer loop
			mov R8, R9		;move number of elements to R9, counting inner loop
			mov R6, R5		;move the beginning address to R5 so it doesnt change

OUTER		dec R8			;decrements the outer loop
			jz  RETURN	    ;exit condition
			mov R5, R6		;points R6 to beginning of array
			inc R6			;sets address greater than the lengths address
			mov R6, R7		;makes R7 point to sorted array
			inc R7			;R7 points to R6 +1
			mov R8, R9		;inner loop counter

INNER		dec R9			;decrement the inner loop
			jz OUTER		;will return to outer loop if inner loop is zero
			mov.b @R6, R11  ;move the value at R6 address to R11
			mov.b @R7, R12  ;move the value at R7 address to R12
			cmp R11, R12    ;will compare R11 and R12 to check if swap is needed
			jn SWAP			;if swap is needed will jump to swap
			inc R6			;if no swap is needed will increase address
			inc R7
			jmp INNER		;Jump back to inner loop

SWAP		mov.b R12, 0(R6) ;put lower value in first spot
			mov.b R11, 0(R7) ; put higher value in second spot
			inc R6			; increment to next values
			inc R7
			jmp INNER		;go back to innter loop

RETURN		ret				;returns to mainloop



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
            
