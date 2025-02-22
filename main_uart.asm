
		.DEF VALUE = R24
		.ORG 0
		RJMP MAIN
		.ORG 0X40
MAIN:
		LDI R16,HIGH(RAMEND)
		OUT SPH,R16
		LDI R16,LOW(RAMEND)
		OUT SPL,R16

		LDI R16,0XFF
		OUT DDRA,R16
		CBI PORTA,7		;don't allow 573_COL
		CBI PORTA,6		;don't allow 573_ROW
		
START:
		RCALL SETUP_MATRIX
	
		LDI	R16,(1<<RXEN0)
		STS UCSR0B,R16
		LDI R16,(1<<UCSZ01)|(1<<UCSZ00)
		STS UCSR0C,R16
		LDI R16,0
		STS UBRR0H,R16
		LDI R16,51
		STS UBRR0L,R16
WAIT:	LDS R17,UCSR0A
		SBRS R17,RXC0
		RJMP WAIT
		LDS VALUE,UDR0
		RCALL DELAY_500MS
		CPI VALUE,'Z'
		BREQ OPTION_KEY_Z
		CPI VALUE,'C'
		BREQ OPTION_KEY_C
		CPI VALUE,'A'
		BREQ OPTION_KEY_A
		CPI VALUE,'S'
		BREQ OPTION_KEY_S
		CPI VALUE,'D'
		BREQ OPTION_KEY_D
		CPI VALUE,'Q'
		BREQ OPTION_KEY_Q
		CPI VALUE,'W'
		BREQ OPTION_KEY_W
		CPI VALUE,'E'
		BREQ OPTION_KEY_E	
;--------------------------------
OPTION_KEY_Z:
		RCALL KEY_Z
		RJMP WAIT
;--------------------------------
OPTION_KEY_C:
		RCALL KEY_C
		RJMP WAIT
;--------------------------------
OPTION_KEY_A:
		RCALL KEY_A
		RJMP WAIT
;--------------------------------
OPTION_KEY_S:
		RCALL KEY_S
		RJMP WAIT
;--------------------------------
OPTION_KEY_D:
		INC R13
		RCALL KEY_D
		RJMP WAIT
;--------------------------------
OPTION_KEY_Q:
		RCALL KEY_Q
		RJMP WAIT
;--------------------------------
OPTION_KEY_W:
		INC R12
		RCALL KEY_W
		RJMP WAIT
;--------------------------------
OPTION_KEY_E:
		RCALL KEY_E
		RJMP WAIT
;=======================================================================================================
;SUBROUTINE FOR EXECUTING THE 'W' KEY FUNCTION
;=======================================================================================================
;Each time the 'W' key is pressed, this subroutine calculates the y-position to check whether the 
;illuminated point exceeds the new LED matrix boundary in the vertical direction 
;(from bottom to top, A to C or B to D) or if it goes beyond the 16x16 LED matrix 
;(out of bounds of Matrix C or D).
;If not, it only executes the subroutine KEY_W_LESS_7 to move within a single LED matrix.
;If it does exceed the boundary, it must execute the subroutine KEY_W_MORE_7 to jump 
;to a new LED matrix and then transfer the illuminated point to this new matrix.
;=======================================================================================================
KEY_W:	
		PUSH R16				
		INC R10					;Increase y-position counter
		MOV R16, R10					
		CPI R16, 8				;Check if it has exceeded the size of one LED matrix
		BRCC OVER_KEY_W			;If yes, jump to OVER_KEY_W
		RCALL KEY_W_LESS_7		;If not, execute the subroutine KEY_W_LESS_7
		RJMP EXIT_W			 

OVER_KEY_W:
		RCALL KEY_W_MORE_7		;Execute the subroutine KEY_W_MORE_7
		MOV R16, R0				;Check if the illuminated point has gone beyond the 16x16 LED matrix
		//MOV R2, R0
		CPI R16, 2
		BRCC OVER_C_D_COL		;If yes, jump to OVER_C_D_COL
		RCALL KEY_W_LESS_7		;If not, execute the subroutine KEY_W_LESS_7 to complete the transition to a new LED matrix
		RJMP EXIT_W				

OVER_C_D_COL:					;Reset the matrix, then set the illuminated point at x-position
		PUSH R13				;x-position is determined just before the point exceeds the 16x16 matrix boundary
		RCALL SETUP_MATRIX
		POP R16	
		CPI R16, 0				;Check if x = 0?
		BREQ EXIT_W				;If x = 0, skip SET_OVER_COL
SET_OVER_COL:					;If x >= 1, execute SET_OVER_COL
		INC R13
		RCALL KEY_D
		DEC R16
		BRNE SET_OVER_COL

EXIT_W:							
		POP R16
		RET						;Return to OPTION_KEY_W
;=======================================================================================================
;SUBROUTINE FOR MOVING THE ILLUMINATED POINT UPWARDS (Y-AXIS) WITHIN A SINGLE LED MATRIX
;=======================================================================================================
;First, check whether the illuminated point is in matrix A,C (R1=0) or B,D (R1=1) 
;to accurately control the hardware shift register.
;=======================================================================================================
KEY_W_LESS_7:
		PUSH R16
		MOV R16, R1
		CPI R16, 1				;Check if it is in LED matrix A,C or B,D
		BRCC MATRIX_B_D_Y		;If in Matrix B or D, jump to MATRIX_B_D_Y
		SBI PORTA, 7			;If in Matrix A or C, use shift register 595 to control GND pin of Matrix A,C
		SBI	PORTA, 1			;Send high-level signal (=1) to parallel outputs
		CBI PORTA, 0			;To move the illuminated point upwards, each time W is pressed
		SBI PORTA, 0			;Shift one unit up
		CBI PORTA, 2		
		SBI PORTA, 2
		CBI PORTA, 0							
		CBI PORTA, 7		
		RJMP EXIT_KEY_W_LESS_7

MATRIX_B_D_Y:					;For Matrix B or D
		SBI PORTA, 7			;For Matrix B or D, use shift register 595 to control GND pin of Matrix B,D
		SBI	PORTA, 4			;Send high-level signal (=1) to parallel outputs
		CBI PORTA, 3			;To move the illuminated point upwards, each time W is pressed
		SBI PORTA, 3			;Shift one unit up
		CBI PORTA, 5		
		SBI PORTA, 5
		CBI PORTA, 3							
		CBI PORTA, 7		

EXIT_KEY_W_LESS_7:				;Exit the subroutine KEY_W_LESS_7
		POP R16
		RET
;=======================================================================================================
;SUBROUTINE FOR MOVING THE ILLUMINATED POINT UPWARDS (Y-AXIS) WHEN CROSSING MATRIX BOUNDARIES
;=======================================================================================================
;First, check whether the illuminated point is in matrix A (R1=0) or B (R1=1) 
;to accurately control the hardware shift register.
;After identification, move the illuminated point to the next LED matrix 
;at coordinate Point(R13,8) with R0=1.
;=======================================================================================================
KEY_W_MORE_7:
		CLR R10					;Clear the y-position counter within an 8x8 LED matrix
		MOV R16, R1
		CPI R16, 1				;Check if it is in LED matrix A or B
		BRCC MATRIX_B_TO_D		;If in matrix B, jump to MATRIX_B_TO_D

		;If in Matrix A, when exceeding R10=7, jump to Matrix C
		;New position of illuminated point is Point(R13,8)
		SBI PORTA, 6			;Initialize active high signal at C_P0
		SBI PORTA, 4				
		CBI PORTA, 3		
		SBI PORTA, 3		
		CBI PORTA, 5		
		SBI PORTA, 5
		MOV R6, R11				;Determine x-position before transitioning to Matrix C
		INC R6
		DEC R6					
		BREQ EXIT_KEY_W_MORE_7
		CBI PORTA, 4			;Then set active low to the x-position

SET_Y_W:
		CBI PORTA, 3		
		SBI PORTA, 3	
		DEC R6
		BRNE SET_Y_W	
		CBI PORTA, 5		
		SBI PORTA, 5
		RJMP EXIT_KEY_W_MORE_7
		
		;If in Matrix B, when exceeding R10=7, jump to Matrix D
		;New position of illuminated point is Point(R13,8)
MATRIX_B_TO_D:
		SBI PORTA, 6			;Set high level (=1) A_
		SBI PORTA, 4		
		CBI PORTA, 3				
		SBI PORTA, 3	
		CBI PORTA, 5		
		SBI PORTA, 5	
		LDI R16, 8				;Send 8 low pulses (=0) to parallel outputs to make D_P0=1
		CBI PORTA, 4

SET_Y_8_W_MATRIX_D:
		CBI PORTA, 3		
		SBI PORTA, 3
		DEC R16
		BRNE SET_Y_8_W_MATRIX_D	
		CBI PORTA, 5		
		SBI PORTA, 5
		MOV R6, R11				;Check x-position in Matrix B
		INC R6
		DEC R6
		BREQ EXIT_KEY_W_MORE_7	;If x=0, jump to end of subroutine
		CBI PORTA, 4			;If x>=1, set x-position

SET_X_W_MATRIX_D:
		CBI PORTA, 3		
		SBI PORTA, 3	
		DEC R6
		BRNE SET_X_W_MATRIX_D	
		CBI PORTA, 5		
		SBI PORTA, 5	

EXIT_KEY_W_MORE_7:				;Exit subroutine
		CBI PORTA, 3
		CBI PORTA, 6			
		INC R0					;Increase the coordinate counter of the LED matrix	
		RET
;=======================================================================================================
;CONDITIONS FOR EXECUTING THE D KEY
;=======================================================================================================
;Each time the D key is pressed, the routine calculates the x position to check whether the illuminated
;point has crossed into a new LED matrix horizontally from left to right (A to B or C to D) or has exited
;the 16x16 LED matrix (beyond Matrix B or D).
;If not, it only executes the routine KEY_D_LESS_7 to move within a single LED matrix.
;If it has crossed over, it must execute the routine KEY_D_MORE_7 to jump to the new LED matrix and then
;move the illuminated point to this new matrix.
;=======================================================================================================

KEY_D:	
		PUSH R16
		INC R11					;Increase the x position counter
		MOV R16, R11				
		CPI R16, 8				;Check if it has exceeded the size of one LED matrix
		BRCC OVER_KEY_D			;If yes, jump to OVER_KEY_D
		RCALL KEY_D_LESS_7		;If no, execute the routine KEY_D_LESS_7
		RJMP EXIT_D					
OVER_KEY_D:
		RCALL KEY_D_MORE_7		;Execute the routine KEY_D_MORE_7
		MOV R16, R1				;Check if the illuminated point has exited the 16x16 LED matrix
		CPI R16, 2
		BRCC OVER_B_D_ROW		;If yes, jump to OVER_B_D_ROW
		RCALL KEY_D_LESS_7		;If no, execute KEY_D_LESS_7 to complete the transition to the new LED matrix
		RJMP EXIT_D
OVER_B_D_ROW:					;Reset the matrix, then set the illuminated point at position y
		PUSH R12				;Position y is determined before the point exits the 16x16 LED matrix
		RCALL SETUP_MATRIX
		POP R16
		CPI R16, 0				;Check if y = 0?
		BREQ EXIT_D				;If y = 0, skip SET_OVER_ROW
SET_OVER_ROW:					;If y >= 1, execute SET_OVER_ROW
		INC R12
		RCALL KEY_W
		DEC R16
		BRNE SET_OVER_ROW
EXIT_D:
		POP R16
		RET						;Return to OPTION_KEY_D

;=======================================================================================================
;MOVING THE ILLUMINATED POINT FROM LEFT TO RIGHT (X) WITHIN A SINGLE MATRIX LED
;=======================================================================================================
;First, check whether the illuminated point is in Matrix A,B (R0=0) or C,D (R0=1) to properly control
;the shift register hardware.
;=======================================================================================================

KEY_D_LESS_7:
		PUSH R16		
		MOV R16, R0			
		CPI R16, 1				;Check whether it is in Matrix A,B or C,D
		BRCC MATRIX_C_D_X		;If in Matrix C or D
		SBI PORTA,6				;If in Matrix A or B, use shift register 595 to control Matrix A,B
		CBI	PORTA,1				;Send a low signal (0) to the parallel output
		CBI PORTA,0				;To shift the illuminated point to the right, each press moves it
		SBI PORTA,0				;by one unit		
		CBI PORTA,2		
		SBI PORTA,2	
		CBI PORTA,0
		CBI PORTA,6			
		RJMP EXIT_KEY_D_LESS_7	;After shifting, jump to EXIT_KEY_D_LESS_7
MATRIX_C_D_X:					;If in Matrix C or D
		SBI PORTA,6				;Use shift register 595 to control Matrix C,D
		CBI	PORTA,4				;Send a low signal (0) to the parallel output
		CBI PORTA,3				;To shift the illuminated point to the right, each press moves it
		SBI PORTA,3				;by one unit	
		CBI PORTA,5		
		SBI PORTA,5
		CBI PORTA,3	
		CBI PORTA,6		
EXIT_KEY_D_LESS_7:				;Exit KEY_D_LESS_7 routine
		POP R16
		RET

;=======================================================================================================
;MOVING THE ILLUMINATED POINT FROM LEFT TO RIGHT (X) WHEN CROSSING BEYOND A MATRIX LED
;=======================================================================================================
;First, check whether the illuminated point is in Matrix A (R0=0) or C (R0=1) to properly control
;the shift register hardware.
;Once determined, proceed to move the point to the next matrix LED with coordinates Point(8, R12).
;R1=1
;=======================================================================================================

KEY_D_MORE_7:
		CLR R11					;Clear the x position counter in an 8x8 LED matrix
		MOV R16, R0				
		CPI R16, 1				;Check if it is in Matrix A or C
		BRCC MATRIX_C_TO_D		;If in Matrix C, jump to MATRIX_C_TO_D

		;If in Matrix A, when R11=7, move to Matrix B
		;The new position of the illuminated point is Point(8, R12)
		SBI PORTA,7				
		CBI PORTA,4				;Initialize low signal at B_GND0 of Matrix B
		CBI PORTA,3		
		SBI PORTA,3		
		CBI PORTA,5		
		SBI PORTA,5
		MOV R5, R10				;Determine the y position before moving to Matrix B
		INC R5	
		DEC R5
		BREQ EXIT_KEY_D_MORE_7	;If y = 0, skip and jump to exit
		SBI PORTA,4				;Then change the low signal at B_GND0 to position B_GNDy	
UP_1:
		CBI PORTA,3		
		SBI PORTA,3	
		DEC R5
		BRNE UP_1	
		CBI PORTA,5		
		SBI PORTA,5	
		RJMP EXIT_KEY_D_MORE_7	;Jump to exit

		;If in Matrix C, when R11=7, move to Matrix D
		;The new position of the illuminated point is Point(8, R12)
MATRIX_C_TO_D:
		SBI PORTA,7				
		CBI PORTA,4				;Create a low signal at B_GND0
		CBI PORTA,3	
		SBI PORTA,3
		CBI PORTA,5		
		SBI PORTA,5	
		LDI R16, 8				;Push the low signal from B_GND0 to D_GND0
		SBI PORTA,4
LOOP_595_COL_2:
		CBI PORTA,3		
		SBI PORTA,3
		DEC R16
		BRNE LOOP_595_COL_2		
		CBI PORTA,5		
		SBI PORTA,5
		MOV R5, R10				;Determine the y position before moving to Matrix D
		INC R5
		DEC R5
		BREQ EXIT_KEY_D_MORE_7	;If y = 0, skip and jump to exit
		SBI PORTA,4				;Then change the low signal at D_GND0 to position D_GNDy
UP_2:
		CBI PORTA,3		
		SBI PORTA,3	
		DEC R5
		BRNE UP_2	
		CBI PORTA,5		
		SBI PORTA,5

EXIT_KEY_D_MORE_7:				;Exit the routine
		CBI PORTA,3	
		CBI PORTA,7			
		INC R1
		RET
;=======================================================================================================
; CONDITIONS FOR EXECUTING KEY A
;=======================================================================================================
; Each time key A is pressed, the function calculates the x position to check whether 
; the lit point exceeds the new LED matrix in the horizontal direction from right to left 
; (B to A or D to C) or goes out of the 16x16 LED Matrix (out of Matrix A, C).
; If not, it only resets the LED matrix and then sets the point (R13-1, R12).
; If it does, it needs to switch to a new LED matrix and transfer the lit point to it. 
; The new coordinates will be Point(15, R12).
;=======================================================================================================
KEY_A:
		PUSH R12				; Save the y-coordinate value to the stack
		PUSH R13				; Save the x-coordinate value to the stack
		RCALL SETUP_MATRIX		; Reset the LED Matrix
		POP R13					; Retrieve x-coordinate for processing
		DEC R13					; Decrease x by 1 (since A moves left)
		MOV R17,R13
		CPI R17,0				; Check if x goes out of bounds from right to left
		BRLT OVER_A_C_ROW		; If it does, jump to OVER_A_C_ROW to handle it
		CPI R17,1				; Otherwise, check if x=0?
		BRCS MOVE_ROW_S			; If yes, jump to MOVE_ROW_S to handle it
SET_X_A:						; Set x-coordinate after pressing A
		RCALL KEY_D
		DEC R17
		BRNE SET_X_A
MOVE_ROW_S:						
		POP R12					; Retrieve y-coordinate for processing
		MOV R17,R12
		CPI R17,1				; Check if y=0?
		BRCS EXIT_A				; If yes, jump to EXIT_A to exit
SET_Y_A:						; If not, set the y-coordinate after pressing A
		RCALL KEY_W
		DEC R17					; Note that y does not change after pressing A
		BRNE SET_Y_A
		RJMP EXIT_A

		// If x decreases and goes out of bounds from right to left,
		// the new point should be set at Point(15, y)
OVER_A_C_ROW:					
		RCALL SETUP_MATRIX			; Reset the LED Matrix
		LDI R16,15					; Set x=15
SET_X_AFTER_OVER_A_C_ROW:
		RCALL KEY_D
		INC R13
		DEC R16
		BRNE SET_X_AFTER_OVER_A_C_ROW
		POP R16						; Retrieve y-coordinate for processing		
SET_Y_AFTER_OVER_A_C_ROW:			; Set y-coordinate
		RCALL KEY_W
		INC R12
		DEC R16
		BRNE SET_Y_AFTER_OVER_A_C_ROW
EXIT_A:	RET							; Exit key A function
;=======================================================================================================
; CONDITIONS FOR EXECUTING KEY S
;=======================================================================================================
; Each time key S is pressed, the function calculates the y position to check whether 
; the lit point exceeds the new LED matrix in the vertical direction from top to bottom 
; (C to A or D to B) or goes out of the 16x16 LED Matrix (out of Matrix A, B).
; If not, it only resets the LED matrix and then sets the point (R13, R12-1).
; If it does, it needs to switch to a new LED matrix and transfer the lit point to it. 
; The new coordinates will be Point(R13, 15).
;=======================================================================================================
KEY_S:	
		PUSH R13				; Save x-coordinate to stack
		PUSH R12				; Save y-coordinate to stack
		RCALL SETUP_MATRIX		; Reset the 16x16 LED Matrix
		POP R12					; Retrieve y-coordinate from stack
		DEC R12					; Decrease y by 1 due to pressing S
		MOV R17,R12				
		CPI R17,0				; Check if y < 0
		BRLT OVER_A_B_COL		; If so, jump to OVER_A_B_COL to handle overflow
		CPI R17,1				; Otherwise, check if y < 1
		BRCS MOVE_ROW			; If y=0, jump to MOVE_ROW and skip setting y
LP_KEY_S_COL:					; If y >= 1, set y
		RCALL KEY_W					
		DEC R17					; Move row (R12-1) times
		BRNE LP_KEY_S_COL			
MOVE_ROW:						; Set x
		POP R13					; Retrieve x-coordinate
		MOV R17,R13					
		CPI R17,1				; Compare x=1?
		BRCS EXIT_S				; If x=0, exit KEY_S function
MOVE_COL:						; If x>=1, set x
		RCALL KEY_D					
		DEC R17					
		BRNE MOVE_COL			
		RJMP EXIT_S		
		// Handle overflow when pressing S, set Point(R13,15)			
OVER_A_B_COL:						
		RCALL SETUP_MATRIX		; Reset the 16x16 LED Matrix	
		LDI R16,15				; Set y=15
SET_Y_AFTER_OVER_A_B_COL:
		RCALL KEY_W
		INC R12					
		DEC R16
		BRNE SET_Y_AFTER_OVER_A_B_COL
		POP R16					; Retrieve x-coordinate
		CPI R16,0
		BREQ EXIT_S
SET_X_AFTER_OVER_A_B_COL:		; Set x=R13 (x remains unchanged)
		RCALL KEY_D				
		INC R13
		DEC R16
		BRNE SET_X_AFTER_OVER_A_B_COL 
EXIT_S:	
		OUT PORTC,R13
		RET						; Exit key S function
;=======================================================================================================
;CTC MOVE THE LIT POINT DIAGONALLY WHEN PRESSING THE (Z) KEY
;=======================================================================================================
;**Some concepts used in the program:
;-  Main reverse diagonal: the diagonal starting from (15,15) --> (0,0)
;-  Upper_Reverse_Main: the diagonal in the same direction, located above the Main reverse diagonal
;-  Lower_Reverse_Main: the diagonal in the same direction, located below the Main reverse diagonal
;**First, check whether the lit point moves out of (0,0) after pressing E. 
;If so, it falls into the case of "exceeding the Main reverse diagonal". In that case, jump to handle it.
;**If "exceeding the Main reverse diagonal" does not occur, check whether the lit point after pressing E
;exceeds the upper diagonal "Upper_Reverse_Main" or the lower diagonal "Lower_Reverse_Main".
;If it does, jump to handle these cases.
;**If none of the above cases occur, after pressing Z, it is the same as after resetting the LED matrix,
;sequentially pressing the combination of W and D keys with the appropriate quantity.
;=======================================================================================================
KEY_Z:		
		MOV R16,R12										
		CPI R16,0						;Check if y = 0? (after pressing, y- will move out of (0,0))
		BREQ OVER_0_S_Z					;If y = 0, jump to OVER_0_S_Z to check x
		RCALL KEY_S						;If y >= 1, perform normal Z press
		RCALL KEY_A
		RJMP NEVER_OVER_0_0_Z			

OVER_0_S_Z:								;Check if x = 0? (after pressing, x- will move out of (0,0))
		PUSH R13
		RCALL KEY_S
		POP R13
		MOV R16,R13
		CPI R16,0
		BREQ OVER_0_0_Z					;If x = 0, it exceeds the Main reverse diagonal, jump to OVER_0_0_Z to handle it
		RCALL KEY_A						;If x >= 1, perform normal Z press

		//Perform Z press action when not exceeding the Main reverse diagonal 
NEVER_OVER_0_0_Z:
		MOV R16,R12						
		CPI R16,15						;Check if it exceeds the Lower_Reverse_Main diagonal?
		BRNE CHECK_Z_OVER_ROW			;If not, check if it exceeds the Upper_Reverse_Main diagonal?
		
		//Case of exceeding the Lower_Reverse_Main diagonal
		//After exceeding, the coordinates of the lit point are Point(15, y)
		PUSH R13						;Push x value onto stack (*note: x has already been -1 compared to the exceeded position)
		RCALL SETUP_MATRIX				;Reset the LED matrix
		LDI R16,14
		POP R13
		SUB R16,R13						;Calculate new y position: y = 15 - (x - (-1))
SET_Y_Z:								;Set y
		RCALL KEY_W							
		INC R12
		DEC R16
		BRNE SET_Y_Z
		LDI R16,15
		CLR R13							;Clear x before setting x
SET_X_15_Z:								;Set x = 15
		RCALL KEY_D
		INC R13
		DEC R16
		BRNE SET_X_15_Z
		RJMP EXIT_OPTION_KEY_Z			;Exit Z key processing
		
		
CHECK_Z_OVER_ROW:
		MOV R16,R13
		CPI R16,15						;Check if it exceeds the Upper_Reverse_Main diagonal?
		BRNE EXIT_OPTION_KEY_Z			;If not, jump to exit
		
		//Case of exceeding the Upper_Reverse_Main diagonal
		//After exceeding, the coordinates of the lit point are Point(x, 15)
		PUSH R12						;Push y value onto stack (*note: y has already been -1 compared to the exceeded position)
		RCALL SETUP_MATRIX				;Reset the LED matrix
		LDI R16,14						
		POP R12							
		SUB R16,R12						;Calculate new x position: x = 15 - (y - (-1))
SET_X_Z:								;Set x
		RCALL KEY_D
		INC R13
		DEC R16
		BRNE SET_X_Z
		LDI R16,15
		CLR R12							;Clear y before setting y
SET_Y_15_Z:								;Set y = 15
		RCALL KEY_W
		INC R12
		DEC R16
		BRNE SET_Y_15_Z
		RJMP EXIT_OPTION_KEY_Z			;Exit Z key processing

		//Case of exceeding the Main reverse diagonal
		//Need to set Point(15,15), so just reset and perform KEY_W and KEY_D 15 times
OVER_0_0_Z:
		CLR R12
		CLR R13
		RCALL SETUP_MATRIX				;Reset the LED matrix
		LDI R16,15
SET_POINT_15_15:						;Set Point(15,15)
		RCALL KEY_D
		INC R13
		RCALL KEY_W
		INC R12
		DEC R16
		BRNE SET_POINT_15_15
EXIT_OPTION_KEY_Z:						;Exit key press
		RET
;=======================================================================================================
;CTC MOVE THE LIT POINT DIAGONALLY WHEN PRESSING THE (E) KEY
;=======================================================================================================
;**Some concepts used in the program:
;-  Main diagonal: the diagonal starting from (0,0) --> (15,15)
;-  Upper_Main: the diagonal in the same direction, located above the Main diagonal
;-  Lower_Main: the diagonal in the same direction, located below the Main diagonal
;**First, check whether the lit point moves out of (15,15) after pressing E. 
;If so, it falls into the case of "exceeding the Main diagonal". In that case, jump to handle it.
;**If "exceeding the Main diagonal" does not occur, check whether the lit point after pressing E
;exceeds the upper diagonal "Upper_Main" or the lower diagonal "Lower_Main".
;If it does, jump to handle these cases.
;**If none of the above cases occur, after pressing E, it is equivalent to pressing the combination of W and D.
;=======================================================================================================
KEY_E:
		INC R12						;Increase y
		MOV R16,R12					
		CPI R16,16					;Check if y = 16?
		BRCC OVER_W_15_E			;If yes, check x = 16?
		RCALL KEY_W					;If not, E does not exceed the Main diagonal
		INC R13
		RCALL KEY_D
		RJMP NEVER_OVER_15_15_E		;Jump to execute key press E in case it does not exceed the Main diagonal

OVER_W_15_E:						;Check if x = 16?
		RCALL KEY_W
		INC R13
		MOV R16,R13
		CPI R16,16
		BRCC OVER_15_15_E			;If x = 16, jump to OVER_15_15_E to handle exceeding the Main diagonal
		RCALL KEY_D					;If x < 16, continue as E does not exceed the Main diagonal

		//Perform key press E when E does not exceed the Main diagonal
NEVER_OVER_15_15_E:					
		MOV R16,R12
		CPI R16,0					;Check if it exceeds the Upper_Main diagonal?
		BRNE CHECK_E_OVER_ROW		;If not, check if it exceeds the Lower_Main diagonal?

		//Case of exceeding the Upper_Main diagonal
		//After exceeding, the coordinates of the lit point are Point(0,y)
		PUSH R13					;Push x value onto stack (*note: x has already been +1 compared to the exceeded position)		
		RCALL SETUP_MATRIX			;Reset the LED matrix
		LDI R16,16					
		POP R13
		SUB R16,R13					;Calculate new y position: y = 15 - (x - 1)
SET_Y_E:							;Set y
		RCALL KEY_W
		INC R12
		DEC R16
		BRNE SET_Y_E
		CLR R13						;Set x = 0
		RJMP EXIT_OPTION_KEY_E		;Jump to exit

CHECK_E_OVER_ROW:
		MOV R16,R13
		CPI R16,0					;Check if it exceeds the Lower_Main diagonal?
		BRNE EXIT_OPTION_KEY_E		;If not, jump to exit

		//Case of exceeding the Lower_Main diagonal
		//After exceeding, the coordinates of the lit point are Point(x,0)
		PUSH R12					;Push y value onto stack (*note: y has already been +1 compared to the exceeded position)
		RCALL SETUP_MATRIX			;Reset the LED matrix
		LDI R16,16
		POP R12
		SUB R16,R12					;Calculate new x position: x = 15 - (y - 1)
SET_X_E:							;Set x
		RCALL KEY_D
		INC R13
		DEC R16
		BRNE SET_X_E
		CLR R12						;Set y = 0
		RJMP EXIT_OPTION_KEY_E		;Jump to exit

		//Case of E exceeding the Main diagonal
		//Need to set Point(0,0), so just resetting the LED matrix is sufficient
OVER_15_15_E:
		RCALL SETUP_MATRIX
EXIT_OPTION_KEY_E:					;Exit key press E
		RET
;=======================================================================================================
;CTC MOVE THE LIT POINT DIAGONALLY WHEN PRESSING THE (C) KEY
;=======================================================================================================
;**Some concepts used in the program:
;-  Reverse secondary diagonal: the diagonal starting from (0,15) --> (15,0)
;-  Reverse_Upper_Secondary: the diagonal in the same direction, located above the Reverse secondary diagonal
;-  Reverse_Lower_Secondary: the diagonal in the same direction, located below the Reverse secondary diagonal
;**First, check whether the lit point moves out of (15,0) after pressing C. 
;If so, it falls into the case of "exceeding the Reverse secondary diagonal". In that case, jump to handle it.
;**If "exceeding the Reverse secondary diagonal" does not occur, check whether the lit point after pressing C
;exceeds the diagonal "Reverse_Upper_Secondary" or the diagonal "Reverse_Lower_Secondary".
;If it does, jump to handle these cases.
;**If none of the above cases occur, after pressing C, it is similar to resetting the LED matrix and then
;pressing the combination of W and D in appropriate quantities.
;=======================================================================================================
KEY_C:
		INC R13							
		MOV R16,R13	
		CPI R16,16						;Check if x=16?
		BRCC OVER_D_15_C				;If x=16, jump to OVER_D_15_C to continue checking
		RCALL KEY_D						;If x<=15, execute key C as normal
		RCALL KEY_S
		RJMP NEVER_OVER_15_0_C			

OVER_D_15_C:							;Check y
		RCALL KEY_D
		MOV R16,R12										
		CPI R16,0						;Check if y=0?
		BREQ OVER_15_0_C				;If yes, jump to handle exceeding the Reverse secondary diagonal
		RCALL KEY_S						;If y>=1, execute key C as normal

		//Execute key press C when it does not exceed the Reverse secondary diagonal
NEVER_OVER_15_0_C:
		MOV R16,R12
		CPI R16,15						;Check if it exceeds the Reverse_Lower_Secondary diagonal?
		BRNE CHECK_C_OVER_ROW			;If not, check if it exceeds the Reverse_Upper_Secondary diagonal?

		//Case of exceeding the Reverse_Lower_Secondary diagonal
		//After exceeding, the coordinates of the lit point are Point(0,y)
		PUSH R13						;Push x value onto stack (*note: x has already been +1 compared to the exceeded position)
		RCALL SETUP_MATRIX				;Reset the LED matrix
		POP R13
		MOV R16,R13
		DEC R16							;Set y=x-1
SET_Y_C:								;Execute setting y
		RCALL KEY_W
		INC R12
		DEC R16
		BRNE SET_Y_C
		CLR R13							;Set x=0
		RJMP EXIT_OPTION_KEY_C			;Jump to exit
		
CHECK_C_OVER_ROW:						
		MOV R16,R13		
		CPI R16,0						;Check if it exceeds the Reverse_Upper_Secondary diagonal?
		BRNE EXIT_OPTION_KEY_C			;If not, jump to exit

		//Case of exceeding the Reverse_Upper_Secondary diagonal
		//After exceeding, the coordinates of the lit point are Point(x,15)
		PUSH R12						;Push y value onto stack (*note: y has already been -1 compared to the exceeded position)
		RCALL SETUP_MATRIX				;Reset the LED matrix
		POP R12							
		MOV R16,R12
		INC R16							;Set x=y+1
SET_X_C:								;Execute setting x
		RCALL KEY_D						
		INC R13
		DEC R16
		BRNE SET_X_C
		LDI R16,15
		CLR R12				
SET_Y_C_15:								;Set y=15
		RCALL KEY_W
		INC R12
		DEC R16
		BRNE SET_Y_C_15
		RJMP EXIT_OPTION_KEY_C			;Jump to exit
		 
		//Case of C exceeding the Reverse secondary diagonal 
		//Need to set Point(0,15)
OVER_15_0_C:
		RCALL SETUP_MATRIX
		LDI R16,15
SET_0_15_C:
		RCALL KEY_W
		INC R12
		DEC R16
		BRNE SET_0_15_C
EXIT_OPTION_KEY_C:						;Exit key press C
		RET
;=======================================================================================================
;CTC MOVE THE LIT POINT DIAGONALLY WHEN PRESSING THE (Q) KEY
;=======================================================================================================
;**Some concepts used in the program:
;-  Reverse secondary diagonal: the diagonal starting from (0,15) --> (15,0)
;-  Reverse_Upper_Secondary: the diagonal in the same direction, located above the Reverse secondary diagonal
;-  Reverse_Lower_Secondary: the diagonal in the same direction, located below the Reverse secondary diagonal
;**First, check whether the lit point moves out of (0,15) after pressing Q. 
;If so, it falls into the case of "exceeding the Reverse secondary diagonal". In that case, jump to handle it.
;**If "exceeding the Reverse secondary diagonal" does not occur, check whether the lit point after pressing Q
;exceeds the diagonal "Reverse_Upper_Secondary" or the diagonal "Reverse_Lower_Secondary".
;If it does, jump to handle these cases.
;**If none of the above cases occur, after pressing Q, it is similar to resetting the LED matrix and then
;pressing the combination of W and A in appropriate quantities.
;=======================================================================================================
KEY_Q:
		MOV R16,R13										
		CPI R16,0					;Check if x=0?
		BREQ OVER_A_0_Q				;If x=0, jump to OVER_A_0_Q to continue checking
		RCALL KEY_A					;If x>=1, execute key Q as normal	
		INC R12
		RCALL KEY_W	
		RJMP NEVER_OVER_0_15_Q

OVER_A_0_Q:							
		RCALL KEY_A
		INC R12
		MOV R16,R12										
		CPI R16,16					;Check if y=16?
		BRCC OVER_0_15_Q			;If y=16, it falls into the case of exceeding the Reverse secondary diagonal
		RCALL KEY_W					;If y<=15, execute key Q as normal	

		//Execute key press Q when it does not exceed the Reverse secondary diagonal
NEVER_OVER_0_15_Q:
		MOV R16,R13
		CPI R16,15					;Check if it exceeds the Reverse_Lower_Secondary diagonal?
		BRNE CHECK_Q_OVER_COL		;If not, check if it exceeds the Reverse_Upper_Secondary diagonal?

		//Case of exceeding the Reverse_Lower_Secondary diagonal
		//After exceeding, the coordinates of the lit point are Point(x,0)
		PUSH R12					;Push y value onto stack (*note: y has already been +1 compared to the exceeded position)
		RCALL SETUP_MATRIX			;Reset the LED matrix
		POP R12
		MOV R16,R12
		DEC R16						;Set x=y-1
SET_X_Q:							;Execute setting x
		RCALL KEY_D
		INC R13
		DEC R16
		BRNE SET_X_Q
		CLR R12						;Set y=0
		RJMP EXIT_OPTION_KEY_Q		;Jump to exit
		
CHECK_Q_OVER_COL:						
		MOV R16,R12
		CPI R16,0					;Check if it exceeds the Reverse_Upper_Secondary diagonal?
		BRNE EXIT_OPTION_KEY_Q		;If not, jump to exit

		//Case of exceeding the Reverse_Upper_Secondary diagonal
		//After exceeding, the coordinates of the lit point are Point(15,y)
		PUSH R13					;Push x value onto stack (*note: x has already been -1 compared to the exceeded position)
		RCALL SETUP_MATRIX
		POP R13
		MOV R16,R13
		INC R16						;Set y=x+1
SET_Y_Q:							;Execute setting y
		RCALL KEY_W					
		INC R12
		DEC R16
		BRNE SET_Y_Q
		LDI R16,15
		CLR R13							
SET_X_Q_15:							;Set x=15
		RCALL KEY_D
		INC R13
		DEC R16
		BRNE SET_X_Q_15
		RJMP EXIT_OPTION_KEY_Q		;Jump to exit

		//Case of Q exceeding the Reverse secondary diagonal 
		//Need to set Point(15,0)
OVER_0_15_Q:
		RCALL SETUP_MATRIX
		LDI R16,15
SET_15_0_Q:
		RCALL KEY_D
		INC R13
		DEC R16
		BRNE SET_15_0_Q
EXIT_OPTION_KEY_Q:					;Exit key press		
		RET
;============================================================================================
;INITIALIZE 16X16 LED MATRIX
;============================================================================================
;Matrix LED A has four vertex coordinates: (0,0), (7,0), (0,7), (7,7)
;Matrix LED B has four vertex coordinates: (8,0), (15,0), (8,7), (15,7)
;Matrix LED C has four vertex coordinates: (0,8), (7,8), (0,15), (7,15)
;Matrix LED D has four vertex coordinates: (8,8), (15,8), (8,15), (15,15)
;Set all GND pins of LED matrices A-D to high-active state
;Set one lit point at coordinate (0,0)
;============================================================================================
SETUP_MATRIX:
		//Clear power pins of LED matrices
		SBI PORTA,6			;Enable 573_row
		LDI R20,16			;Number of Power (P) pins
		PUSH R20			;Push onto stack	
		CBI	PORTA,1			;Set low level for 595_row_A_B  
LP_CLR_A_B:
		CBI PORTA,0			;Generate rising edge for data transmission
		SBI PORTA,0			;Latch output of shift register
		CBI PORTA,2			;595_row_A_B
		SBI PORTA,2			
		DEC R20				;Decrease power pin counter
		BRNE LP_CLR_A_B		;If not cleared completely, repeat
		POP R20				;Retrieve power pin count
		CBI	PORTA,4			;Set low level for 595_row_C_D  
LP_CLR_C_D:
		CBI PORTA,3			;Generate rising edge for data transmission
		SBI PORTA,3			;Latch output of shift register
		CBI PORTA,5			;595_row_C_D
		SBI PORTA,5	
		DEC R20				;Decrease power pin counter		
		BRNE LP_CLR_C_D		;If not cleared completely, repeat
		CBI PORTA,6			;Disable 573_row
		
		//Set GND pins of LED matrices
		SBI PORTA,7			;Enable 573_col
		LDI R20,16			;Number of GND pins
		PUSH R20			;Push onto stack	
		SBI	PORTA,1			;Set high level for 595_col_A_C  
LP_SET_A_C:
		CBI PORTA,0			;Generate rising edge for data transmission
		SBI PORTA,0			;Latch output of shift register
		CBI PORTA,2			;595_col_A_C
		SBI PORTA,2			
		DEC R20				;Decrease GND pin counter
		BRNE LP_SET_A_C		;If not set completely, repeat
		POP R20				;Retrieve GND pin count
		SBI	PORTA,4			;Set high level for 595_col_B_D 
LP_SET_B_D:
		CBI PORTA,3			;Generate rising edge for data transmission
		SBI PORTA,3			;Latch output of shift register
		CBI PORTA,5			;595_col_B_D
		SBI PORTA,5	
		DEC R20				;Decrease GND pin counter		
		BRNE LP_SET_B_D		;If not set completely, repeat

		//Set one lit pixel at coordinate (0,0)
		//Set low-active state for GND pin at coordinate (x,0)
		CBI	PORTA,1			;Set low level for 595_col_A_C
		CBI PORTA,0			;Generate rising edge for data transmission
		SBI PORTA,0			;Latch output of shift register
		CBI PORTA,2			
		SBI PORTA,2
		CBI PORTA,0	
		CBI PORTA,7			;Disable 573_col

		//Set high-active state for Power pin at coordinate (0,y)
		CLR R16				;Clear all PA pins before connecting 
		OUT PORTA,R16		;595_row_A_B
		SBI PORTA,6			;Enable 573_row_A_B
		SBI	PORTA,1			;Set high level for 595_row_A_B
		CBI PORTA,0			;Generate rising edge for data transmission
		SBI PORTA,0			;595_row_A_B
		CBI PORTA,2		
		SBI PORTA,2
		CBI PORTA,0
		CBI PORTA,6			;Disable 573_row_A_B
		//Clear registers used for position counting (location)
		CLR R10				;Clear row coordinate counter (y) in a matrix (0->8)
		CLR R11				;Clear column coordinate counter (x) in a matrix (0->8)
		CLR R12				;Clear row coordinate counter (y) in 4 matrices (0->15)
		CLR R13				;Clear column coordinate counter (x) in 4 matrices (0->15)
		CLR R0				;Clear matrix coordinate counter (Y) (0->2)	
		CLR R1				;Clear matrix coordinate counter (X) (0->2)
		RET	
;--------------------------------------------------
DELAY_500MS:	
		LDI R19,5			;0.5s = 5 * 100ms
LP3:	LDI R18,100			;100ms = 100 * 1ms	
LP2:	LDI R17,200			;1ms = 5 * 200
LP1:	LDI R16,8			;5 * 8 = 40MC -> 5us	
LP:		NOP
		NOP
		DEC R16
		BRNE LP
		DEC R17
		BRNE LP1
		DEC R18
		BRNE LP2
		DEC R19
		BRNE LP3
		RET
