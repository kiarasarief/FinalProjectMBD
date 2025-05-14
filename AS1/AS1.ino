#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <DHT.h>

// Inisialisasi LCD I2C
LiquidCrystal_I2C lcd(0x27, 16, 2); 

// Inisialisasi DHT11
#define DHT11_PIN 13
DHT dht(DHT11_PIN, DHT11);

void setup() {
  // Inisialisasi LCD dan DHT11
  lcd.begin(16, 2);
  lcd.backlight();
  dht.begin();
}

void loop() {
  float temp = dht.readTemperature();
  float hum = dht.readHumidity();

  lcd.clear();
  lcd.setCursor(0, 0); 
  lcd.print("Temp: ");
  lcd.print(temp);
  lcd.print(" C");

  lcd.setCursor(0, 1);
  lcd.print("Hum : ");
  lcd.print(hum);
  lcd.print(" %");

  delay(1000);
}
