; ===================================================================
; File: display.S
; Deskripsi: File ini berisi fungsi untuk menangani tampilan LCD.
; Implementasi sebenarnya dilakukan di interrupt.ino melalui fungsi
; tampilkan_lcd dalam C++.
; ===================================================================

#define __SFR_OFFSET 0x00
#include "avr/io.h"

.section .text
; Mengekspor fungsi display_lcd agar dapat dipanggil dari file lain
.global display_lcd

display_lcd:
    ; Fungsi ini saat ini hanya berisi placeholder
    ; Implementasi sebenarnya ada di interrupt.ino
    ret  ; Kembali ke pemanggil fungsi