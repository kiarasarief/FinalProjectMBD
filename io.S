#define __SFR_OFFSET 0x00
#include "avr/io.h"

.section .text
.global io_init
.global read_dht11

io_init:
    sbi DDRD, 6
    sbi DDRD, 7
    sbi DDRB, 0
    sbi DDRB, 1
    cbi PORTD, 6
    cbi PORTD, 7
    cbi PORTB, 0
    cbi PORTB, 1
    ret

read_dht11:
    ret