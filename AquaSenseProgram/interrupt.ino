// ===================================================================
// File: interrupt.ino
// Deskripsi: File ini berisi fungsi interrupt untuk mengatur LED dan buzzer
// ===================================================================

#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <DHT.h>

LiquidCrystal_I2C lcd(0x27, 16, 2);

#define DHT11_PIN 13
DHT dht(DHT11_PIN, DHT11);

// Pin LED & buzzer
const int ledGreen = 6;
const int ledYellow = 7;
const int ledRed = 8;
const int buzzerPin = 9;
const int buttonPin = 2;

// Variabel global untuk assembly
extern "C" float suhu;
extern "C" float hum;
extern "C" uint8_t status_alarm;
extern "C" uint8_t buzzer_off_flag;  // flag untuk matikan buzzer via interrupt

extern "C" void io_init();
extern "C" void main_logic();

// Fungsi C untuk LCD
void tampilkan_lcd(float suhu, float hum, uint8_t status_alarm) {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("T:");
  lcd.print(suhu, 1);  // 1 angka di belakang koma
  lcd.print("C H:");
  lcd.print(hum, 1);  // 1 angka di belakang koma
  lcd.print("%");

  lcd.setCursor(0, 1);
  if (status_alarm == 2) lcd.print("BAHAYA!");
  else if (status_alarm == 1) lcd.print("WASPADA");
  else lcd.print("AMAN   ");
}

void acknowledgeAlarm() {
  buzzer_off_flag = 1;  // Hanya set flag, buzzer OFF, LED merah tetap ON
}

void setup() {
  lcd.begin(16, 2);
  lcd.backlight();
  dht.begin();
  io_init();

  pinMode(ledGreen, OUTPUT);
  pinMode(ledYellow, OUTPUT);
  pinMode(ledRed, OUTPUT);
  pinMode(buzzerPin, OUTPUT);
  pinMode(buttonPin, INPUT_PULLUP);

  attachInterrupt(digitalPinToInterrupt(buttonPin), acknowledgeAlarm, FALLING);

  digitalWrite(ledGreen, LOW);
  digitalWrite(ledYellow, LOW);
  digitalWrite(ledRed, LOW);
  digitalWrite(buzzerPin, LOW);

  buzzer_off_flag = 0;
}

void loop() {
  float t = dht.readTemperature();
  float h = dht.readHumidity();
  if (!isnan(t)) suhu = t;
  if (!isnan(h)) hum = h;

  // LOGIKA STATUS ALARM DI C++
  if (t > 30.0) status_alarm = 2;        // BAHAYA
  else if (t >= 25.0) status_alarm = 1;  // WASPADA
  else status_alarm = 0;                 // AMAN

  // RESET FLAG BUZZER JIKA TIDAK BAHAYA
  if (status_alarm != 2) buzzer_off_flag = 0;

  main_logic();

  tampilkan_lcd(suhu, hum, status_alarm);

  delay(1000);
}