
const int stepsPerRevolution = 4096; //  steps per shaft revolution for the 28BYJ-48 in half-step mode
const float distancePerRevolution = 35; // 35mm
const float distancePerStep = 0.0085; // mm's
const int maxHeight = 130; // 130mm 

const int stepCount = 8; // 8 steps per motor revolution 
// 1 turns a coil on, 0 turns it off.
const int stepSequence[8][4] = {
  {1, 0, 0, 0}, // Step 1
  {1, 1, 0, 0}, // Step 2
  {0, 1, 0, 0}, // Step 3
  {0, 1, 1, 0}, // Step 4
  {0, 0, 1, 0}, // Step 5
  {0, 0, 1, 1}, // Step 6
  {0, 0, 0, 1}, // Step 7
  {1, 0, 0, 1}  // Step 8
};  
const int maxElevation = 3000; // max elevation in meters
const int minElevation = 2000; // min elevation in meters


int elevations[10] = {0,0,0,0,0,0,0,0,0,0}; // elevations from the MacOS app
int positions[10] = {0,0,0,0,0,0,0,0,0,0}; // Converted to mm's with my scale

class Rod {
  public:
    // Default constructor
    Rod() : current_pos(0), target_pos(0), IN1(0), IN2(0), IN3(0), IN4(0) {}

    // Constructor to initialize a rod. P1-P4 are the chosen pins on the arduino. start_pos should probably be 0.
    Rod(float start_pos, int P1, int P2, int P3, int P4) {
      current_pos = start_pos;
      target_pos = 0;
      IN1 = P1;
      IN2 = P2;
      IN3 = P3;
      IN4 = P4;
    }

    

    // Go to the maximum rod height
    void go_to_max() {
      target_pos = maxHeight; 
      int steps = steps_from_target();
      int direction = direction_from_target();
      stepMotor(steps, direction);

    }
    // Go to the minimum rod height;
    void go_to_zero() {
      target_pos = 0;
      int steps = steps_from_target();
      stepMotor(steps, -1);

    }
    // Go to a specified position in mm's
    void go_to_position(int pos) {
      target_pos = pos;
      int steps = steps_from_target();
      int direction = direction_from_target();
      stepMotor(steps, direction);
    }

  private: 
    float current_pos; // The current position in mm's 
    float target_pos; // The target position in mm's 
    int IN1;
    int IN2;
    int IN3;
    int IN4; 

    void stepMotor(int steps, int direction) {
      for (int i = 0; i < steps; i++) {
        int stepIndex;
        if (direction > 0) {
          stepIndex = i % stepCount;
        } else {
          stepIndex = (stepCount - (i % stepCount) - 1) % stepCount;
        }

        // Set the coils based on the step sequence
        digitalWrite(IN1, stepSequence[stepIndex][0]);
        digitalWrite(IN2, stepSequence[stepIndex][1]);
        digitalWrite(IN3, stepSequence[stepIndex][2]);
        digitalWrite(IN4, stepSequence[stepIndex][3]);

        // Delay between steps (adjust for speed)
        delay(1); 
      }

      // De-energize the coils after movement
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, LOW);
      digitalWrite(IN3, LOW);
      digitalWrite(IN4, LOW);

      current_pos = target_pos; // Equalize after motor is done.
    }

    // Return the number of steps the motor should spin
    int steps_from_target() {
      float distance = abs(current_pos - target_pos); 
      return round(distance / distancePerStep);
    }

    // Return the direction the motor should spin
    int direction_from_target() {
      if (target_pos > current_pos) {
        return 1;
      } else {
        return -1;
      }
    }

};
const int numRods = 10; // How many rods I have
Rod rods[numRods]; // initialize the list of rods because C++ sucks. 

void initializeRods() {
    rods[0] = Rod(0, 2, 3, 4, 5);
    rods[1] = Rod(0, 6, 7, 8, 9);
    rods[2] = Rod(0, 10, 11, 12, 13);
    rods[3] = Rod(0, 14, 15, 16, 17);
    rods[4] = Rod(0, 18, 19, 20, 21);
    rods[5] = Rod(0, 22, 23, 24, 25);
    rods[6] = Rod(0, 26, 27, 28, 29);
    rods[7] = Rod(0, 30, 31, 32, 33);
    rods[8] = Rod(0, 34, 35, 36, 37);
    rods[9] = Rod(0, 38, 39, 40, 41);
}

// Set the Megas's digital pins as outputs
void set_mega_pins_to_output() {
  for (int pin = 0; pin <= 53; pin++) {
    pinMode(pin, OUTPUT);
  }
}

// Set the Uno's digital pins as outputs
void set_uno_pins_to_output() {
  for (int pin = 0; pin <= 13; pin++) {
    pinMode(pin, OUTPUT);
  }
}

void setup() {
  Serial.begin(9600);
  set_mega_pins_to_output();
  initializeRods();
  delay(2000);
}
void loop() {
  // calibrate_rods();
  if (Serial.available() > 0) {
    String data = Serial.readStringUntil('\n');  // Read until newline character
    Serial.println("read data successfully");
    data.trim();  // Remove any leading/trailing whitespace
    // Remove square brackets 
    data.replace("[", "");
    data.replace("]", "");
    Serial.println("replaced []");
    int numElevations = parseElevations(data);
  
    Serial.print("numElevations: ");
    Serial.println(numElevations);
    // Process the elevations if they exist
    if (numElevations > 0) {
      Serial.println("Received elevations:");
      for (int i = 0; i < numElevations; i++) {
        
        positions_from_elevations(elevations, positions, numRods); // Map the elevations
        Serial.println("Updated positions");

        update_rod_positions(positions); // Move the rods to the new positions.
        Serial.println("Moved the rods");
      }
    }

  }
}

void update_rod_positions(int positions[]) {
  for (int i = 0; i < numRods; i++) {
    Rod &rod = rods[i]; // Make a reference to the specific rod
    rod.go_to_position(positions[i]);
  }
}


void positions_from_elevations(int elevations[], int positions[], int size) {
    for (int i = 0; i < size; i++) {
        if (elevations[i] == 0) {
            positions[i] = 0;
        } else if (elevations[i] == 1) {
            positions[i] = maxHeight;
        } else {
            int clampedElevation = constrain(elevations[i], minElevation, maxElevation);
            positions[i] = map(clampedElevation, minElevation, maxElevation, 0, maxHeight);
        }
    }
}


      
// Parse the elevations and update the elevations array.
// Return the number of elevation points
int parseElevations(String data) {
  int count = 0;
  while (data.length() > 0 && count < numRods) {
    int commaIndex = data.indexOf(",");
    String valueStr;
    if (commaIndex == -1) {
      // Last value
      valueStr = data;
      data = "";
    } else {
      valueStr = data.substring(0, commaIndex);
      data = data.substring(commaIndex + 1);
    }
    valueStr.trim();  // Remove any extra whitespace
    elevations[count] = valueStr.toInt();
    count++;
  }
  return count;
}

void calibrate_rods() {
  //rods[0].go_to_position(-150);
  // rods[1].go_to_position(-40);
  // rods[2].go_to_position(-60);
  // rods[3].go_to_position(-20);
  rods[4].go_to_position(-40);
  //rods[5].go_to_position(-1);
  //rods[6].go_to_position(-90);
  // rods[7].go_to_position(-9);
  //rods[8].go_to_position(-25);
  // rods[9].go_to_position(-10);
}













































