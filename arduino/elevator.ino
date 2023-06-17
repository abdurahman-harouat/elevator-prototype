// Input shift register pins
#define SO 7
#define CLK 4
#define CLKI 6
#define LD 5

// 74hc595 shift pins
#define ser 2
#define latch 3

// Motor pins
#define motorpin1 9
#define motorpin2 8

// Store values from shift registers
byte shift[3];

// Sensor values
const byte sensor1 = B01111111;
const byte sensor2 = B10111111;
const byte sensor3 = B11011111;
const byte sensor4 = B11101111;
const byte sensor5 = B11110111;
const byte sensor6 = B11111011;

void setup() {
  Serial.begin(9600);

  // Pins configuration
  pinMode(CLK, OUTPUT);
  pinMode(CLKI, OUTPUT);
  pinMode(LD, OUTPUT);
  pinMode(SO, INPUT);
  pinMode(motorpin1, OUTPUT);
  pinMode(motorpin2, OUTPUT);

  pinMode(latch, OUTPUT);
  pinMode(ser, OUTPUT);
}

void stop() {
  digitalWrite(motorpin1, LOW);
  digitalWrite(motorpin2, LOW);
}

void down() {
  digitalWrite(motorpin1, LOW);
  digitalWrite(motorpin2, HIGH);
}

void up() {
  digitalWrite(motorpin1, HIGH);
  digitalWrite(motorpin2, LOW);
}

void shiftInRegisters() {
  digitalWrite(CLKI, HIGH);
  digitalWrite(LD, HIGH);
  delayMicroseconds(5);
  digitalWrite(LD, LOW);
  digitalWrite(LD, HIGH);
  digitalWrite(CLK, HIGH);
  digitalWrite(CLKI, LOW);
  shift[0] = shiftIn(SO, CLK, LSBFIRST);
  shift[1] = shiftIn(SO, CLK, LSBFIRST);
  shift[2] = shiftIn(SO, CLK, LSBFIRST);
}


void printShiftRegisters() {
  for (int k = 0; k < 3; k++) {
    for (int i = 0; i < 8; i++) {
      Serial.print(bitRead(shift[k], i));
    }
    Serial.print(',');
  }
  Serial.println();
}


//7 segment
void seg() {
  byte digit;
  if (shift[0] == sensor1) {
    digit = B11110010;  // digit 1
  } else if (shift[0] == sensor2) {
    digit = B01001000;  // digit 2
  } else if (shift[0] == sensor3) {
    digit = B01100000;  // digit 3
  } else if (shift[0] == sensor4) {
    digit = B00110011;  // digit 4
  } else if (shift[0] == sensor5) {
    digit = B00100100;  // digit 5
  } else if (shift[0] == sensor6) {
    digit = B00000100;  // digit 6
  } else {
    digit = B11111111;
  }

  digitalWrite(latch, LOW);
  shiftOut(ser, CLK, MSBFIRST, digit);
  digitalWrite(latch, HIGH);
}

void update() {
  shiftInRegisters();
  seg();
}

void loop() {
  update();
  printShiftRegisters();
  delay(100);

  // Check if button 1 is pressed
  if (shift[2] == B10000000 || shift[1] == B10000000) {
    // Move motor until sensor1 is activated

    if (shift[0] == sensor2 || shift[0] == sensor3 || shift[0] == sensor4 || shift[0] == sensor5 || shift[0] == sensor6) {
      while (1) {
        update();
        down();
        if (shift[0] == sensor1)
          break;
      }
    }
    stop();
  }

  // Check if button 2 is pressed
  else if (shift[2] == B01000000 || shift[1] == B01000000) {
    // going up()
    if (shift[0] == sensor1) {
      while (1) {
        update();
        up();
        if (shift[0] == sensor2)
          break;
      }
    }

    // going down
    else if (shift[0] == sensor3 || shift[0] == sensor4 || shift[0] == sensor5 || shift[0] == sensor6) {
      while (1) {
        update();
        down();
        if (shift[0] == sensor2)
          break;
      }
    }
    stop();
  }

  // Check if button 3 is pressed
  else if (shift[2] == B00100000 || shift[1] == B00100000) {
    // going up()
    if (shift[0] == sensor1 || shift[0] == sensor2) {
      while (1) {
        update();
        up();
        if (shift[0] == sensor3)
          break;
      }
    }

    // going down
    else if (shift[0] == sensor4 || shift[0] == sensor5 || shift[0] == sensor6) {
      while (1) {
        update();
        down();
        if (shift[0] == sensor3)
          break;
      }
    }
    stop();
  }

  // Check if button 4 is pressed
  else if (shift[2] == B00000100 || shift[1] == B00001000) {
    // Move motor until sensor4 is activated
    // going up()
    if (shift[0] == sensor1 || shift[0] == sensor2 || shift[0] == sensor3) {
      while (1) {
        update();
        up();
        if (shift[0] == sensor4)
          break;
      }
    }

    // going down
    else if (shift[0] == sensor5 || shift[0] == sensor6) {
      while (1) {
        update();
        down();
        if (shift[0] == sensor4)
          break;
      }
    }
    stop();
  }

  // Check if button 5 is pressed
  else if (shift[2] == B00000010 || shift[1] == B00000100) {
    // going up()
    if (shift[0] == sensor1 || shift[0] == sensor2 || shift[0] == sensor3 || shift[0] == sensor4) {
      while (1) {
        update();
        up();
        if (shift[0] == sensor5)
          break;
      }
    }

    // going down
    else if (shift[0] == sensor6) {
      while (1) {
        update();
        down();
        if (shift[0] == sensor5)
          break;
      }
    }
    stop();
  }


  // Check if button 6 is pressed
  else if (shift[2] == B00000001 || shift[1] == B00000010) {
    if (shift[0] == sensor2 || shift[0] == sensor3 || shift[0] == sensor4 || shift[0] == sensor5 || shift[0] == sensor1) {
    while (1) {
      update();
      up();
      if (shift[0] == sensor6)
        break;
    }
    }
    stop();
  }
  ///////////////////////////////////////////////////////////////////////////////////////

  // Read commands from Bluetooth HC-05
  if (Serial.available() > 0) {
    int command = Serial.read();
    if (command == '1') {
      while (shift[0] != sensor1) {
        update();
        down();
      }
      stop();
    }

    else if (command == '2') {
      // going up
      if (shift[0] == sensor1) {
        while (1) {
          update();
          up();
          if (shift[0] == sensor2)
            break;
        }
      }
      // going down
      else if (shift[0] == sensor3 || shift[0] == sensor4 || shift[0] == sensor5 || shift[0] == sensor6) {
        while (1) {
          update();
          down();
          if (shift[0] == sensor2)
            break;
        }
      }
      stop();
    }

    else if (command == '3') {
      // going up
      if (shift[0] == sensor1 || shift[0] == sensor2) {
        while (1) {
          update();
          up();
          if (shift[0] == sensor3)
            break;
        }
      }
      // going down
      else if (shift[0] == sensor4 || shift[0] == sensor5 || shift[0] == sensor6) {
        while (1) {
          update();
          down();
          if (shift[0] == sensor3)
            break;
        }
      }
      stop();
    }

    else if (command == '4') {
      // going up()
      if (shift[0] == sensor1 || shift[0] == sensor2 || shift[0] == sensor3) {
        while (1) {
          update();
          up();
          if (shift[0] == sensor4)
            break;
        }
      }
      // going down
      else if (shift[0] == sensor5 || shift[0] == sensor6) {
        while (1) {
          update();
          down();
          if (shift[0] == sensor4)
            break;
        }
      }
      stop();
    }

    else if (command == '5') {
      // going up()
      if (shift[0] == sensor1 || shift[0] == sensor2 || shift[0] == sensor3 || shift[0] == sensor4) {
        while (1) {
          update();
          up();
          if (shift[0] == sensor5)
            break;
        }
      }

      // going down
      else if (shift[0] == sensor6) {
        while (1) {
          update();
          down();
          if (shift[0] == sensor5)
            break;
        }
      }
      stop();
    }

    else if (command == '6') {
      while (1) {
        update();
        up();
        if (shift[0] == sensor6)
          break;
      }
      stop();
    }
  }
}
