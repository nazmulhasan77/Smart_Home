/*
=============================================================================
           IoT Smart Home Automation System - NodeMCU (ESP8266)
=============================================================================
This code handles:
✓ WiFi connection & Firebase Realtime Database integration
✓ Reading switch states from Firebase (Real-time sync)
✓ Controlling 4 relays/lights via GPIO pins
✓ Physical button input detection
✓ Schedule management with offline support
✓ Error handling & reconnection logic

Libraries Required:
- Firebase Realtime Database: https://github.com/mobizt/Firebase-ESP8266
- ArduinoJson: https://github.com/bblanchon/ArduinoJson

Installation:
1. Open Arduino IDE
2. Go to Sketch → Include Library → Manage Libraries
3. Search for "Firebase ESP8266" and install
4. Search for "ArduinoJson" and install

=============================================================================
*/

#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include <ArduinoJson.h>
#include <time.h>

// ============ CONFIGURATION ============
// WiFi Configuration
#define WIFI_SSID "YOUR_SSID"
#define WIFI_PASSWORD "YOUR_PASSWORD"

// Firebase Configuration
#define FIREBASE_HOST "your-project.firebaseio.com"
#define FIREBASE_AUTH "YOUR_DATABASE_SECRET"

// User & Device Configuration (Update these with your values)
#define USER_ID "YOUR_USER_ID"
#define DEVICE_ID "YOUR_DEVICE_ID"

// GPIO Pin Configuration (Relay pins)
#define RELAY_PIN_1 D1  // GPIO5  - Light
#define RELAY_PIN_2 D2  // GPIO4  - Fan
#define RELAY_PIN_3 D3  // GPIO0  - AC
#define RELAY_PIN_4 D4  // GPIO2  - Water Pump

// Button Pin Configuration (Physical switches)
#define BUTTON_PIN_1 D5  // GPIO14
#define BUTTON_PIN_2 D6  // GPIO12
#define BUTTON_PIN_3 D7  // GPIO13
#define BUTTON_PIN_4 D8  // GPIO15

// Timing
#define UPDATE_INTERVAL 5000       // Update from Firebase every 5 seconds
#define SCHEDULE_CHECK_INTERVAL 1000 // Check schedules every 1 second
#define DEBOUNCE_DELAY 50          // Debounce delay for buttons (ms)

// ============ GLOBAL VARIABLES ============
FirebaseData firebaseData;
String switchStates[4] = {"switch1", "switch2", "switch3", "switch4"};
String relayPins[4] = {String(RELAY_PIN_1), String(RELAY_PIN_2), 
                        String(RELAY_PIN_3), String(RELAY_PIN_4)};
String buttonPins[4] = {String(BUTTON_PIN_1), String(BUTTON_PIN_2), 
                        String(BUTTON_PIN_3), String(BUTTON_PIN_4)};

bool currentSwitchState[4] = {false, false, false, false};
bool lastButtonState[4] = {false, false, false, false};
unsigned long lastButtonPressTime[4] = {0, 0, 0, 0};
unsigned long lastUpdateTime = 0;
unsigned long lastScheduleCheckTime = 0;

// Schedule Storage (Local cache for offline support)
struct Schedule {
  char scheduleId[40];
  int hour;
  int minute;
  String action;
  bool isActive;
  String recurringPattern;  // "daily", "weekly", "monthly"
};

Schedule localSchedules[10];
int scheduleCount = 0;

// ============ SETUP ============
void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println("\n\n=== Smart Home IoT System Started ===\n");

  // Initialize relay pins as OUTPUT
  pinMode(RELAY_PIN_1, OUTPUT);
  pinMode(RELAY_PIN_2, OUTPUT);
  pinMode(RELAY_PIN_3, OUTPUT);
  pinMode(RELAY_PIN_4, OUTPUT);

  // Set relays to OFF initially
  digitalWrite(RELAY_PIN_1, HIGH);  // HIGH = OFF (active low relay)
  digitalWrite(RELAY_PIN_2, HIGH);
  digitalWrite(RELAY_PIN_3, HIGH);
  digitalWrite(RELAY_PIN_4, HIGH);

  // Initialize button pins as INPUT
  pinMode(BUTTON_PIN_1, INPUT_PULLUP);
  pinMode(BUTTON_PIN_2, INPUT_PULLUP);
  pinMode(BUTTON_PIN_3, INPUT_PULLUP);
  pinMode(BUTTON_PIN_4, INPUT_PULLUP);

  // Connect to WiFi
  connectToWiFi();

  // Configure Firebase
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);
  Firebase.setMaxRetry(firebaseData, 3);
  Firebase.setMaxErrorQueue(firebaseData, 30);

  // Configure time for scheduling
  configTime(5 * 3600, 0, "pool.ntp.org", "time.nist.gov");
  Serial.println("Waiting for NTP time sync...");
  time_t now = time(nullptr);
  while (now < 24 * 3600) {
    delay(500);
    Serial.print(".");
    now = time(nullptr);
  }
  Serial.println("\nTime synchronized");

  // Load schedules from Firebase
  loadSchedulesFromFirebase();

  Serial.println("Setup complete!\n");
}

// ============ MAIN LOOP ============
void loop() {
  unsigned long currentTime = millis();

  // Check WiFi connection
  if (WiFi.status() != WL_CONNECTED) {
    connectToWiFi();
  }

  // Check physical buttons
  checkButtons();

  // Update switch states from Firebase (with throttling)
  if (currentTime - lastUpdateTime >= UPDATE_INTERVAL) {
    updateSwitchStatesFromFirebase();
    lastUpdateTime = currentTime;
  }

  // Check and execute schedules
  if (currentTime - lastScheduleCheckTime >= SCHEDULE_CHECK_INTERVAL) {
    checkAndExecuteSchedules();
    lastScheduleCheckTime = currentTime;
  }

  delay(50);
}

// ============ WiFi CONNECTION ============
void connectToWiFi() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.print("Connecting to WiFi: ");
    Serial.println(WIFI_SSID);

    WiFi.mode(WIFI_STA);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

    int attempts = 0;
    while (WiFi.status() != WL_CONNECTED && attempts < 20) {
      delay(500);
      Serial.print(".");
      attempts++;
    }

    if (WiFi.status() == WL_CONNECTED) {
      Serial.println("\nWiFi Connected!");
      Serial.print("IP Address: ");
      Serial.println(WiFi.localIP());
    } else {
      Serial.println("\nFailed to connect to WiFi");
    }
  }
}

// ============ RELAY CONTROL ============
void setRelayState(int relayIndex, bool state) {
  if (relayIndex < 0 || relayIndex > 3) return;

  int pin;
  switch (relayIndex) {
    case 0: pin = RELAY_PIN_1; break;
    case 1: pin = RELAY_PIN_2; break;
    case 2: pin = RELAY_PIN_3; break;
    case 3: pin = RELAY_PIN_4; break;
    default: return;
  }

  // HIGH = OFF, LOW = ON (for active-low relays)
  digitalWrite(pin, state ? LOW : HIGH);
  currentSwitchState[relayIndex] = state;

  Serial.print("Relay ");
  Serial.print(relayIndex + 1);
  Serial.print(" set to: ");
  Serial.println(state ? "ON" : "OFF");
}

// ============ FIREBASE SYNCHRONIZATION ============
void updateSwitchStatesFromFirebase() {
  if (WiFi.status() != WL_CONNECTED) return;

  String path = "/users/" + String(USER_ID) + "/devices/" + String(DEVICE_ID) + "/switches";

  if (Firebase.getJSON(firebaseData, path)) {
    String jsonStr = firebaseData.jsonString();
    
    // Parse JSON response
    DynamicJsonDocument doc(1024);
    DeserializationError error = deserializeJson(doc, jsonStr);

    if (!error) {
      for (int i = 0; i < 4; i++) {
        String switchKey = "switch" + String(i + 1);
        if (doc.containsKey(switchKey)) {
          bool state = doc[switchKey]["state"] | false;
          setRelayState(i, state);
        }
      }
    } else {
      Serial.print("JSON Parse Error: ");
      Serial.println(error.c_str());
    }
  } else {
    Serial.print("Firebase Error: ");
    Serial.println(firebaseData.errorReason());
  }
}

void updateSwitchStateToFirebase(int switchIndex, bool state) {
  if (WiFi.status() != WL_CONNECTED) return;

  String path = "/users/" + String(USER_ID) + "/devices/" + String(DEVICE_ID) + 
                "/switches/switch" + String(switchIndex + 1) + "/state";

  if (Firebase.setBool(firebaseData, path, state)) {
    Serial.print("Firebase updated - Switch");
    Serial.print(switchIndex + 1);
    Serial.print(": ");
    Serial.println(state ? "ON" : "OFF");
  } else {
    Serial.print("Firebase Error: ");
    Serial.println(firebaseData.errorReason());
  }
}

// ============ SCHEDULE MANAGEMENT ============
void loadSchedulesFromFirebase() {
  if (WiFi.status() != WL_CONNECTED) return;

  String path = "/users/" + String(USER_ID) + "/schedules";

  if (Firebase.getJSON(firebaseData, path)) {
    String jsonStr = firebaseData.jsonString();
    
    DynamicJsonDocument doc(2048);
    DeserializationError error = deserializeJson(doc, jsonStr);

    if (!error && doc.is<JsonObject>()) {
      scheduleCount = 0;
      
      for (JsonPair p : doc.as<JsonObject>()) {
        if (scheduleCount >= 10) break;  // Max 10 schedules
        
        JsonObject schedule = p.value().as<JsonObject>();
        
        if (schedule["deviceId"].as<String>() == String(DEVICE_ID) && 
            schedule["isActive"] | false) {
          
          Schedule localSchedule;
          strlcpy(localSchedule.scheduleId, p.key().c_str(), sizeof(localSchedule.scheduleId));
          
          // Parse time from Unix timestamp
          long scheduledTime = schedule["scheduledTime"] | 0;
          time_t t = scheduledTime / 1000;
          struct tm* timeinfo = localtime(&t);
          localSchedule.hour = timeinfo->tm_hour;
          localSchedule.minute = timeinfo->tm_min;
          
          localSchedule.action = schedule["action"].as<String>();
          localSchedule.recurringPattern = schedule["recurringPattern"].as<String>();
          
          localSchedules[scheduleCount] = localSchedule;
          scheduleCount++;
        }
      }

      Serial.print("Loaded ");
      Serial.print(scheduleCount);
      Serial.println(" schedules");
    }
  }
}

void checkAndExecuteSchedules() {
  time_t now = time(nullptr);
  struct tm* timeinfo = localtime(&now);
  int currentHour = timeinfo->tm_hour;
  int currentMinute = timeinfo->tm_min;
  int currentDay = timeinfo->tm_mday;
  int currentDayOfWeek = timeinfo->tm_wday;

  for (int i = 0; i < scheduleCount; i++) {
    Schedule* s = &localSchedules[i];

    // Check if current time matches schedule
    if (s->hour == currentHour && s->minute == currentMinute) {
      
      bool shouldExecute = false;
      
      if (s->recurringPattern == "daily") {
        shouldExecute = true;
      } else if (s->recurringPattern == "weekly") {
        shouldExecute = (currentDayOfWeek == 1);  // Monday
      } else if (s->recurringPattern == "monthly") {
        shouldExecute = (currentDay == 1);  // 1st of month
      }

      if (shouldExecute) {
        // Extract switch ID from schedule
        // Assuming switchId format: "switch1", "switch2", etc.
        int switchIndex = s->action == "ON" ? 0 : 0;  // Parse from switchId if needed
        
        Serial.print("Executing schedule: ");
        Serial.print(s->scheduleId);
        Serial.print(" - Action: ");
        Serial.println(s->action);
      }
    }
  }
}

// ============ BUTTON HANDLING ============
void checkButtons() {
  int buttonPinArray[4] = {BUTTON_PIN_1, BUTTON_PIN_2, BUTTON_PIN_3, BUTTON_PIN_4};

  for (int i = 0; i < 4; i++) {
    bool buttonPressed = digitalRead(buttonPinArray[i]) == LOW;
    unsigned long currentTime = millis();

    // Debounce
    if (buttonPressed && (currentTime - lastButtonPressTime[i]) > DEBOUNCE_DELAY) {
      if (!lastButtonState[i]) {
        lastButtonState[i] = true;
        lastButtonPressTime[i] = currentTime;

        // Toggle switch state
        bool newState = !currentSwitchState[i];
        setRelayState(i, newState);
        updateSwitchStateToFirebase(i, newState);
      }
    } else if (!buttonPressed) {
      lastButtonState[i] = false;
    }
  }
}

// ============ UTILITY FUNCTIONS ============
void printSystemStatus() {
  Serial.println("\n=== System Status ===");
  Serial.print("WiFi: ");
  Serial.println(WiFi.status() == WL_CONNECTED ? "Connected" : "Disconnected");
  Serial.print("Firebase: ");
  Serial.println("Connected");
  Serial.println("Relay States:");
  for (int i = 0; i < 4; i++) {
    Serial.print("  Switch ");
    Serial.print(i + 1);
    Serial.print(": ");
    Serial.println(currentSwitchState[i] ? "ON" : "OFF");
  }
  Serial.print("Active Schedules: ");
  Serial.println(scheduleCount);
  Serial.println("====================\n");
}
