; ========================================================================
; File: data.S
; Deskripsi: Deklarasi variabel global untuk pertukaran data antara Assembly dan C++
; ========================================================================

#define __SFR_OFFSET 0x00
#include "avr/io.h"

.section .data

; Ekspor variabel agar dapat diakses dari kode C++
.global suhu
.global hum
.global status_alarm
.global buzzer_off_flag
suhu: .float 0            ; Variabel untuk menyimpan nilai suhu (format float)
hum:  .float 0            ; Variabel untuk menyimpan nilai kelembaban (format float)
status_alarm: .byte 1     ; Status alarm: 0=aman, 1=waspada, 2=bahaya
buzzer_off_flag: .byte 1  ; Flag untuk mematikan buzzer: 0=buzzer aktif, 1=buzzer mati