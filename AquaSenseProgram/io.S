; ===================================================================
; File: io.S
; Deskripsi: Inisialisasi I/O dan fungsi untuk sensor DHT11
; ===================================================================

#define __SFR_OFFSET 0x00
#include "avr/io.h"

.section .text
.global io_init       ; Fungsi untuk inisialisasi pin I/O
.global read_dht11    ; Fungsi untuk membaca sensor DHT11 (placeholder)

; Fungsi inisialisasi I/O - mengatur pin sebagai output dan mematikan semua LED/buzzer
io_init:
    ; Konfigurasi pin sebagai output
    sbi DDRD, 6       ; LED hijau (pin D6) sebagai output
    sbi DDRD, 7       ; LED kuning (pin D7) sebagai output
    sbi DDRB, 0       ; LED merah (pin B0) sebagai output
    sbi DDRB, 1       ; Buzzer (pin B1) sebagai output

    ; Matikan semua LED dan buzzer (keadaan awal)
    cbi PORTD, 6      ; LED hijau OFF
    cbi PORTD, 7      ; LED kuning OFF
    cbi PORTB, 0      ; LED merah OFF
    cbi PORTB, 1      ; Buzzer OFF
    ret

; Fungsi pembacaan DHT11 (hanya placeholder, implementasi sebenarnya di C++)
read_dht11:
    ret