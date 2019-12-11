#include <avr/io.h>
#include "mappings.S"
#include "delay_cs.S"
#define __SFR_OFFSET 0

;Timings in centiseconds
DOT = 10
DASH = 30
SIGNAL_GAP = 10
LETTER_GAP = 30
WORD_GAP = 70

;Set output bit
OUTPUT = 7

;r16 = current morse byte, r17 = counter, r18 = bit pair to look at, r19 = AND mask, r24 = delay in cs
    .section .text
	.global main
main:
    ;Enable output
    ldi r16, _BV(OUTPUT)
    out DDRB, r16
    clr r16
    ;Load table pointers
    ldi r30, lo8(ButtonBits)
    ldi r31, hi8(ButtonBits)
    ;Set AND mask
    ldi r19, 0b00000011

loadbyte:
    lpm r16, Z+
    ldi r17, 3 ;initial counter value

loop:
    mov r18, r16 ;load fresh byte for testing
    tst r17 ;skip shifting if on last bit pair
    breq skipshift   

    push r17 ;save counter
    add r17, r17
rightshift:
	lsr r18 
	dec r17
	tst r17
	brne rightshift
    pop r17 ;restore counter

skipshift:
    and r18, r19 ;should now have 000000XX
    cpi r18, 0b00000001
    breq dot
    cpi r18, 0b00000011
    breq dash
    rjmp end ;skip output if pair is 00

dot:
    sbi PORTB, OUTPUT
    ldi r24, DOT
    rcall delay_cs
    rjmp end

dash:
    cpi r18, 0
    sbi PORTB, OUTPUT
    ldi r24, DASH
    rcall delay_cs
    rjmp end

end:
    cbi PORTB, OUTPUT
	
    
