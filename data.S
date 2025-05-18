#define __SFR_OFFSET 0x00
#include "avr/io.h"

.section .data
.global suhu
.global hum
.global status_alarm
.global buzzer_off_flag
suhu: .float 0
hum:  .float 0
status_alarm: .byte 1
buzzer_off_flag: .byte 1