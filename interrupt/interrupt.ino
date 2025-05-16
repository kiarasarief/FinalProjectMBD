// Update Interrupt

#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <DHT.h>

LiquidCrystal_I2C lcd(0x27, 16, 2);

#define DHT11_PIN 13
DHT dht(DHT11_PIN, DHT11);

// Pin LED
const int ledGreen = 6;
const int ledYellow = 7;
const int ledRed = 8;

// Pin buzzer
const int buzzerPin = 9;

// Tombol interrupt
const int buttonPin = 2;

// Flag untuk alarm
volatile bool alarmActive = false;

void acknowledgeAlarm() {
  alarmActive = false; // reset alarm saat tombol ditekan
  digitalWrite(buzzerPin, LOW);
  digitalWrite(ledRed, LOW);
}

void setup() {
  lcd.begin(16, 2);
  lcd.backlight();
  dht.begin();

  // Setup pin output
  pinMode(ledGreen, OUTPUT);
  pinMode(ledYellow, OUTPUT);
  pinMode(ledRed, OUTPUT);
  pinMode(buzzerPin, OUTPUT);
  
  // Setup tombol interrupt
  pinMode(buttonPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(buttonPin), acknowledgeAlarm, FALLING);

  // Matikan semua indikator awalnya
  digitalWrite(ledGreen, LOW);
  digitalWrite(ledYellow, LOW);
  digitalWrite(ledRed, LOW);
  digitalWrite(buzzerPin, LOW);
}

void loop() {
  // Baca sensor (simulasi untuk alarm)
  float temp = dht.readTemperature();
  float hum = dht.readHumidity();

  // Display (bisa kamu ganti dengan assembly nanti)
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Temp: ");
  lcd.print(temp);
  lcd.print(" C");

  lcd.setCursor(0, 1);
  lcd.print("Hum : ");
  lcd.print(hum);
  lcd.print(" %");

  // Logika alarm sederhana (misal suhu > 30 = bahaya)
  if (temp > 30) {
    alarmActive = true;
  }

  // Set indikator LED dan buzzer sesuai alarm
  if (alarmActive) {
    digitalWrite(ledRed, HIGH);
    digitalWrite(buzzerPin, HIGH);
    digitalWrite(ledGreen, LOW);
    digitalWrite(ledYellow, LOW);
  } else if (temp > 25) {
    digitalWrite(ledYellow, HIGH);
    digitalWrite(ledGreen, LOW);
    digitalWrite(ledRed, LOW);
    digitalWrite(buzzerPin, LOW);
  } else {
    digitalWrite(ledGreen, HIGH);
    digitalWrite(ledYellow, LOW);
    digitalWrite(ledRed, LOW);
    digitalWrite(buzzerPin, LOW);
  }

  delay(1000);
}
