/****
 *  tom_smart_sole
 *  Based on healththromometer sketch example for nRF51822 based Bluefruit LE modules
 */

/*********************************************************************
 This is an example for our nRF51822 based Bluefruit LE modules

 Pick one up today in the adafruit shop!

 Adafruit invests time and resources providing this open source code,
 please support Adafruit and open-source hardware by purchasing
 products from Adafruit!

 MIT license, check LICENSE for more information
 All text above, and the splash screen below must be included in
 any redistribution
*********************************************************************/

/*
    Please note the long strings of data sent mean the *RTS* pin is
    required with UART to slow down data sent to the Bluefruit LE!  
*/

#include <CountUpDownTimer.h>

#include <Arduino.h>
#include <SPI.h>
#if not defined (_VARIANT_ARDUINO_DUE_X_) && not defined (_VARIANT_ARDUINO_ZERO_)
  #include <SoftwareSerial.h>
#endif

#include "Adafruit_BLE.h"
#include "Adafruit_BluefruitLE_SPI.h"
#include "Adafruit_BluefruitLE_UART.h"
#include "Adafruit_BLEGatt.h"
#include "Adafruit_BLEBattery.h"


#include "BluefruitConfig.h"

#include "IEEE11073float.h"
#define VBATPIN A9


//// Create the bluefruit object, either software serial...uncomment these lines
//
//SoftwareSerial bluefruitSS = SoftwareSerial(BLUEFRUIT_SWUART_TXD_PIN, BLUEFRUIT_SWUART_RXD_PIN);
//
//Adafruit_BluefruitLE_UART ble(bluefruitSS, BLUEFRUIT_UART_MODE_PIN,
//                      BLUEFRUIT_UART_CTS_PIN, BLUEFRUIT_UART_RTS_PIN);


//// ...or hardware serial, which does not need the RTS/CTS pins. Uncomment this line
// Adafruit_BluefruitLE_UART ble(BLUEFRUIT_HWSERIAL_NAME, BLUEFRUIT_UART_MODE_PIN);

///...hardware SPI, using SCK/MOSI/MISO hardware SPI pins and then user selected CS/IRQ/RST
    Adafruit_BluefruitLE_SPI ble(BLUEFRUIT_SPI_CS, BLUEFRUIT_SPI_IRQ, BLUEFRUIT_SPI_RST);

/// ...software SPI, using SCK/MOSI/MISO user-defined SPI pins and then user selected CS/IRQ/RST
//Adafruit_BluefruitLE_SPI ble(BLUEFRUIT_SPI_SCK, BLUEFRUIT_SPI_MISO,
//                             BLUEFRUIT_SPI_MOSI, BLUEFRUIT_SPI_CS,
//                             BLUEFRUIT_SPI_IRQ, BLUEFRUIT_SPI_RST);

    Adafruit_BLEGatt gatt(ble);
    Adafruit_BLEBattery battery(ble);

// A small helper
    void error(const __FlashStringHelper*err) {
      Serial.println(err);
      while (1);
    }

/* The service information */

CountUpDownTimer T(UP, HIGH); // Default precision is HIGH, but you can change it to also be LOW



int32_t htsServiceId;
int32_t htsMeasureCharId;

int threshold = 300;

int on_led = 10;
int ble_led=11;
int buzzer = 12;

uint16_t temp_16;

int temp = 0;

double temp_d=0.0;

uint8_t temp_measurement [5] = { bit(0) };

void buzzer_alarm1();

/**************************************************************************
*
*    @brief  Sets up the HW an the BLE module (this function is called
*            automatically on startup)
*
**************************************************************************/
void setup(void)
{
 // while (!Serial); // required for Flora & Micro
  //delay(500);

  pinMode(buzzer,OUTPUT);
  pinMode(on_led,OUTPUT);
  pinMode(ble_led, OUTPUT);

  digitalWrite(on_led,HIGH);
  T.SetStopTime(1,0,0); 
  T.StartTimer();

  boolean success;

  Serial.begin(115200);
  Serial.println(F("Adafruit Bluefruit Health Thermometer Example"));
  Serial.println(F("--------------------------------------------"));

  randomSeed(micros());

  /* Initialise the module */
  Serial.print(F("Initialising the Bluefruit LE module: "));

  if ( !ble.begin(VERBOSE_MODE) )
  {
    error(F("Couldn't find Bluefruit, make sure it's in CoMmanD mode & check wiring?"));
  }
  Serial.println( F("OK!") );

  /* Perform a factory reset to make sure everything is in a known state */
  Serial.println(F("Performing a factory reset: "));
  if (! ble.factoryReset() ){
   error(F("Couldn't factory reset"));
 }

  /* Disable command echo from Bluefruit */
 ble.echo(false);

 Serial.println("Requesting Bluefruit info:");
  /* Print Bluefruit information */
 ble.info();

  // this line is particularly required for Flora, but is a good idea
  // anyways for the super long lines ahead!
  // ble.setInterCharWriteDelay(5); // 5 ms

  /* Add the Heart Rate Service definition */
  /* Service ID should be 1 */
 Serial.println(F("Adding the Health Thermometer Service definition (UUID = 0x1809): "));
 htsServiceId = gatt.addService(0x1809);
 if (htsServiceId == 0) {
  error(F("Could not add Thermometer service"));
}

  /* Add the Temperature Measurement characteristic which is composed of
   * 1 byte flags + 4 float */
  /* Chars ID for Measurement should be 1 */
Serial.println(F("Adding the Temperature Measurement characteristic (UUID = 0x2A1C): "));
htsMeasureCharId = gatt.addCharacteristic(0x2A1C, GATT_CHARS_PROPERTIES_INDICATE, 5, 5, BLE_DATATYPE_BYTEARRAY);
if (htsMeasureCharId == 0) {
  error(F("Could not add Temperature characteristic"));
}

  /* Add the Health Thermometer Service to the advertising data (needed for Nordic apps to detect the service) */
Serial.print(F("Adding Health Thermometer Service UUID to the advertising payload: "));
uint8_t advdata[] { 0x02, 0x01, 0x06, 0x05, 0x02, 0x09, 0x18, 0x0a, 0x18 };
ble.setAdvData( advdata, sizeof(advdata) );

  /* Reset the device for the new service setting changes to take effect */
Serial.print(F("Performing a SW reset (service changes require a reset): "));
ble.reset();

Serial.println();

battery.begin(true);
}

/** Send randomized heart rate data continuously **/
void loop(void)
{

 ble_check();


 if (analogRead(A0)>=threshold){
  time_count();
}
battery_check();

Serial.print(analogRead(A0));

/*

  temp_d= (double) temp;
  Serial.print("Value:");
  Serial.println(temp_d);
  
  //float2IEEE11073(temp_d, temp_measurement+1);
//temp_measurement[1]=0;  
temp_measurement[1]= temp_16 = (uint16_t)temp;
temp_measurement[2] = temp_16 >> 8;
 Serial.print("u 16:");
Serial.println(temp_measurement[1]);
 Serial.print("u cast:");
Serial.println(temp_measurement[2]);
Serial.println(temp_measurement[3]);
Serial.println(temp_measurement[4]);

  // TODO temperature is not correct due to Bluetooth use IEEE-11073 format
  gatt.setChar(htsMeasureCharId, temp_measurement, 5);
  // Delay before next measurement update 
*/


  delay(1000);
}

void battery_check(){

  float measuredvbat = analogRead(VBATPIN);
measuredvbat *= 2;    // we divided by 2, so multiply back
measuredvbat *= 3.3;  // Multiply by 3.3V, our reference voltage
measuredvbat /= 1024; // convert to voltage
ble.print("VBat: " );
ble.println(measuredvbat);

measuredvbat=measuredvbat*100.0;

int bat_precentage = (int) measuredvbat;
Serial.println(bat_precentage);
bat_precentage=map(bat_precentage,330,420,0,100);
bat_precentage=constrain(bat_precentage,0,100);

//ble.print("Bat: " );
//ble.print(bat_precentage);
 //ble.println("%");

battery.update(bat_precentage);

}

void ble_check(){

  if(! ble.isConnected()) digitalWrite(ble_led, LOW);
  else digitalWrite(ble_led, HIGH);

  
}

void time_count(){

  Serial.print("count 1 hr");

  long t=0;
  long count_sec = 0;
  long count_min =0;
  long count_hour = 0;
  long temp_long=0;
  bool cont_flag = false;
  long prev_count_sec=0;

  for(int i=0;i<5;i++){

    temp+=analogRead(A0);
    delay(20);
  }

  temp=temp/5;

  
  if(temp>=threshold){

    T.Timer();
    temp_long=temp;

    while(T.ShowHours()<1){ 

  //Serial.println(temp_d);
      cont_flag = true;

      while (cont_flag) {
        cont_flag = false;
        t=0;
        do{


          Serial.println(t);

          temp_long=0;
          for(int i=0;i<5;i++){

            temp_long+=analogRead(A0);
            delay(20);
            t=t+20;
          }

          temp_long=temp_long/5;

          if (temp_long > threshold) {
            Serial.println("TH");
            
            cont_flag = true;
          }
          
        }   
        while(t<1000*4);


        if (cont_flag) count_sec++; 

      }




      temp= (int) temp_long;   
      temp_d= (double) temp;
      Serial.print("Value:");
      Serial.println(temp_d);
      Serial.print("sec counter:");
      Serial.println(count_sec); 
      Serial.print("min counter:");
      Serial.println(count_min); 
//temp_measurement[1]= temp_16 = (uint16_t)temp;
//temp_measurement[2] = temp_16 >> 8;

//gatt.setChar(htsMeasureCharId, temp_measurement, 5);

      battery_check();
      
      if(prev_count_sec < count_sec){
        Serial.println("prev if");
        prev_count_sec=count_sec;
        if(count_sec>=5) {
          Serial.println("sec>15");

          count_min++;
          count_sec=0;
        }


      }
      if(count_min==1){


       temp_measurement[1]= temp_16 = (uint16_t)count_min;
//temp_measurement[2] = temp_16 >> 8;

       gatt.setChar(htsMeasureCharId, temp_measurement, 5);

       buzzer_alarm1();
       T.ResetTimer();
       return;
     }
  //else if(temp<threshold) return;

   }
   T.ResetTimer();
 }

} 




void buzzer_alarm1(){


  digitalWrite(buzzer,HIGH);
  delay(2000);

  digitalWrite(buzzer,LOW);


}
