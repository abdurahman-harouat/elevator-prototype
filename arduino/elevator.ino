// motor pins
#define motorPin1 2
#define motorPin2 3

// sensors pins
#define sensor6Pin 4
#define sensor5Pin 5
#define sensor4Pin 6
#define sensor3Pin 7
#define sensor2Pin 8
#define sensor1Pin 9

// M74HC595B1
#define DS_PIN 10     // data pin
#define ORCLK_PIN 11  // output register clock
#define SRCLK_PIN 12  // shift register clock

// 7 segment digits table
int digits[10][8]{
  //{dp,a,b,c,d,e,f,g}
  { 0, 0, 1, 1, 0, 0, 0, 0 },  // digit 1
  { 0, 1, 1, 0, 1, 1, 0, 1 },  // digit 2
  { 0, 1, 1, 1, 1, 0, 0, 1 },  // digit 3
  { 0, 0, 1, 1, 0, 0, 1, 1 },  // digit 4
  { 0, 1, 0, 1, 1, 0, 1, 1 },  // digit 5
  { 0, 1, 0, 1, 1, 1, 1, 1 },  // digit 6
};

// #define pb0 8
// #define pb1 9
// #define pb2 10
// #define pb3 11

// preparing sensor states
int sensor6State, sensor5State, sensor4State, sensor3State, sensor2State, sensor1State;

void setup() {

  // pin modes
  pinMode(DS_PIN, OUTPUT);
  pinMode(ORCLK_PIN, OUTPUT);
  pinMode(SRCLK_PIN, OUTPUT);

  pinMode(motorPin1, OUTPUT);
  pinMode(motorPin2, OUTPUT);

  pinMode(sensor1Pin, INPUT);
  pinMode(sensor2Pin, INPUT);
  pinMode(sensor3Pin, INPUT);
  pinMode(sensor4Pin, INPUT);
  pinMode(sensor5Pin, INPUT);
  pinMode(sensor6Pin, INPUT);

  // pinMode(pb0, INPUT);
  // pinMode(pb1, INPUT);
  // pinMode(pb2, INPUT);
  // pinMode(pb3, INPUT);

  // start serial communication
  Serial.begin(9600);
}
// display digit function
void DisplayDigit(int Digit) {
  digitalWrite(ORCLK_PIN, LOW);
  for (int i = 7; i >= 0; i--) {
    digitalWrite(SRCLK_PIN, LOW);
    if (digits[Digit][i] == 1) digitalWrite(DS_PIN, LOW);
    if (digits[Digit][i] == 0) digitalWrite(DS_PIN, HIGH);
    digitalWrite(SRCLK_PIN, HIGH);
  }
  digitalWrite(ORCLK_PIN, HIGH);
}

// goes up function
void goesUP() {
  digitalWrite(motorPin1, LOW);
  digitalWrite(motorPin2, HIGH);
}

// goes down functtion
void goesDOWN() {
  digitalWrite(motorPin1, HIGH);
  digitalWrite(motorPin2, LOW);
}

// Stop elevator
void stopELEVATOR() {
  digitalWrite(motorPin1, LOW);
  digitalWrite(motorPin2, LOW);
}
void loop() {
  // getting the initial state of sensors
  sensor1State = digitalRead(sensor1Pin);
  sensor2State = digitalRead(sensor2Pin);
  sensor3State = digitalRead(sensor3Pin);
  sensor4State = digitalRead(sensor4Pin);
  sensor5State = digitalRead(sensor5Pin);
  sensor6State = digitalRead(sensor6Pin);

  // buttons logic
  // if (digitalRead(pb0) == 0) {
  //   // Move to the first floor
  //   while (sensor1State == HIGH) {
  //     sensor1State = digitalRead(sensor1Pin);
  //     goesDOWN();
  //   }
  //   // elevator stops
  //   stopELEVATOR();
  // } else if (digitalRead(pb1) == 0) {
  //   // Move to the second floor
  //   while (sensor2State == HIGH) {
  //     sensor2State = digitalRead(sensor2Pin);
  //     if (sensor1State == LOW) {
  //       goesUP();
  //     } else {
  //       goesDOWN();
  //     }
  //   }
  //   stopELEVATOR();
  // } else if (digitalRead(pb2) == 0) {
  //   // Move to the third floor
  //   while (sensor3State == HIGH) {
  //     sensor3State = digitalRead(sensor3Pin);
  //     if (sensor1State == LOW || sensor2State == LOW) {
  //       goesUP();
  //     } else {
  //       goesDOWN();
  //     }
  //   }
  //   stopELEVATOR();
  // } else if (digitalRead(pb3) == 0) {
  //   // Move to the fourth floor
  //   while (sensor4State == HIGH) {
  //     sensor4State = digitalRead(sensor4Pin);
  //     goesUP();
  //   }
  //   stopELEVATOR();
  // }

  // Read commands from Bluetooth HC-05
  if (Serial.available() > 0) {
    int command = Serial.read();
    if (command == '1') {
      // Move to the first floor
      while (sensor1State == HIGH) {
        sensor1State = digitalRead(sensor1Pin);
        goesDOWN();
      }
      // elevator stops
      stopELEVATOR();
    } else if (command == '2') {
      // Move to the second floor
      while (sensor2State == HIGH) {
        sensor2State = digitalRead(sensor2Pin);
        if (sensor1State == LOW) {
          goesUP();
        } else {
          goesDOWN();
        }
      }
      stopELEVATOR();
    } else if (command == '3') {
      // Move to the third floor
      while (sensor3State == HIGH) {
        sensor3State = digitalRead(sensor3Pin);
        if (sensor1State == LOW || sensor2State == LOW) {
          goesUP();
        } else {
          goesDOWN();
        }
      }
      stopELEVATOR();
    } else if (command == '4') {
      // Move to the fourth floor
      while (sensor4State == HIGH) {
        sensor4State = digitalRead(sensor4Pin);
        if (sensor1State == LOW || sensor2State == LOW || sensor3State == LOW) {
          goesUP();
        } else {
          goesDOWN();
        }
      }
      stopELEVATOR();
    } else if (command == '5') {
      // Move to the fourth floor
      while (sensor5State == HIGH) {
        sensor5State = digitalRead(sensor5Pin);
        if (sensor1State == LOW || sensor2State == LOW || sensor3State == LOW || sensor4State == LOW) {
          goesUP();
        } else {
          goesDOWN();
        }
      }
      stopELEVATOR();
    } else if (command == '6') {
      // Move to the fourth floor
      while (sensor6State == HIGH) {
        sensor6State = digitalRead(sensor6Pin);
        goesUP();
      }
      stopELEVATOR();
    }
  }
  // 7-segment logic
  if (sensor1State == LOW) {
    DisplayDigit(1);
  } else if (sensor2State == LOW) {
    DisplayDigit(2);
  } else if (sensor3State == LOW) {
    DisplayDigit(3);
  } else if (sensor4State == LOW) {
    DisplayDigit(4);
  } else if (sensor5State == LOW) {
    DisplayDigit(5);
  } else if (sensor6State == LOW) {
    DisplayDigit(6);
  }
}
