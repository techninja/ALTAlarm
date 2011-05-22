/* Arduino Laser Tripwire Alarm (ALTAlarm) by Super Awesome Sylvia
 * and TechNinja for Bay Area Maker Faire 2011.
 * Project homepage @ http://sylviashow.com/tripwire
 * 
 * Inspired by action_owl's instructable
 * http://www.instructables.com/id/Twittering-Laser-Tripwire-with-Webcam-Capture/
 *
 * Includes modified car alarm sound code by Machine Science
 * http://machinescience.wordpress.com/2009/12/17/making-sounds-with-arduino-and-the-iomodule/
 *
 */



// Pin Contants =================--------------------------
  const int laserPin = 13;       // Laser output on standard LED pin with resistor
  const int infraredLEDPin = 0;  // Analog input pin that reads the infrared LED's voltage
  const int speakerPin = 10;     // Speaker positive output pin


// Setup Contants =================-------------------------

  // Values read from the LED (changes depending on the laser, and the LED). Adjust this according
  // to a high value the LED is guaranteed to not be without the laser, and to be ABOVE with the laser.  
  const int alarmThreshold = 95;

  // The number of seconds the LED must read above the threshold to be considered armed
  const int calibrationTime = 5;


// Loop Variables =================--------------------------
  int sensorValue = 0;            // Value read from the LED
  boolean isCalibrated = false;   // Switch for whether the alarm is calibrated yet
  int secsCalibrated = 0;         // Counter for evaluation calibration


void setup() {
   Serial.begin(9600);  // Turn on serial output (for realtime viewing)
   digitalWrite(laserPin, HIGH); // Turn the laser ON!
   
   // Clear first value (tends to read incorrectly)
   sensorValue = analogRead(infraredLEDPin);
   delay(100);
 }

void loop() {
  sensorValue = analogRead(infraredLEDPin); // Grab the LED value
  
  if (!isCalibrated){ // If not yet calibrated

    if (sensorValue > alarmThreshold){ // If Laser is on LED
      secsCalibrated++; // Add 1 to the number of calibration counter
      beep(speakerPin, 500 + (secsCalibrated * 100), 200); // Beep at an increasing frequency
    }else{ // Below threshold, laser NOT on LED
      if (secsCalibrated > 0){ // If we were ever calibrated, sad beep!
        calibrationFailBeep();
      }
      secsCalibrated = 0; // Restart the counter timer
    }

    // Report the sensor value and amount calibrated 
    Serial.print("sensor = ");
    Serial.print(sensorValue);
    Serial.print(", secs calibrated = ");
    Serial.print(secsCalibrated);
    Serial.print("\n");

    // If seconds calibrated matches the calibration time, we're calibrated!
    if (secsCalibrated == calibrationTime){
      isCalibrated = true;
      calibrationBeep();
      Serial.println("Laser Tripwire Armed!");
    }

    // Wait 1 second between each calibration check
    delay(1000);
    
  }else{
    // Wait 1/100 of a second for each check when armed
    delay(10);

    // If the LED value dips below the threshold (laser can't be seen), it's been tripped!
    if (sensorValue < alarmThreshold) {
      digitalWrite(laserPin, LOW);
      Serial.println("Intruder Detected!!");
      alarm();
      digitalWrite(laserPin, HIGH);
      delay(1000);
    }
  }
   
}

// Function for handling the calibration failure beep 
void calibrationFailBeep(){
   beep(speakerPin, 200, 500);
   delay(100);
   beep(speakerPin, 200, 500);
}

// Function for handling the calibration success beep
void calibrationBeep(){
  beep(speakerPin, 1800, 200); delay(100); beep(speakerPin, 1800, 200);
  delay(500);
  beep(speakerPin, 1800, 200); delay(100); beep(speakerPin, 1800, 200);
}

// Wrapper function for tone() to include delay
void beep(int pin, int hz, int ms){
  tone(pin, hz);
  delay(ms);
  noTone(pin);
}


// Annoying alarm sound (by machine science)
void alarm() {
  char y;
  unsigned int i;
  for (y = 0; y < 7; y++) {
    for (y = 0; y < 7; y++) {
     for (i = 250; i < 800; i++)
       tone(speakerPin, i);
       for (i = 800; i > 250; i--)
       tone(speakerPin, i);
     }
    
     for (y = 0; y < 7; y++) {
       tone(speakerPin, 250);
       delay(400);
       tone(speakerPin, 0);
       delay(300);
     }
     for (y = 0; y < 7; y++) {
       for (i = 250; i < 700; i += 5) {
         tone(speakerPin, i);
         delay(10);
       }
       noTone(speakerPin);
       delay(300);
     }
     for (y = 0; y < 7; y++) {
       tone(speakerPin, 800);
       delay(400);
       tone(speakerPin, 250);
       delay(400);
     }
  }
  noTone(speakerPin);
}

