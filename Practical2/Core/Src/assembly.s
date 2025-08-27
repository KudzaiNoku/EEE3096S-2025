/*
 * assembly.s
 *
 */
 
 @ DO NOT EDIT
	.syntax unified
    .text
    .global ASM_Main
    .thumb_func

@ DO NOT EDIT
vectors:
	.word 0x20002000
	.word ASM_Main + 1

@ DO NOT EDIT label ASM_Main
ASM_Main:

	@ Some code is given below for you to start with
	LDR R0, RCC_BASE  		@ Enable clock for GPIOA and B by setting bit 17 and 18 in RCC_AHBENR
	LDR R1, [R0, #0x14]
	LDR R2, AHBENR_GPIOAB	@ AHBENR_GPIOAB is defined under LITERALS at the end of the code
	ORRS R1, R1, R2
	STR R1, [R0, #0x14]

	LDR R0, GPIOA_BASE		@ Enable pull-up resistors for pushbuttons
	MOVS R1, #0b01010101
	STR R1, [R0, #0x0C]
	LDR R1, GPIOB_BASE  	@ Set pins connected to LEDs to outputs
	LDR R2, MODER_OUTPUT
	STR R2, [R1, #0]
	MOVS R2, #0         	@ NOTE: R2 will be dedicated to holding the value on the LEDs
	MOVS  R4, #0xFF            @ mask = 0xFF

@ TODO: Add code, labels and logic for button checks and LED patterns

main_loop:
	SW3_pressed:
		@check if the button SW3 is pressed
		LDR R5, [R0, #0x10]
		MOVS R7, #8 @ 8=0b0000 1000
		ANDS R5, R7 @isolate PA3 bit
		@if pressed, keep in this loop till its released
		CMP R5, #0
		BEQ SW3_pressed

	@check if the button SW2 is pressed
	LDR R5, [R0, #0x10]
	MOVS R7, #4 @ 4=0b0000 0100
	ANDS R5, R7 @isolate PA2 bit
	@if SW2 has been pressed, go to buttonSW2_pressed until button is no longer pressed
	CMP R5, #0
	BEQ buttonSW2_pressed

	@ read ODR into temp register R3
	LDR R3, [R1, #0x14]
	@ make R3 and R2 values match
	BICS R3, R4 @this clears the last 8bits of the temp ODR : R3 = R3 & (~0xFF)
	ANDS R2, R4 @this ensures only last 8 bits of R2 are used: R2 = R2 & 0xFF
	ORRS R3, R2 @ this makes R2 and R3 match, by or'ing the two : R3 = R3 | R2
	@ write R3 back to ODR
	STR R3, [R1, #0x14]
	@ delay
	BL delay

	@ update R2 - must check if SW0 is pressed or not
	LDR R5, [R0, #0x10] @get IDR address and load into temp register R5
	@make bitmask for SW0, use it to check if SW0 is pressed, i.e if PA0 bit=1
	MOVS R6, #1 @ #1 = 0b00000001
	ANDS R5, R6 @R5 (IDR) being anded with the bitmask to check if pa0 is on
	@if R5 == 0, add 2, but if not, add one
	CMP R5, #0
	BEQ add_two

	@defaul, add 1
	ADDS R2, R2, #1
	B wrap_value

	add_two:
		ADDS R2, R2, #2
	wrap_value:
		ANDS  R2, R2, R4 @ wrap R2 back after 255

	B main_loop

@write_leds:
	@STR R2, [R1, #0x14]
	@B main_loop


buttonSW2_pressed:
	@MOV R5, #0xAA
	@STR R5, STR R3, [R1, #0x14]

    LDR R3, [R1, #0x14] @ read GPIOB->ODR
    BICS R3, R4 @ clear low 8
    MOVS R5, #0xAA
    ORRS R3, R5 @ insert 0xAA
    STR  R3, [R1, #0x14]      @ write ODR

hold_it_right_there:
	BL delay

    @check SW2 again and stay here while still pressed
    LDR   R5, [R0, #0x10]@ IDR
    MOVS  R7, #4  @ mask PA2
    ANDS  R5, R7
    CMP   R5, #0
    BEQ   hold_it_right_there  @keep forcing 0xAA if still pressed

	B main_loop


@ --- delay subroutine: ~0.7 s if LONG_DELAY_CNT ≈ 1400000 ---
@ uses R6 as the loop counter
@ clobbers: R6
delay:
	@get idr register value
	LDR R5, [R0, #0x10]
	@use bitmask to check value of PA1
	MOVS R3, #2 @ #2 = 0b00000010
	ANDS R5, R3 @ isolate PA1 bit
	@ if bit of PA1 = 0, button has been pressed, R6 = short_delay_cnt
	CMP R5, #0
	BEQ short_delay
	LDR R6, LONG_DELAY_CNT

	short_delay:
    	LDR   R6, SHORT_DELAY_CNT   @ load the literal value (from .word below)
delay_loop:
    SUBS  R6, #1               @ 1 cycle
    BNE   delay_loop           @ ~3 cycles when taken, 1 when not
    BX    LR                   @ return

@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
LONG_DELAY_CNT: 	.word 1400000   @ ~0.7 (8MHz * 0.7/ 4 cycles)
SHORT_DELAY_CNT: 	.word 600000    @ ~0.3 s (8MHz * 0.3 / 4 cycles)
