; ===================================================================
; File: logic.S
; Deskripsi: File ini berisi logika utama untuk mengendalikan LED dan buzzer
; berdasarkan status alarm yang ditentukan dari pembacaan sensor suhu.
; ===================================================================

#define __SFR_OFFSET 0x00
#include "avr/io.h"

.section .text
; Mengekspor fungsi main_logic agar dapat dipanggil dari file lain
.global main_logic
; Mengekspor fungsi reset_alarm_flag agar dapat dipanggil dari file lain
.global reset_alarm_flag

; Mengimpor variabel global dari file data.S
.extern status_alarm     ; Status alarm (0=Aman, 1=Waspada, 2=Bahaya)
.extern buzzer_off_flag  ; Flag untuk mematikan buzzer melalui tombol

main_logic:
    ; Menyimpan nilai register ke stack agar dapat dipulihkan setelah fungsi selesai
    push r16
    push r17
    push r18
    push r19

    ; Memanggil fungsi untuk membaca sensor DHT11
    rcall read_dht11

    ; Mengontrol LED dan buzzer berdasarkan status_alarm
    lds r18, status_alarm    ; Memuat nilai status_alarm ke register r18
    cpi r18, 2               ; Membandingkan status_alarm dengan 2 (BAHAYA)
    breq bahaya              ; Lompat ke label 'bahaya' jika status_alarm = 2
    cpi r18, 1               ; Membandingkan status_alarm dengan 1 (WASPADA)
    breq waspada             ; Lompat ke label 'waspada' jika status_alarm = 1
    ; Status Aman (0): Nyalakan LED hijau, matikan LED lainnya dan buzzer
    sbi PORTD, 6      ; LED hijau ON
    cbi PORTD, 7      ; LED kuning OFF
    cbi PORTB, 0      ; LED merah OFF
    cbi PORTB, 1      ; Buzzer OFF
    rjmp selesai      ; Lompat ke label 'selesai'

waspada:
    ; Status Waspada (1): Nyalakan LED kuning, matikan LED lainnya dan buzzer
    cbi PORTD, 6      ; LED hijau OFF
    sbi PORTD, 7      ; LED kuning ON
    cbi PORTB, 0      ; LED merah OFF
    cbi PORTB, 1      ; Buzzer OFF
    rjmp selesai      ; Lompat ke label 'selesai'

bahaya:
    ; Status Bahaya (2): Nyalakan LED merah, matikan LED lainnya
    cbi PORTD, 6      ; LED hijau OFF
    cbi PORTD, 7      ; LED kuning OFF
    sbi PORTB, 0      ; LED merah ON

    ; Memeriksa apakah buzzer harus dimatikan berdasarkan flag
    lds r19, buzzer_off_flag      ; Memuat nilai buzzer_off_flag ke register r19
    cpi r19, 1                   ; Membandingkan buzzer_off_flag dengan 1
    breq buzzer_mati             ; Jika flag=1, buzzer harus dimatikan
    sbi PORTB, 1      ; Buzzer ON    ; Nyalakan buzzer jika flag=0
    rjmp selesai                     ; Lompat ke label 'selesai'
buzzer_mati:
    cbi PORTB, 1      ; Buzzer OFF   ; Matikan buzzer jika flag=1
    rjmp selesai                     ; Lompat ke label 'selesai'

selesai:
    ; Memulihkan nilai register dari stack
    pop r19
    pop r18
    pop r17
    pop r16
    ret                              ; Kembali ke pemanggil fungsi

reset_alarm_flag:
    ; Fungsi untuk mengatur ulang flag buzzer ke 0
    ldi r20, 0                       ; Memuat nilai 0 ke register r20
    sts buzzer_off_flag, r20         ; Reset flag agar buzzer bisa nyala lagi jika bahaya berikutnya
    cbi PORTB, 1                     ; Matikan buzzer
    ret                              ; Kembali ke pemanggil fungsi