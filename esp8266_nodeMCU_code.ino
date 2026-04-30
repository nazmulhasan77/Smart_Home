/*
=============================================================================
           IoT Smart Home Automation System - NodeMCU (ESP8266)
=============================================================================
Tech Stack: NodeMCU ESP8266, Firebase Realtime Database
Features:
- Real-time sync with Flutter App (via Stream)
- Physical button support with Debounce
- Offline status caching (relays stay in last state)
- Automatic reconnection (WiFi & Firebase)
- Multi-user data isolation

Libraries Required:
1. Firebase-ESP8266 (by Mobizt)
2. ArduinoJson (by Benoit Blanchon)

=============================================================================
*/

#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include <ArduinoJson.h>

// ============ 1. WiFi CONFIGURATION ============
#define WIFI_SSID "YOUR_WIFI_NAME"
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"

// ============ 2. FIREBASE CONFIGURATION ============
// Found in Firebase Console Settings -> Project Settings
#define FIREBASE_HOST "your-project-id-default-rtdb.firebaseio.com"
// Found in Firebase Console Settings -> Service Accounts -> Database Secrets
#define FIREBASE_AUTH "YOUR_FIREBASE_DATABASE_SECRET"

// ============ 3. USER & DEVICE CONFIGURATION ============
// Must match the IDs in your Flutter App
#define USER_ID "YOUR_UID_FROM_APP"
#define DEVICE_ID "YOUR_DEVICE_ID_FROM_APP"

// ============ 4. HARDWARE PIN MAPPING ============
// Relay Pins (Active Low)
const int RELAY_PINS[4] = {D1, D2, D3, D4}; 

// Physical Button Pins (Internal Pullup)
const int BUTTON_PINS[4] = {D5, D6, D7, D8};

// ============ GLOBAL OBJECTS ============
FirebaseData firebaseData;
FirebaseConfig config;
FirebaseAuth auth;

bool switchStates[4] = {false, false, false, false};
bool lastButtonStates[4] = {HIGH, HIGH, HIGH, HIGH};
unsigned long lastDebounceTimes[4] = {0, 0, 0, 0};
unsigned long debounceDelay = 50;

// ============ SETUP ============
void setup() {
  Serial.begin(115200);
  
  // Initialize Relays
  for (int i = 0; i < 4; i++) {
    pinMode(RELAY_PINS[i], OUTPUT);
    digitalWrite(RELAY_PINS[i], HIGH); // Default OFF (Active Low)
  }

  // Initialize Buttons
  for (int i = 0; i < 4; i++) {
    pinMode(BUTTON_PINS[i], INPUT_PULLUP);
  }

  connectWiFi();

  // Firebase Initialization
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // Setup Real-time Stream
  String path = "/users/" + String(USER_ID) + "/devices/" + String(DEVICE_ID) + "/switches";
  if (!Firebase.beginStream(firebaseData, path)) {
    Serial.println("Stream begin error: " + firebaseData.errorReason());
  }

  Serial.println("System Ready!");
}

// ============ MAIN LOOP ============
void loop() {
  handleButtons();
  handleFirebaseStream();
  
  // Keep alive / WiFi check
  if (WiFi.status() != WL_CONNECTED) {
    connectWiFi();
  }
}

// ============ WiFi HELPERS ============
void connectWiFi() {
  if (WiFi.status() == WL_CONNECTED) return;
  
  Serial.print("Connecting to WiFi...");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected! IP: " + WiFi.localIP().toString());
}

// ============ FIREBASE STREAM HANDLER ============
void handleFirebaseStream() {
  if (!Firebase.readStream(firebaseData)) {
    // Serial.println("Stream read error: " + firebaseData.errorReason());
    return;
  }

  if (firebaseData.streamTimeout()) {
    Serial.println("Stream timeout, resuming...");
    return;
  }

  if (firebaseData.streamAvailable()) {
    String jsonStr = firebaseData.jsonString();
    // Serial.println("New Update: " + jsonStr);

    DynamicJsonDocument doc(1024);
    deserializeJson(doc, jsonStr);

    // Path analysis to see what changed
    String path = firebaseData.dataPath();
    
    if (path == "/") {
      // Entire switches object updated
      for (int i = 0; i < 4; i++) {
        String key = "switch" + String(i + 1);
        if (doc.containsKey(key)) {
          updateRelay(i, doc[key]["state"]);
        }
      }
    } else {
      // Single switch updated (e.g., /switch1/state)
      for (int i = 0; i < 4; i++) {
        String key = "/switch" + String(i + 1) + "/state";
        if (path == key) {
          updateRelay(i, firebaseData.boolData());
        }
      }
    }
  }
}

// ============ HARDWARE CONTROL ============
void updateRelay(int index, bool state) {
  switchStates[index] = state;
  // Relay is active-low: LOW = ON, HIGH = OFF
  digitalWrite(RELAY_PINS[index], state ? LOW : HIGH);
  Serial.printf("Switch %d -> %s\n", index + 1, state ? "ON" : "OFF");
}

// ============ PHYSICAL BUTTON HANDLER ============
void handleButtons() {
  for (int i = 0; i < 4; i++) {
    int reading = digitalRead(BUTTON_PINS[i]);

    if (reading != lastButtonStates[i]) {
      lastDebounceTimes[i] = millis();
    }

    if ((millis() - lastDebounceTimes[i]) > debounceDelay) {
      if (reading == LOW && switchStates[i] == false) {
        // Button Pressed (Active Low)
        toggleSwitch(i);
        while(digitalRead(BUTTON_PINS[i]) == LOW) delay(10); // Simple wait for release
      } else if (reading == LOW && switchStates[i] == true) {
        toggleSwitch(i);
        while(digitalRead(BUTTON_PINS[i]) == LOW) delay(10);
      }
    }
    lastButtonStates[i] = reading;
  }
}

void toggleSwitch(int index) {
  bool newState = !switchStates[index];
  updateRelay(index, newState);
  
  // Sync back to Firebase
  String path = "/users/" + String(USER_ID) + "/devices/" + String(DEVICE_ID) + "/switches/switch" + String(index + 1) + "/state";
  Firebase.setBool(firebaseData, path, newState);
}
