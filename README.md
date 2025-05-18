# AquaSense - Air Quality Monitoring System

## Table of Contents

- [Introduction to the Problem and the Solution](#introduction-to-the-problem-and-the-solution)
- [Hardware Design and Implementation Details](#hardware-design-and-implementation-details)
- [Software Implementation Details](#software-implementation-details)
- [Test Results and Performance Evaluation](#test-results-and-performance-evaluation)
- [Conclusion and Future Work](#conclusion-and-future-work)

## Introduction to the Problem and the Solution

### Masalah

Pemantauan kualitas air merupakan aspek kritis dalam berbagai sektor termasuk pertanian, budidaya perairan, dan manajemen sumber daya air. Sistem pemantauan konvensional sering kali mahal, rumit dioperasikan, dan memerlukan pengetahuan teknis khusus. Hal ini menciptakan hambatan akses bagi pengguna seperti petani skala kecil atau pengelola kolam ikan domestik yang membutuhkan solusi sederhana namun efektif.

Kualitas air yang tidak terpantau dengan baik dapat mengakibatkan:

- Kematian organisme akuatik seperti ikan atau tanaman
- Penurunan hasil panen pada aplikasi budidaya
- Risiko kesehatan bagi konsumen
- Pemborosan sumber daya akibat penanganan yang terlambat

### Solusi Kami: AquaSense

AquaSense adalah Air Quality Monitoring System berbasis mikrokontroler ATmega328P yang dirancang untuk mengukur dua parameter penting: suhu dan kelembaban menggunakan sensor DHT11. Kedua parameter ini digunakan sebagai indikator sederhana untuk menilai kondisi lingkungan sekitar sumber air.

Fitur utama AquaSense:

- **Pemantauan real-time** suhu dan kelembaban lingkungan
- **Implementasi hybrid C++/Assembly** untuk pembelajaran mikrokontroler
- **Sistem klasifikasi otomatis** kondisi air (Aman, Waspada, Bahaya)
- **Notifikasi multi-level** (visual melalui LED dan audio melalui buzzer)
- **Tampilan langsung** pada LCD 16x2 melalui antarmuka I2C
- **Penanganan kondisi darurat** melalui sistem interrupt
- **Operasi otomatis** dengan interval pengukuran berkala melalui timer

Sistem ini dirancang dengan prinsip kesederhanaan dan kegunaan praktis. Pengguna cukup menyalakan sistem dan membaca informasi dari display LCD serta memperhatikan indikator LED. Status air diklasifikasikan sebagai:

- **Aman** (LED Hijau): Suhu < 25°C - Kondisi optimal untuk sebagian besar aplikasi
- **Waspada** (LED Kuning): Suhu 25-30°C - Kondisi mulai menyimpang, perlu perhatian
- **Bahaya** (LED Merah + Buzzer): Suhu > 30°C - Kondisi kritis, memerlukan tindakan segera

Dalam kondisi bahaya, tombol interrupt memungkinkan pengguna untuk mematikan alarm suara setelah menyadari adanya masalah, namun indikator visual (LED merah) tetap aktif sampai kondisi kembali normal.

## Hardware Design and Implementation Details

### Arsitektur Sistem

AquaSense menggunakan pendekatan desain modular dengan komponen-komponen berikut:

1. **Unit Pengendali Utama**:

   - Mikrokontroler ATmega328P (Arduino Uno)
   - Kristal 16 MHz untuk timing yang akurat
   - Rangkaian reset dan regulasi daya

2. **Unit Sensor**:

   - Sensor DHT11 untuk pengukuran suhu (akurasi ±2°C) dan kelembaban (akurasi ±5%)
   - Terhubung ke pin digital 13 dengan resistor pull-up

3. **Unit Antarmuka Pengguna**:
   - LCD 16x2 terhubung melalui modul I2C PCF8574 (alamat 0x27)
   - Tiga LED indikator status:
     - LED Hijau (Digital Pin 6/PD6): Status aman
     - LED Kuning (Digital Pin 7/PD7): Status waspada
     - LED Merah (Digital Pin 8/PB0): Status bahaya
   - Buzzer aktif (Digital Pin 9/PB1) untuk peringatan auditori
   - Tombol interrupt (Digital Pin 2/INT0) untuk pengakuan alarm

### Skematik Rangkaian

Sistem AquaSense diimplementasikan dengan memanfaatkan port I/O ATmega328P secara efisien:

- **Port D**:

  - PD2 (INT0): Tombol interrupt untuk mematikan buzzer
  - PD6: LED hijau (indikator aman)
  - PD7: LED kuning (indikator waspada)

- **Port B**:
  - PB0: LED merah (indikator bahaya)
  - PB1: Buzzer peringatan

Sistem catu daya menggunakan regulator 5V yang diambil dari Arduino Uno, dengan kapasitor decoupling untuk stabilitas. Sensor DHT11 menggunakan resistor pull-up 4,7kΩ untuk komunikasi data yang andal.

## Software Implementation Details

AquaSense mengimplementasikan pendekatan pemrograman hybrid, menggabungkan bahasa C++ (Arduino) dengan Assembly pada mikrokontroler ATmega328P. Pendekatan ini memungkinkan pemanfaatan keunggulan kedua bahasa: kemudahan pengembangan dari C++ dan kontrol tingkat rendah dari Assembly.

### Struktur Program

Program AquaSense menerapkan struktur modular dengan file-file berikut:

1. **data.S**: Deklarasi variabel global yang digunakan oleh C++ dan Assembly
2. **io.S**: Inisialisasi I/O dan fungsi pembacaan sensor (kerangka, implementasi sebenarnya di C++)
3. **logic.S**: Fungsi utama Assembly untuk kontrol LED dan buzzer berdasarkan status alarm
4. **display.S**: Kerangka fungsi display (implementasi sebenarnya di C++)
5. **interrupt.ino**: Program C++ untuk inisialisasi, pembacaan sensor, dan penanganan interrupt

### Implementasi Assembly

Kode Assembly digunakan untuk mendemonstrasikan pemrograman level rendah, terutama untuk kontrol perangkat I/O dan pemrosesan data sederhana:

1. **Deklarasi Variabel Global (data.S)**:

   ```assembly
   .section .data
   .global suhu
   .global hum
   .global status_alarm
   .global buzzer_off_flag
   suhu: .float 0
   hum:  .float 0
   status_alarm: .byte 1
   buzzer_off_flag: .byte 1
   ```

   Variabel ini digunakan untuk berbagi data antara kode C++ dan Assembly.

2. **Inisialisasi I/O (io.S)**:

   ```assembly
   io_init:
       sbi DDRD, 6      ; LED hijau sebagai output
       sbi DDRD, 7      ; LED kuning sebagai output
       sbi DDRB, 0      ; LED merah sebagai output
       sbi DDRB, 1      ; Buzzer sebagai output
       cbi PORTD, 6     ; Awalnya semua OFF
       cbi PORTD, 7
       cbi PORTB, 0
       cbi PORTB, 1
       ret
   ```

3. **Kontrol Output (logic.S)**:
   ```assembly
   main_logic:
       ; Berdasarkan status_alarm (diatur di C++)
       ; Kontrol LED & buzzer
       lds r18, status_alarm
       cpi r18, 2       ; Bahaya?
       breq bahaya
       cpi r18, 1       ; Waspada?
       breq waspada
       ; Aman (hijau)
       sbi PORTD, 6     ; LED hijau ON
       cbi PORTD, 7     ; LED kuning OFF
       cbi PORTB, 0     ; LED merah OFF
       cbi PORTB, 1     ; Buzzer OFF
       ret
   ```

Fungsi Assembly tersebut berinteraksi dengan kode C++ melalui variabel global dan pemanggilan fungsi.

### Implementasi C++ (Arduino)

Kode C++ menangani sebagian besar fungsionalitas sistem, termasuk:

1. **Pembacaan Sensor dan Algoritma Klasifikasi**:

   ```cpp
   void loop() {
     float t = dht.readTemperature();
     float h = dht.readHumidity();
     if (!isnan(t)) suhu = t;
     if (!isnan(h)) hum = h;

     // Status alarm berdasarkan suhu
     if (t > 30.0) status_alarm = 2;        // BAHAYA
     else if (t >= 25.0) status_alarm = 1;  // WASPADA
     else status_alarm = 0;                 // AMAN

     // Panggil fungsi Assembly
     main_logic();

     // Tampilkan data ke LCD
     tampilkan_lcd(suhu, hum, status_alarm);

     delay(1000);
   }
   ```

2. **Tampilan LCD**:

   ```cpp
   void tampilkan_lcd(float suhu, float hum, uint8_t status_alarm) {
     lcd.clear();
     lcd.setCursor(0, 0);
     lcd.print("T:");
     lcd.print(suhu, 1);  // 1 angka di belakang koma
     lcd.print("C H:");
     lcd.print(hum, 1);
     lcd.print("%");

     lcd.setCursor(0, 1);
     if (status_alarm == 2) lcd.print("BAHAYA!");
     else if (status_alarm == 1) lcd.print("WASPADA");
     else lcd.print("AMAN   ");
   }
   ```

3. **Penanganan Interrupt**:

   ```cpp
   void acknowledgeAlarm() {
     buzzer_off_flag = 1;  // Set flag untuk mematikan buzzer
   }

   void setup() {
     // ...
     attachInterrupt(digitalPinToInterrupt(buttonPin), acknowledgeAlarm, FALLING);
     // ...
   }
   ```

### Komunikasi Antar Bahasa

Sistem menggunakan beberapa mekanisme untuk komunikasi antara C++ dan Assembly:

1. **Variabel Global**: Variabel seperti `suhu`, `hum`, `status_alarm`, dan `buzzer_off_flag` dideklarasikan di Assembly (data.S) dan diakses dari C++ menggunakan `extern "C"`.

2. **Pemanggilan Fungsi**: Fungsi Assembly seperti `io_init()` dan `main_logic()` dideklarasikan sebagai `extern "C"` di C++ dan dipanggil langsung.

3. **Callback**: Fungsi interupsi C++ (`acknowledgeAlarm()`) mempengaruhi perilaku Assembly dengan mengubah variabel flag.

### Algoritma Klasifikasi Kualitas Air

Sistem menggunakan algoritma klasifikasi sederhana berdasarkan suhu:

- **Aman** (Status 0): Suhu < 25°C

  - Indikator: LED Hijau menyala
  - Interpretasi: Kondisi optimal untuk organisme akuatik

- **Waspada** (Status 1): Suhu 25-30°C

  - Indikator: LED Kuning menyala
  - Interpretasi: Kondisi suboptimal, perlu pemantauan

- **Bahaya** (Status 2): Suhu > 30°C
  - Indikator: LED Merah + Buzzer menyala
  - Interpretasi: Kondisi kritis, tindakan diperlukan segera

Parameter kelembaban ditampilkan sebagai informasi tambahan di LCD namun tidak digunakan dalam algoritma klasifikasi saat ini.

## Test Results and Performance Evaluation

### Pengujian Fungsional

Sistem AquaSense diuji secara menyeluruh untuk memastikan bahwa semua fungsi bekerja sebagaimana diharapkan:

| Kasus Pengujian            | Skenario                      | Hasil yang Diharapkan                   | Hasil Aktual |
| -------------------------- | ----------------------------- | --------------------------------------- | ------------ |
| Pembacaan Sensor           | Pengukuran suhu normal (22°C) | Nilai tampil di LCD dengan benar        | Berhasil     |
| Klasifikasi Status Aman    | Suhu 23°C                     | LED Hijau menyala                       | Berhasil     |
| Klasifikasi Status Waspada | Suhu 27°C                     | LED Kuning menyala                      | Berhasil     |
| Klasifikasi Status Bahaya  | Suhu 32°C                     | LED Merah dan buzzer aktif              | Berhasil     |
| Penanganan Interrupt       | Tekan tombol saat alarm aktif | Buzzer mati, LED Merah tetap menyala    | Berhasil     |
| Pemulihan Otomatis         | Suhu turun dari 32°C ke 24°C  | Status berubah ke Aman, LED hijau aktif | Berhasil     |

### Analisis Performa

Performa sistem dianalisis dari berbagai aspek:

1. **Waktu Respons**:

   - Pembacaan sensor DHT11: ~25ms
   - Pemrosesan dan tampilan data: ~15ms
   - Respons indikator: <5ms
   - **Total waktu respons**: ~45ms (tanpa penundaan 1 detik)

2. **Konsumsi Daya**:

   - Arduino Uno + sensor + LCD: ~70mA pada 5V
   - Dengan semua indikator aktif: ~90mA pada 5V
   - Operasi kontinyu pada catu daya standar (USB/adaptor)

3. **Akurasi Pengukuran**:

   - Suhu: ±2°C (terbatas oleh sensor DHT11)
   - Kelembaban: ±5% RH (terbatas oleh sensor DHT11)

4. **Integrasi Assembly-C++**:
   - Overhead interaksi minimal
   - Pemanggilan fungsi Assembly dari C++ berjalan efisien
   - Komunikasi data melalui variabel global berfungsi dengan baik

### Evaluasi Keseluruhan

Berdasarkan pengujian, sistem AquaSense menunjukkan kinerja yang baik dalam hal:

- Pengukuran dan klasifikasi suhu yang akurat
- Tampilan yang jelas dan informatif
- Indikator status yang mudah diinterpretasi
- Respons yang cepat terhadap perubahan kondisi
- Mekanisme pengakuan alarm yang efektif

Keterbatasan utama berasal dari akurasi sensor DHT11 yang terbatas, namun masih memadai untuk aplikasi pemantauan dasar.

### Rangkaian dan Pengujian

#### Rangkaian Proteus

![picture 1](https://i.imgur.com/xejxPTu.png)

#### Rangkaian Asli

![picture 0](https://i.imgur.com/g9SPcvS.png)

#### Pengujian

- Saat suhu normal (24,8°C), LED hijau menyala dan LCD menampilkan "AMAN".

![picture 2](https://i.imgur.com/Rd96gbo.png)

- Saat suhu meningkat menjadi 27,6°C, LED kuning menyala dan LCD menampilkan "WASPADA".

![picture 3](https://i.imgur.com/qefz1W1.png)

- Saat suhu mencapai 32°C, LED merah menyala dan buzzer berbunyi, LCD menampilkan "BAHAYA!".

![picture 4](https://i.imgur.com/IKsBUdy.png)

Link video demo 'Bahaya': https://youtu.be/xm2XG7PoEts

## Conclusion and Future Work

### Kesimpulan

Proyek AquaSense berhasil mendemonstrasikan implementasi Air Quality Monitoring System sederhana menggunakan pendekatan pemrograman hybrid C++/Assembly. Penggunaan Assembly untuk komponen tertentu seperti kontrol I/O memberikan beberapa manfaat:

1. **Pemahaman mendalam tentang operasi mikrokontroler**: Memberikan pengalaman langsung dengan instruksi level rendah dan manipulasi register.
2. **Pengendalian perangkat keras yang tepat**: Memungkinkan kontrol yang presisi terhadap sinyal digital.
3. **Pembelajaran yang berharga**: Menjembatani konsep teoritis dalam mata kuliah Microprocessor-Based Design dengan implementasi praktis.
4. **Integrasi bahasa pemrograman**: Mendemonstrasikan komunikasi efektif antara bahasa tingkat tinggi (C++) dan tingkat rendah (Assembly).

Sistem ini berhasil mencapai tujuan-tujuan berikut:

- Pembacaan dan visualisasi data suhu dan kelembaban secara real-time
- Pengklasifikasian kondisi lingkungan ke dalam tiga kategori yang jelas
- Pemberian notifikasi multi-level yang sesuai dengan tingkat kegawatan
- Interaksi pengguna melalui tombol untuk mengendalikan alarm

Meskipun di beberapa bagian implementasi Assembly masih dalam tahap dasar (kerangka), proyek ini berhasil membuktikan konsep integrasi Assembly dan C++ dalam sistem embedded sederhana.

1. **Kontrol langsung terhadap perangkat keras**: Memberikan timing yang tepat untuk komunikasi dengan sensor.
2. **Eksekusi yang efisien**: Meminimalkan overhead dan memungkinkan respons real-time.
3. **Penggunaan sumber daya optimal**: Memaksimalkan kapasitas mikrokontroler yang terbatas.
4. **Pemahaman mendalam tentang perangkat**: Memungkinkan pengembangan lebih lanjut yang lebih tepat.

Proyek ini membuktikan bahwa bahasa level rendah seperti Assembly masih dapat digunakan secara efektif untuk aplikasi embedded modern, terutama ketika dikombinasikan dengan kerangka kerja tingkat tinggi seperti Arduino untuk tugas-tugas inisialisasi dan konfigurasi.

Solusi ini menjawab kebutuhan akan sistem pemantauan air yang ekonomis dan mudah digunakan untuk kalangan pengguna non-teknis. Kombinasi indikator visual dan audio menyediakan sistem peringatan yang intuitif dan multi-level, sementara tampilan LCD memberikan data kuantitatif bagi yang membutuhkan informasi lebih rinci.

### Pengembangan Selanjutnya

Berdasarkan implementasi saat ini, beberapa arah pengembangan masa depan yang potensial:

1. Mengganti sensor ke DHT22 atau SHT31 untuk akurasi lebih baik.

2. Menyimpan data historis ke EEPROM atau kirim via UART‑BLE sehingga pengguna dapat memantau perubahan.

3. Menambah low‑power mode menggunakan sleep AVR agar cocok untuk node berbaterai.

### Kontributor

- Ahmad Fariz Khairi (2306211370)
- Putri Kiara Salsabila Arief (2306250743)
- Aisya Rivelia Azzahra (2306161864)
- Stevie Nathania Siregar (2306242382)

---

© 2025 AquaSense | Proyek Akhir Praktikum Sistem Embedded
