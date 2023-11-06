GPIOE_BASE EQU 0x40021000	;Base of port E

;this is where you write your data as an output into the port
GPIOE_ODR EQU 0x40021014    ;output register of port E, PE0 - PE15

RCC_AHB1ENR EQU 0x40023830 ;this register is responsible for enabling certain ports, by making the clock affect the target port.

INTERVAL EQU 0x186004		;just a number to perform the delay. this number takes roughly 1 second to decrement until it reaches 0
	

;the following are pins connected from our EasyMX board to the TFT
;RD = PE10		Read pin	--> to read from touch screen input 
;WR = PE11		Write pin	--> to write data/command to display
;RS = PE12		Command pin	--> to choose command or data to write
;CS = PE15		Chip Select	--> to enable the TFT, lol
;RST= PE8		Reset		--> to reset the TFT (active low)


BLACK	EQU   	0x0000
BLUE 	EQU  	0x001F
RED  	EQU  	0xF800
RED2   	EQU 	0x4000
GREEN 	EQU  	0x07E0
CYAN  	EQU  	0x07FF
MAGENTA EQU 	0xF81F
YELLOW	EQU  	0xFFE0
WHITE 	EQU  	0xFFFF
GREEN2 	EQU 	0x2FA4
CYAN2 	EQU  	0x07FF


	EXPORT __main
	

	AREA	MYCODE, CODE, READONLY


__main FUNCTION

	BL SETUP

	MOV R0, #200
	MOV R1, #240
	LDR R10, =RED
	MOV R3, #200
	MOV R4, #0

	BL DRAW_LINE


STARTAG
	MOV R0, #40
	MOV R1, #40
	MOV R3, #180
	MOV R4, #180
	LDR R10, =RED

	BL DRAW_RECTANGLE_FILLED

	LDR R10, =GREEN
	BL DRAW_RECTANGLE_FILLED
	LDR R10, =0xe7e0
	BL DRAW_RECTANGLE_FILLED
	LDR R10, =WHITE
	BL DRAW_RECTANGLE_FILLED
	LDR R10, =MAGENTA
	BL DRAW_RECTANGLE_FILLED

	B STARTAG


;SKIP ALL FUNCTION DECLARATION
	B ENDPROGRAM

;#####################################################################################################################################################################
LCD_WRITE
	PUSH {r0-r2, LR}
	;this function takes what is inside r2 and writes it to the tft
	;this function writes 8 bits only
	;later we will choose whether those 8 bits are considered a command, or just pure data


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SETTING WR to 0 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDR r1, =GPIOE_ODR
	LDR r0, [r1]
	AND r0, r0, #0xFFFFF7FF
	STRH r0, [r1]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; HERE YOU PUT YOUR DATA which is in R2 TO PE0-7 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDR r1, =GPIOE_ODR
	STRB r2, [r1]			;only write the lower byte to PE0-7
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;; SETTING WR to 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDR r1, =GPIOE_ODR
	LDR r0, [r1]
	ORR r0, r0, #0x00000800
	STRH r0, [r1]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	POP {R0-r2, PC}
;#####################################################################################################################################################################











;#####################################################################################################################################################################
LCD_COMMAND_WRITE
	PUSH {R0-R2, LR}
	;this function writes a command to the TFT, the command is read from R2
	;it writes LOW to RS first to specify that we are writing a command not data.


	;RD HIGH
	LDR r1, =GPIOE_ODR
	LDR r0, [r1]
	ORR r0, r0, #0x00000400
	STRH r0, [r1]

;;;;;;;;;;;;;;;;;;;;;;;;; SETTING RS to 0 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDR r1, =GPIOE_ODR
	LDR r0, [r1]
	AND r0, r0, #0xFFFFEFFF
	STRH r0, [r1]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	BL LCD_WRITE	;Call Function LCD_WRITE
	POP {R0-R2, PC}
;#####################################################################################################################################################################






;#####################################################################################################################################################################
LCD_DATA_WRITE
	PUSH {R0-R2, LR}
	;this function writes Data to the TFT, the data is read from R2
	;it writes HIGH to RS first to specify that we are writing data not a command.



	;RD HIGH
	LDR r1, =GPIOE_ODR
	LDR r0, [r1]
	ORR r0, r0, #0x00000400
	STRH r0, [r1]

;;;;;;;;;;;;;;;;;;;;;;;;;; SETTING RS to 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDR r1, =GPIOE_ODR
	LDR r0, [r1]
	ORR r0, r0, #0x00001000
	STRH r0, [r1]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	BL LCD_WRITE	;Call Function LCD_WRITE
	POP {R0-R2, PC}
;#####################################################################################################################################################################






;#####################################################################################################################################################################
LCD_INIT
	PUSH {R0-R2, LR}
  ;This function will have LCD initialization measures
  ;Only the necessary Commands are covered
  ;Eventho there are so many more in DataSheet

;RESET_SIGNAL_HIGH
	LDR r1, =GPIOE_ODR
	LDR r0, [r1]
	ORR r0, r0, #0x0000100
	STRH r0, [r1]


	BL delay_1_second


;RESET_SIGNAL_LOW
	LDR r1, =GPIOE_ODR
	LDR r0, [r1]
	AND r0, r0, #0xFFFFFEFF
	STRH r0, [r1]


	BL delay_10_milli_second

;RESET_SIGNAL_HIGH
	LDR r1, =GPIOE_ODR
	LDR r0, [r1]
	ORR r0, r0, #0x00000100
	STRH r0, [r1]


	BL delay_1_second


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PREPARATION FOR WRITE CYCLE SEQUENCE ;;;;;;;;;;;;;;;;;;
	;CS HIGH
	LDR r1, =GPIOE_ODR
	LDR r0, [r1]
	ORR r0, r0, #0x00008000
	STR r0, [r1]

	;WR HIGH
	LDR r1, =GPIOE_ODR
	LDR r0, [r1]
	ORR r0, r0, #0x00000800
	STRH r0, [r1]

	;RD HIGH
	LDR r1, =GPIOE_ODR
	LDR r0, [r1]
	ORR r0, r0, #0x00000400
	STRH r0, [r1]


	;CS LOW
	LDR r1, =GPIOE_ODR
	LDR r0, [r1]
	AND r0, r0, #0xFFFF7FFF
	STR r0, [r1]

	

	;SET THE CONTRAST
	MOV R2, #0xC5
	BL LCD_COMMAND_WRITE

	;VCOM H 1111111
	MOV R2, #0x7F
	BL LCD_DATA_WRITE

	;VCOM L 00000000
	MOV R2, #0x00
	BL LCD_DATA_WRITE


	;MEMORY ACCESS CONTROL | DATASHEET PAGE 127
	MOV R2, #0x36
	BL LCD_COMMAND_WRITE

	;ADJUST THIS VALUE TO GET RIGHT COLOR AND STARTING POINT OF X AND Y
	MOV R2, #0x40
	BL LCD_DATA_WRITE

	;COLMOD: PIXEL FORMAT SET | DATASHEET PAGE 134
	MOV R2, #0x3A
	BL LCD_COMMAND_WRITE

	;16 BIT RGB AND MCU
	MOV R2, #0x55
	BL LCD_DATA_WRITE

	;SLEEP OUT | DATASHEET PAGE 245
	MOV R2, #0x11
	BL LCD_COMMAND_WRITE

	BL delay_1_second



	;NECESSARY TO WAIT 5MSEC BEFORE SENDING NEXT COMMAND
	;I WILL WAIT FOR 10MSEC TO BE SURE

	;DISPLAY ON
	MOV R2, #0x29
	BL LCD_COMMAND_WRITE

	;COLOR INVERSION OFF
	MOV R2, #0x21
	BL LCD_COMMAND_WRITE

	;MEMORY WRITE | DATASHEET PAGE 245
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE	



	POP {R0-R2, PC}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;#####################################################################################################################################################################






;#####################################################################################################################################################################
ADDRESS_SET
	PUSH {R0-R4, LR}
	;THIS FUNCTION TAKES Y1, Y2, X1, X2
	;R0 = Y1
	;R1 = Y2
	;R3 = X1
	;R4 = X2

	;COLUMN ADDRESS SET | DATASHEET PAGE 110
	MOV R2, #0x2A
	BL LCD_COMMAND_WRITE

	;8BIT SHIFT RIGHT OF Y1
	MOV R2, R0
	LSR R2, #8
	BL LCD_DATA_WRITE

	;VALUE OF Y1
	MOV R2, R0
	BL LCD_DATA_WRITE


	;8BIT SHIFT RIGHT OF Y2
	MOV R2, R1
	LSR R2, #8
	BL LCD_DATA_WRITE

	;VALUE OF Y2
	MOV R2, R1
	BL LCD_DATA_WRITE



	;PAGE ADDRESS SET | DATASHEET PAGE 110
	MOV R2, #0x2B
	BL LCD_COMMAND_WRITE

	;8BIT SHIFT RIGHT OF X1
	MOV R2, R3
	LSR R2, #8
	BL LCD_DATA_WRITE

	;VALUE OF X1
	MOV R2, R3
	BL LCD_DATA_WRITE


	;8BIT SHIFT RIGHT OF X2
	MOV R2, R4
	LSR R2, #8
	BL LCD_DATA_WRITE

	;VALUE OF X2
	MOV R2, R4
	BL LCD_DATA_WRITE

	;MEMORY WRITE
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE



	POP {R0-R4, PC}
;#####################################################################################################################################################################



;#####################################################################################################################################################################
DRAWPIXEL
	PUSH {R0-R4, r10, LR}
	;THIS FUNCTION TAKES X AND Y AND A COLOR AND DRAWS THIS PIXEL
	;R0 = X
	;R1 = Y
	;R10 = COLOR

	;CHIP SELECT ACTIVE, WRITE LOW TO CS
	LDR r3, =GPIOE_ODR
	LDR r4, [r3]
	AND r4, r4, #0xFFFF7FFF
	STR r4, [r3]

	;SETTING PARAMETERS FOR FUNC 'ADDRESS_SET' CALL
	MOV R3, R0 ;X1
	ADD R4, R0, #1 ;X2
	MOV R0, R1 ;Y1
	ADD R1, R0, #1 ;Y2

	BL ADDRESS_SET


	
	;MEMORY WRITE
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE


	MOV R2, R10
	LSR R2, #8
	BL LCD_DATA_WRITE
	MOV R2, R10
	BL LCD_DATA_WRITE


	
	POP {R0-R4, r10, PC}
;#####################################################################################################################################################################








;#####################################################################################################################################################################
SETUP
	PUSH {R0-R12, LR}

	;Make the clock affect port E by enabling the corresponding bit (the third bit) in RCC_AHB1ENR register
	LDR r1, =RCC_AHB1ENR
	LDR r0, [r1, #0]
	ORR r0, r0, #0x10
	STR r0, [r1, #0]
	
	
	;Make the GPIO E mode as output (01 for each pin)
	LDR r0, =GPIOE_BASE
	mov r1, #0x55555555
	STR r1, [r0]
	
	
	;Make the Output type as Push-Pull not Open-drain, by clearing all the bits in the lower 2 bytes of OTYPE register, the higher 2 bytes are reserved.
	mov r0, #0
	LDR r1, =GPIOE_BASE
	ADD r1, r1, #0x04	;go to OTYPER of GPIOE which is at offset 0x04 from base of GPIOE
	STRH r0, [r1]
	
	;Make the Output speed as super fast by clearing all the bits in the OSPEED register
	;00 means slow
	;01 means medium
	;10 means fast
	;11 means super fast
	;2 bits for each pin and we will choose slow
	;this register just scales the time of flipping from low to high or from high to low.
	mov r0, #0xFFFFFFFF
	LDR r1, =GPIOE_BASE
	ADD r1, r1, #0x08	;go to OSPEEDR of GPIOE which is at offset 0x08 from base of GPIOE
	STR r0, [r1]
	
	
	;Clear the Pullup-pulldown bits for each port, we don't need the internal resistors
	mov r0, #0
	LDR r1, =GPIOE_BASE
	ADD r1, r1, #0x0c	;go to PUPDR of GPIOE which is at offset 0x0C from base of GPIOE
	STR r0, [r1]



	LDR r1, =GPIOE_ODR
	LDR r0, [r1]
	ORR r0, #0x00007F00
	STRH r0, [r1]
	

	BL LCD_INIT

	POP {R0-R12, PC}
;#####################################################################################################################################################################









;##########################################################################################################################################
delay_1_second
	;this function just delays for 1 second
	PUSH {R8, LR}
	LDR r8, =INTERVAL
delay_loop
	SUBS r8, #1
	CMP r8, #0
	BGE delay_loop
	POP {R8, PC}
;##########################################################################################################################################




;##########################################################################################################################################
delay_half_second
	;this function just delays for half a second
	PUSH {R8, LR}
	LDR r8, =INTERVAL
delay_loop1
	SUBS r8, #2
	CMP r8, #0
	BGE delay_loop1

	POP {R8, PC}
;##########################################################################################################################################


;##########################################################################################################################################
delay_milli_second
	;this function just delays for a millisecond
	PUSH {R8, LR}
	LDR r8, =INTERVAL
delay_loop2
	SUBS r8, #1000
	CMP r8, #0
	BGE delay_loop2

	POP {R8, PC}
;##########################################################################################################################################



;##########################################################################################################################################
delay_10_milli_second
	;this function just delays for a millisecond
	PUSH {R8, LR}
	LDR r8, =INTERVAL
delay_loop3
	SUBS r8, #100
	CMP r8, #0
	BGE delay_loop3

	POP {R8, PC}
;##########################################################################################################################################























;##########################################################################################################################################
DRAW_LINE
	PUSH {R0-R12, LR}
	;THIS FUNCTION TAKES X1, Y1, COLOR, X2, Y2 AND COLOR AND THEN DRAWS THE LINE ACCORDING TO BRESENHAM'S ALGORITHM

	;R0 = X1
	;R1 = Y1
	;R10 = COLOR
	;R3 = X2
	;R4 = Y2


	;DELTA X
	SUBS R5, R3, R0
	MOV R11, R5
	CMP R5, #0
	BEQ DRAW_VERTICAL_LINE

	;DELTA Y
	SUBS R6, R4, R1

	CMP R6, #0
	BEQ DRAW_HORIZONTAL_LINE

	;P0 = 2dY - dX
	LSL R6, #2
	SUBS R8, R6, R5


LINE_DRAW_LOOP
	SUBS R11, R11, #1
	CMP R11, #0
	BLT END_LINE
	BL DRAWPIXEL
	CMP R8, #0
	BLT ADVANCE_X
	BGE ADVANCE_BOTH

ADVANCE_X			;X += 1    AND P(k+1) = P(k) + 2dY
	ADD R0, R0, #1
	SUBS R6, R4, R1
	LSL R6, #2
	ADD R8, R6

	B LINE_DRAW_LOOP

ADVANCE_BOTH		;X+=1 AND Y+=1 AND P(k+1) = P(k) + 2dY - 2dX
	ADD R0, R0, #1
	ADD R1, R1, #1
	SUBS R6, R4, R1
	LSL R6, #2
	SUBS R5, R3, R0
	LSL R5, #2	
	ADD R8, R8, R6
	SUBS R8, R8, R5
	B LINE_DRAW_LOOP



DRAW_HORIZONTAL_LINE
	CMP R5, #0
	BGE HORIZ_LINE_LOOP
	MVN R5, R5
	ADD R5, R5, #1
	MOV R6, R0
	MOV R0, R3
	MOV R3, R6

HORIZ_LINE_LOOP
	BL DRAWPIXEL
	ADD R0, R0, #1
	SUBS R5, R5, #1
	CMP R5, #0
	BGE HORIZ_LINE_LOOP
	B END_LINE

DRAW_VERTICAL_LINE
	SUBS R6, R4, R1
	CMP R6, #0
	BGE VERT_LINE_LOOP
	MVN R6, R6
	ADD R6, R6, #1
	MOV R5, R1
	MOV R1, R4
	MOV R4, R5

VERT_LINE_LOOP
	BL DRAWPIXEL
	ADD R1, R1, #1
	SUBS R6, R6, #1
	CMP R6, #0
	BGE VERT_LINE_LOOP
	B END_LINE


END_LINE



	POP {R0-R12, PC}
;##########################################################################################################################################













;##########################################################################################################################################
DRAW_RECTANGLE
	PUSH {R0-R12, LR}
	;THIS FUNCTION TAKES THE UPPER-LEFT AND LOWER-RIGHT DIAGONAL POINTS, THEN DRAWS THE RECTANGLE
	;R0 = X1
	;R1 = Y1
	;R3 = X2
	;R4 = Y2
	;R10 = COLOR

	PUSH {R4}
	MOV R4, R1
	BL DRAW_LINE
	POP {R4}

	PUSH {R3}
	MOV R3, R0
	BL DRAW_LINE
	POP {R3}

	PUSH {R1}
	MOV R1, R4
	BL DRAW_LINE
	POP {R1}

	PUSH {R0}
	MOV R0, R3
	BL DRAW_LINE
	POP {R0}



	POP {R0-R12, PC}
;##########################################################################################################################################






;##########################################################################################################################################
DRAW_RECTANGLE_FILLED
	PUSH {R0-R12, LR}
	;THIS FUNCTION TAKES THE UPPER-LEFT AND LOWER-RIGHT DIAGONAL POINTS, THEN DRAWS THE RECTANGLE THEN FILLS ITS INSIDE
	;R0 = X1
	;R1 = Y1
	;R3 = X2
	;R4 = Y2
	;R10 = COLOR

RECT_FILL_LOOP
	BL DRAW_RECTANGLE
	ADD R1, R1, #1
	SUBS R4, R4, #1
	ADD R0, R0, #1
	SUBS R3, R3, #1
	CMP R0, R3
	BGT END_RECT_FILL
	B RECT_FILL_LOOP


END_RECT_FILL



	POP {R0-R12, PC}
;##########################################################################################################################################












ENDPROGRAM
	ENDFUNC
	END