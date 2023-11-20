

GPIOE_BASE EQU 0x40021000	;Base of port E
GPIOC_BASE EQU 0x40020800
GPIOC_PUPDR EQU GPIOC_BASE + 0x0C
GPIOC_IDR EQU GPIOC_BASE + 0x10

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
	IMPORT DIO
	
	

	AREA	MYCODE, CODE, READONLY
	ENTRY
	
__main FUNCTION


	BL SETUP



	MOV R0, #0
	MOV R1, #0
	MOV R3, #320
	MOV R4, #240
	LDR R10, =WHITE
	BL DRAW_RECTANGLE_FILLED


	bl delay_1_second


	MOV R0, #0
	MOV R1, #0
	LDR R10, =RED
	MOV R3, #320
	MOV R4, #0

Draw_multiple_lines_horizontal
	BL DRAW_LINE
	mov r0, #0
	add r1, r1, #3
	LDR R10, =RED
	mov R3, #320
	add R4, r4, #3
	cmp r4, #240
	blt Draw_multiple_lines_horizontal
	
	bl delay_1_second
	bl delay_1_second
	bl delay_1_second


	MOV R0, #0
	MOV R1, #0
	MOV R3, #320
	MOV R4, #240
	LDR R10, =WHITE
	BL DRAW_RECTANGLE_FILLED


	MOV R0, #0
	MOV R1, #0
	LDR R10, =RED
	MOV R3, #0
	MOV R4, #240
Draw_multiple_lines_vertical
	BL DRAW_LINE
	add r0, r0, #4
	mov r1, #0
	LDR R10, =RED
	add r3, r3, #4
	mov r4, #240
	cmp r0, #320
	blt Draw_multiple_lines_vertical
	
	bl delay_1_second
	bl delay_1_second
	bl delay_1_second
	



	MOV R0, #0
	MOV R1, #0
	MOV R3, #320
	MOV R4, #240
	LDR R10, =RED

	BL DRAW_RECTANGLE_FILLED


STARTAG
	MOV R0, #0
	MOV R1, #0
	MOV R3, #320
	MOV R4, #240
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





	MOV R0, #0
	MOV R1, #0
	MOV R3, #320
	MOV R4, #240
	LDR R10, =WHITE

	BL DRAW_RECTANGLE_FILLED
		bl delay_1_second
	
	bl DRAW_SNAKE




	bl delay_1_second

	MOV R0, #160
	MOV R1, #6
	MOV R3, #163
	MOV R4, #230
	LDR R10, =BLACK
	BL DRAW_RECTANGLE_FILLED

	bl delay_1_second

	MOV R0, #120
	MOV R1, #210
	MOV R3, #240
	MOV R4, #212
	LDR R10, =BLACK
	BL DRAW_RECTANGLE_FILLED


	


	
	BL DRAW_IMAGE

	;B STARTAG


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




OPTIMIZED_DATA_WRITE
	PUSH {LR}
	;this function writes Data to the TFT, the data is read from R2
	;it writes HIGH to RS first to specify that we are writing data not a command.

;;;;;;;;;;;;;;;;;;;;;;;;;; SETTING RS to 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDR r1, =GPIOE_ODR
	LDR r0, [r1]
	ORR r0, r0, #0x00001000
	STRH r0, [r1]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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




	POP {PC}
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


	
	;FRAME RATE (119HZ)
	MOV R2, #0xB1
	BL LCD_COMMAND_WRITE

	;SET DIVISION RATIO TO FOSC
	MOV R2, #0x00
	BL LCD_DATA_WRITE

	;SET CLOCKS PER LINE TO 119HZ
	MOV R2, #0x10
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


;####################################################################################################################################################################
TEST
	PUSH {R0-R4, r10, LR}

	;CHIP SELECT ACTIVE, WRITE LOW TO CS
	LDR r3, =GPIOE_ODR
	LDR r4, [r3]
	AND r4, r4, #0xFFFF7FFF
	STR r4, [r3]

	;SETTING PARAMETERS FOR FUNC 'ADDRESS_SET' CALL
	MOV R3, R0 ;X1
	ADD R4, R0, #50 ;X2
	MOV R0, R1 ;Y1
	ADD R1, R0, #50 ;Y2

	BL ADDRESS_SET

	MOV R12, #200

	;MEMORY WRITE
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE

LOOPYSS
	MOV R2, R10
	LSR R2, #8
	BL LCD_DATA_WRITE
	MOV R2, R10
	BL LCD_DATA_WRITE
	SUBS R12, R12, #1
	CMP R12, #0
	BGT LOOPYSS


	;MEMORY WRITE
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE



	POP {R0-R4, r10, PC}
;###################################################################################################################################################################





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



	B SKIPED
	LTORG
SKIPED






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



	PUSH {R0-R4}
;just reorder arguments to set the address (column & page)
	mov r5, r0
	mov r6, r3
	mov r0, r1
	mov r1, r4
	mov r3, r5
	mov r4, r6
	;THE NEXT FUNCTION TAKES Y1, Y2, X1, X2
	;R0 = Y1
	;R1 = Y2
	;R3 = X1
	;R4 = X2
	bl ADDRESS_SET
	
	POP {R0-R4}

	SUBS R3, R3, R0
	add r3, r3, #1
	SUBS R4, R4, R1
	add r4, r4, #1
	MUL R3, R3, R4


;MEMORY WRITE
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE


RECT_FILL_LOOP
	MOV R2, R10
	LSR R2, #8
	BL OPTIMIZED_DATA_WRITE
	MOV R2, R10
	BL OPTIMIZED_DATA_WRITE

	SUBS R3, R3, #1
	CMP R3, #0
	BGT RECT_FILL_LOOP

	;BL DRAW_RECTANGLE
	;ADD R1, R1, #1
	;SUBS R4, R4, #1
	;ADD R0, R0, #1
	;SUBS R3, R3, #1
	;CMP R0, R3
	;BGT END_RECT_FILL
	;B RECT_FILL_LOOP


END_RECT_FILL



	POP {R0-R12, PC}
;##########################################################################################################################################






DRAW_IMAGE
	PUSH {R0-R12, LR}
	
	MOV R0, #91
	MOV R1, #185
	MOV R3, #101
	MOV R4, #260
	bl ADDRESS_SET

	LDR R5, =DIO
	MOV R7, #15000


	;MEMORY WRITE
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE

IMAGE_LOOP
	LDR R6, [R5], #2


	MOV R2, R6
	LSR R2, #8
	BL LCD_DATA_WRITE
	MOV R2, R6
	BL LCD_DATA_WRITE

	SUBS R7, R7, #1
	CMP R7, #0
	BNE IMAGE_LOOP



	POP {R0-R12, PC}










DRAW_SNAKE
	push {r0-r12, LR}

	bl CONFIGURE_INPUTS
	mov r11, #26
	mov r12, #206
	bl DRAW_APPLE

	mov r0, #300
	mov r1, #150
	mov r3, #300
	mov r4, #150

horiz_loop
	
;Winning Checks
	subs r5, r0, r11
	cmp r5, #0
	bgt skipnegation1
	mvn r5, r5
	add r5, r5, #1

skipnegation1
	cmp r5, #11
	blt second_win_check
	b losing_check

second_win_check
	subs r5, r1, r12
	bgt skipnegation2
	mvn r5, r5
	add r5, r5, #1
	
skipnegation2
	cmp r5, #13
	blt win_game
	b draw_snake_cont

;Losing Checks
losing_check
	cmp r0, #0
	ble lose_game

	cmp r0, #320
	bgt lose_game
	
	cmp r1, #0
	ble lose_game

	cmp r1, #240
	bgt lose_game


draw_snake_cont
	add R3, r0, #3
	add R4, r1, #3
	LDR R10, =BLACK
	BL DRAW_RECTANGLE_FILLED
	BL delay_10_milli_second
	BL delay_10_milli_second
	bl recieve_input

	cmp r6, #0 ;go left
	bne snake_left

	cmp r8, #0 ;go right
	bne snake_right

	cmp r7, #0 ;go up
	bne snake_up

	cmp r9, #0 ;go down
	bne snake_down

	b cont_snake


snake_left
	subs r0, r0, #3
	b horiz_loop

snake_up
	subs r1, r1, #3
	b horiz_loop

snake_right
	adds r0, r0, #3
	B horiz_loop

snake_down
	adds r1, r1, #3
cont_snake
	B horiz_loop


win_game
	bl DRAW_IMAGE
stop1 b stop1

lose_game
	MOV R0, #0
	mov R1,	#0
	mov R3, #320
	mov R4, #240
	LDR R10, =RED
	BL DRAW_RECTANGLE_FILLED
stop2 b stop2
	pop {r0-r12, pc}











CONFIGURE_INPUTS
	push{r0-r12, lr}
	
	;Make the clock affect port C by enabling the corresponding bit (the third bit) in RCC_AHB1ENR register
	LDR r1, =RCC_AHB1ENR
	LDR r0, [r1, #0]
	ORR r0, r0, #0x04
	STR r0, [r1, #0]
	
	
	;Make the GPIO C mode as input (00 for each pin)
	LDR r0, =GPIOC_BASE
	mov r1, #0x0
	STR r1, [r0]

	pop {r0-r12, pc}


recieve_input
	push{r0-r3, lr}

	ldr r0, =GPIOC_IDR
	ldr r1, [r0]
	mov r3, #1
	and r6, r1, r3, lsl #6 ;test for PC 6
	cmp r6, #0
	bne go_left

	mov r3, #1
	and r8, r1, r3, lsl #2 ;test for PC 2
	cmp r8, #0
	bne go_right

	mov r3, #1
	and r7, r1, r3, lsl #3 ;test for PC 3
	cmp r7, #0
	bne go_up

	mov r3, #1
	and r9, r1, r3    ;test for PC 1
	cmp r9, #0
	bne go_down

	b cont_input

go_left
	mov r8, #0
	mov r7, #0
	mov r9, #0
	mov r6, #1
	b cont_input

go_right
	mov r6, #0
	mov r7, #0
	mov r9, #0
	mov r8, #1
	b cont_input

go_up
	mov r6, #0
	mov r7, #1
	mov r9, #0
	mov r8, #0
	b cont_input


go_down
	mov r6, #0
	mov r7, #0
	mov r9, #1
	mov r8, #0
	b cont_input

cont_input
	pop {r0-r3, pc}







DRAW_APPLE
;this function draws an apple a the x,y coordinates which are passed inside the r11, r12 respectively
; size of apple is 11x14 pixels
	push {r0-r12, lr}


	MOV R0, r11
	add R1, r12, #4
	add R3, r11, #11
	add R4, r12, #14
	LDR R10, =RED
	BL DRAW_RECTANGLE_FILLED

	add R0, r11, #4
	MOV R1, r12
	add R3, r11, #6
	add R4, r12, #8
	LDR R10, =GREEN
	BL DRAW_RECTANGLE_FILLED


	pop {r0-r12, PC}








ENDPROGRAM
	ENDFUNC
	END
