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

@ TODO: Add code, labels and logic for button checks and LED patterns

main_loop:

	@ read ODR into temp register R3
	LDR R3, [R1, #0x14]
	@ make R3 and R2 values match
	BIC R3, R3, #0xFF @this clears the last 8bits of the temp ODR
	ANDS R2, R2, #0xFF @this ensures only last 8 bits of R2 are used
	ORR R3, R3, R2 @ this makes R2 and R3 match, by or'ing the two
	@ write R3 back to ODR
	STR R3, [R1, #0x14]
	@ delay
	BL delay
	@ update R2
	ADDS R2, R2, #1
	ANDS  R2, R2, #0xFF @ wrap back after 255
	B main_loop


@write_leds:
	@STR R2, [R1, #0x14]
	@B main_loop



@ --- delay subroutine: ~0.7 s if LONG_DELAY_CNT ≈ 1400000 ---
@ uses R6 as the loop counter
@ clobbers: R6
delay:
    LDR   R6, LONG_DELAY_CNT   @ load the literal value (from .word below)
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
LONG_DELAY_CNT: 	.word 1400000
SHORT_DELAY_CNT: 	.word 0
