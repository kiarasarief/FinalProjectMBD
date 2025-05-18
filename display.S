#define __SFR_OFFSET 0x00
#include "avr/io.h"

.section .text
.global display_lcd

display_lcd:
    ret