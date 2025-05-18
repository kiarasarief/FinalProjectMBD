#define __SFR_OFFSET 0x00
#include "avr/io.h"

.section .text
.global main_logic
.global reset_alarm_flag

.extern status_alarm
.extern buzzer_off_flag

main_logic:
    push r16
    push r17
    push r18
    push r19

    rcall read_dht11

    ; Kontrol LED & buzzer dari assembly
    lds r18, status_alarm
    cpi r18, 2
    breq bahaya
    cpi r18, 1
    breq waspada
    ; Aman (hijau)
    sbi PORTD, 6      ; LED hijau ON
    cbi PORTD, 7      ; LED kuning OFF
    cbi PORTB, 0      ; LED merah OFF
    cbi PORTB, 1      ; Buzzer OFF
    rjmp selesai
waspada:
    cbi PORTD, 6      ; LED hijau OFF
    sbi PORTD, 7      ; LED kuning ON
    cbi PORTB, 0      ; LED merah OFF
    cbi PORTB, 1      ; Buzzer OFF
    rjmp selesai
bahaya:
    cbi PORTD, 6      ; LED hijau OFF
    cbi PORTD, 7      ; LED kuning OFF
    sbi PORTB, 0      ; LED merah ON

    lds r19, buzzer_off_flag
    cpi r19, 1
    breq buzzer_mati
    sbi PORTB, 1      ; Buzzer ON
    rjmp selesai
buzzer_mati:
    cbi PORTB, 1      ; Buzzer OFF
    rjmp selesai

selesai:
    pop r19
    pop r18
    pop r17
    pop r16
    ret

reset_alarm_flag:
    ldi r20, 0
    sts buzzer_off_flag, r20 ; Reset flag agar buzzer bisa nyala lagi jika bahaya berikutnya
    cbi PORTB, 1             ; Buzzer OFF
    ret