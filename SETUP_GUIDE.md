# Smart Home IoT Automation System - Complete Setup Guide

## 📋 Table of Contents
1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Prerequisites](#prerequisites)
4. [Firebase Setup](#firebase-setup)
5. [Flutter App Setup](#flutter-app-setup)
6. [NodeMCU Setup](#nodemcu-setup)
7. [Database Schema](#database-schema)
8. [Usage Guide](#usage-guide)
9. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

This is a complete **IoT-based Smart Home Automation System** with:
- ✅ **Multi-user support** with Firebase Authentication
- ✅ **Real-time synchronization** between Flutter app and NodeMCU
- ✅ **Multiple device management** support
- ✅ **Schedule system** with offline capability
- ✅ **Physical switch input** handling
- ✅ **Production-level** security and error handling

### Components:
- **Frontend:** Flutter app (iOS/Android)
- **Backend:** Firebase Realtime Database
- **Hardware:** NodeMCU (ESP8266) with relays
- **Auth:** Firebase Authentication (Email/Password)

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Firebase Backend                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │          Firebase Realtime Database                  │   │
│  │  /users/{uid}/devices/{deviceId}/switches/{id}      │   │
│  │  /users/{uid}/schedules/{scheduleId}                │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │          Firebase Authentication                     │   │
│  │  (Email/Password Login)                              │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
         ▲                                          ▲
         │                                          │
         │ (Real-time                               │ (Real-time
         │  Sync via                                │  Sync)
         │  Streams)                                │
         │                                          │
    ┌────┴────────────────────┐         ┌──────────┴─────────┐
    │                          │         │                   │
┌───▼──────────────────────┐   │   ┌─────▼──────────────┐   │
│   Flutter Mobile App      │   │   │  NodeMCU (ESP8266) │   │
│  ┌────────────────────┐   │   │   │ ┌────────────────┐ │   │
│  │ Home Screen        │   │   │   │ │ WiFi Module    │ │   │
│  │ - Device List      │   │   │   │ │ Firebase SDK   │ │   │
│  │ - Real-time Sync   │   │   │   │ │ Relay Control  │ │   │
│  └────────────────────┘   │   │   │ │ Button Inputs  │ │   │
│  ┌────────────────────┐   │   │   │ │ Schedule Mgmt  │ │   │
│  │ Device Control     │   │   │   │ └────────────────┘ │   │
│  │ - Toggle Switch    │   │   │   │ ┌────────────────┐ │   │
│  │ - Edit Name        │   │   │   │ │ Relays (4x)    │ │   │
│  └────────────────────┘   │   │   │ │ - Light        │ │   │
│  ┌────────────────────┐   │   │   │ │ - Fan          │ │   │
│  │ Schedule Manager   │   │   │   │ │ - AC           │ │   │
│  │ - Add Schedule     │   │   │   │ │ - Water Pump   │ │   │
│  │ - Edit Schedule    │   │   │   │ └────────────────┘ │   │
│  │ - View All         │   │   │   │ ┌────────────────┐ │   │
│  └────────────────────┘   │   │   │ │ Buttons (4x)   │ │   │
└────────────────────────────┘   │   │ │ Physical Ctrl  │ │   │
                                 │   │ └────────────────┘ │   │
                                 └───┴──────────────────────┘   
```

---

## 📋 Prerequisites

### Required Accounts:
1. **Google/Firebase Account** (free tier is sufficient)
2. **GitHub** (optional, for version control)

### Hardware:
- **NodeMCU (ESP8266)** - Development board
- **4x Relay Modules** - To control devices
- **4x Push Buttons** - For physical input
- **Power Supply** - 5V for NodeMCU, appropriate for relays
- **Jumper Wires** - For connections
- **USB Cable** - For programming NodeMCU

### Software:
- **Arduino IDE** (https://www.arduino.cc/en/software)
- **Flutter SDK** (https://flutter.dev/docs/get-started/install)
- **Git** (optional)

### Libraries for Arduino:
- Firebase-ESP8266
- ArduinoJson

---

## 🔥 Firebase Setup

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a new project"
3. Enter project name (e.g., "SmartHomeIoT")
4. Enable Google Analytics (optional)
5. Click "Create project"

### Step 2: Set Up Authentication
1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Click on "Email/Password"
4. Enable it
5. No additional setup needed

### Step 3: Set Up Realtime Database
1. In Firebase Console, go to **Realtime Database**
2. Click "Create Database"
3. Choose region (select closest to you)
4. Start in **Test Mode** (we'll add rules later)
5. Click "Enable"

### Step 4: Add Security Rules
1. Go to **Realtime Database** → **Rules**
2. Replace the content with the rules from `FIREBASE_RULES.json`
3. Click "Publish"

### Step 5: Get Firebase Configuration
1. Go to **Project Settings** (gear icon)
2. Click on **Your apps** → **iOS** (or Android)
3. If no app created, click "Add app"
4. Follow the setup steps
5. You'll get `GoogleService-Info.plist` (iOS) or `google-services.json` (Android)

For Android:
1. Download `google-services.json`
2. Copy to `android/app/` directory

---

## 📱 Flutter App Setup

### Step 1: Install Dependencies
```bash
cd smart_home
flutter pub get
```

### Step 2: Configure Firebase
**For Android:**
1. Copy `google-services.json` to `android/app/`
2. Open `android/build.gradle` and ensure Firebase is configured

**For iOS:**
1. Copy `GoogleService-Info.plist` to `ios/Runner/`
2. Follow iOS Firebase setup guide

### Step 3: Run the App
```bash
flutter run
```

### Step 4: First Time Usage
1. **Sign Up** with your email
2. **Create a device** by tapping "Add Device"
3. **Give it a name** (e.g., "Living Room")
4. **Configure switches** by long-pressing each switch tile
5. **Add schedules** from the Schedules menu

---

## 🛠️ NodeMCU Setup

### Step 1: Install Arduino IDE
1. Download from https://www.arduino.cc/en/software
2. Install it

### Step 2: Add ESP8266 Board
1. Open Arduino IDE
2. Go to **File** → **Preferences**
3. In "Additional Board Manager URLs", add:
   ```
   http://arduino.esp8266.com/stable/package_esp8266com_index.json
   ```
4. Go to **Tools** → **Board** → **Board Manager**
5. Search "ESP8266" and install "esp8266 by ESP8266 Community"

### Step 3: Install Required Libraries
1. Go to **Sketch** → **Include Library** → **Manage Libraries**
2. Install these libraries:
   - `Firebase ESP8266` (by mobizt)
   - `ArduinoJson` (by Benoit Blanchon)

### Step 4: Configure the Code
Open `esp8266_nodeMCU_code.ino` and update these values:

```cpp
#define WIFI_SSID "YOUR_SSID"
#define WIFI_PASSWORD "YOUR_PASSWORD"
#define FIREBASE_HOST "your-project.firebaseio.com"
#define FIREBASE_AUTH "YOUR_DATABASE_SECRET"
#define USER_ID "YOUR_USER_ID"
#define DEVICE_ID "YOUR_DEVICE_ID"
```

#### How to get these values:

**FIREBASE_HOST & FIREBASE_AUTH:**
1. Go to Firebase Console → Realtime Database
2. Click on "Rules" tab
3. Look at the URL: `https://YOUR_PROJECT.firebaseio.com`
4. `YOUR_PROJECT` is your FIREBASE_HOST
5. For FIREBASE_AUTH, go to Project Settings → Service Accounts → Database Secrets

**USER_ID & DEVICE_ID:**
1. Get USER_ID from Firebase Authentication
2. Get DEVICE_ID from the Flutter app (visible when you create a device)

### Step 5: Connect NodeMCU
1. Connect NodeMCU to your computer via USB cable
2. In Arduino IDE, go to **Tools**:
   - Board: "NodeMCU 1.0 (ESP-12E Module)"
   - Upload Speed: "115200"
   - Port: Select your USB port
3. Click **Upload** to program the device

### Step 6: Hardware Connections

**Relay Pins:**
- D1 (GPIO5) → Relay 1 (Light)
- D2 (GPIO4) → Relay 2 (Fan)
- D3 (GPIO0) → Relay 3 (AC)
- D4 (GPIO2) → Relay 4 (Water Pump)

**Button Pins:**
- D5 (GPIO14) → Button 1
- D6 (GPIO12) → Button 2
- D7 (GPIO13) → Button 3
- D8 (GPIO15) → Button 4

**Power Connections:**
- NodeMCU: 5V from USB or external power supply
- Relays: Connect to appropriate power supply (usually 5V or 12V)
- Ground: Common ground between NodeMCU and relay module

---

## 💾 Database Schema

```
firebase_database
├── users/
│   └── {uid}/
│       ├── uid: "user_id"
│       ├── email: "user@example.com"
│       ├── displayName: "John Doe"
│       ├── createdAt: 1693891200000
│       │
│       ├── devices/
│       │   └── {deviceId}/
│       │       ├── deviceId: "device-uuid"
│       │       ├── userId: "{uid}"
│       │       ├── deviceName: "Living Room"
│       │       ├── createdAt: 1693891200000
│       │       └── switches/
│       │           ├── switch1/
│       │           │   ├── name: "Light"
│       │           │   └── state: true/false
│       │           ├── switch2/
│       │           │   ├── name: "Fan"
│       │           │   └── state: true/false
│       │           ├── switch3/
│       │           │   ├── name: "AC"
│       │           │   └── state: true/false
│       │           └── switch4/
│       │               ├── name: "Water Pump"
│       │               └── state: true/false
│       │
│       └── schedules/
│           └── {scheduleId}/
│               ├── scheduleId: "schedule-uuid"
│               ├── deviceId: "{deviceId}"
│               ├── userId: "{uid}"
│               ├── switchId: "switch1"
│               ├── scheduledTime: 1693891200000
│               ├── action: "ON"/"OFF"
│               ├── isRecurring: true/false
│               ├── recurringPattern: "daily"/"weekly"/"monthly"
│               ├── isActive: true/false
│               └── createdAt: 1693891200000
```

---

## 📖 Usage Guide

### Flutter App - User Flow

#### 1. Authentication
- **Sign Up:** Create new account with email/password
- **Login:** Use credentials to access your smart home

#### 2. Home Screen
- **View Devices:** See all your connected devices
- **Quick Control:** Toggle switches directly from device card
- **Add Device:** Tap "Add Device" button to register new NodeMCU

#### 3. Device Detail Screen
- **Full Control:** Detailed view of each switch
- **Rename Device:** Long-press device name
- **Manage Schedules:** Create time-based automation

#### 4. Schedules
- **Create Schedule:** Set time-based actions
- **Recurring:** Daily, Weekly, or Monthly automation
- **Manage:** Edit or delete existing schedules

### NodeMCU - Operation

#### Real-time Operation
1. **Power On:** NodeMCU connects to WiFi automatically
2. **Firebase Sync:** Reads switch states every 5 seconds
3. **Control:** Toggle switches via Flutter app or physical buttons
4. **Update:** Changes reflect instantly on both ends

#### Physical Button Usage
- **Press Button:** Toggles corresponding switch
- **Updates Firebase:** Change is synced to app and database
- **Offline Support:** Works even without internet (local only)

#### Schedule Execution
- **Loads Schedules:** Downloaded on startup and periodically
- **Offline Execution:** Runs even if WiFi disconnects
- **Accurate Timing:** Uses NTP for time synchronization

---

## 🐛 Troubleshooting

### Flutter App Issues

**"Firebase not initialized"**
- Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in correct location
- Run `flutter clean` then `flutter pub get`

**"Authentication failed"**
- Verify your email/password are correct
- Check if your account is created in Firebase
- Ensure Authentication is enabled in Firebase Console

**"No devices showing"**
- Create a device first using "Add Device" button
- Check Firebase Realtime Database has data
- Ensure you're logged in with correct account

**"Real-time updates not working"**
- Check internet connection
- Verify Firebase rules are correct
- Look at Firebase Database for error messages

### NodeMCU Issues

**"Failed to connect to WiFi"**
- Verify SSID and password are correct
- Check WiFi signal strength
- Ensure WiFi is 2.4GHz (ESP8266 doesn't support 5GHz)

**"Firebase connection failed"**
- Verify FIREBASE_HOST and FIREBASE_AUTH are correct
- Check internet connection
- Ensure Firebase Realtime Database is created
- Verify security rules are not too restrictive

**"Relays not working"**
- Check GPIO pin connections
- Verify relay module is powered
- Check if relay has correct voltage
- Test with simple digitalWrite example

**"Physical buttons not responding"**
- Verify button connections to correct pins
- Test with simple INPUT example
- Check for loose connections
- Consider adding pull-up resistors if needed

### General Issues

**"Port Permission Denied" (Arduino IDE)**
- Linux: Run `sudo usermod -a -G dialout $USER`
- Windows/Mac: Restart IDE and try again

**"Board not detected" (Arduino IDE)**
- Install USB driver for ESP8266
- Try different USB cable
- Check Device Manager (Windows) or System Report (Mac)

---

## 🔐 Security Best Practices

1. **Never Share Secrets:**
   - Firebase secret keys
   - Database URLs
   - WiFi credentials

2. **Use Strong Passwords:**
   - At least 12 characters
   - Mix of letters, numbers, symbols

3. **Enable 2FA:**
   - For Firebase/Google account
   - Protects your backend

4. **Regular Updates:**
   - Keep libraries updated
   - Check for security patches

5. **Monitor Database:**
   - Review Firebase logs
   - Check for unusual access patterns

---

## 📊 Performance Optimization

### Firebase Operations
- **Batch Updates:** Group multiple writes
- **Throttling:** Update intervals (5 seconds default)
- **Caching:** Local cache to reduce reads

### Network Optimization
- **Compression:** Enable gzip if possible
- **Minimal Payloads:** Only send necessary data
- **Connection Pooling:** Reuse connections

### Hardware Optimization
- **Power Management:** Put ESP8266 to sleep when idle
- **Memory:** Monitor available RAM
- **Serial Debug:** Disable in production

---

## 📝 API Reference

### Firebase Service (Flutter)
```dart
// Authentication
await firebaseService.signUp(email, password, displayName)
await firebaseService.signIn(email, password)
await firebaseService.signOut()

// Devices
await firebaseService.addDevice(deviceName, userId)
await firebaseService.getDevices(userId)
firebaseService.getDevicesStream(userId)

// Switches
await firebaseService.updateSwitchState(userId, deviceId, switchId, state)
firebaseService.getSwitchStateStream(userId, deviceId, switchId)

// Schedules
await firebaseService.addSchedule(...)
await firebaseService.getSchedules(userId)
```

### NodeMCU Functions
```cpp
connectToWiFi()
setRelayState(relayIndex, state)
updateSwitchStateToFirebase(switchIndex, state)
loadSchedulesFromFirebase()
checkAndExecuteSchedules()
checkButtons()
```

---

## 🚀 Next Steps / Advanced Features

1. **Mobile Push Notifications** - Notify when schedules execute
2. **Voice Control** - Google Assistant integration
3. **Energy Monitoring** - Track power consumption
4. **Remote Access** - Cloud functions for external control
5. **Machine Learning** - Predictive automation
6. **Mobile App Analytics** - Usage patterns
7. **Backup & Restore** - Data backup system
8. **Multi-device Dashboard** - Unified control panel

---

## 📞 Support & Documentation

- **Firebase Docs:** https://firebase.google.com/docs
- **Flutter Docs:** https://flutter.dev/docs
- **ESP8266 Documentation:** https://github.com/esp8266/Arduino
- **Firebase ESP8266 Library:** https://github.com/mobizt/Firebase-ESP8266

---

## 📄 License

This project is provided as-is for educational and personal use.

---

## ✅ Checklist Before Deployment

- [ ] Firebase project created and configured
- [ ] Authentication enabled in Firebase
- [ ] Realtime Database created with security rules
- [ ] Flutter app built and tested
- [ ] google-services.json added to Android
- [ ] GoogleService-Info.plist added to iOS
- [ ] NodeMCU code updated with correct credentials
- [ ] ESP8266 libraries installed
- [ ] Hardware connections verified
- [ ] NodeMCU programmed successfully
- [ ] WiFi credentials tested
- [ ] First device created in app
- [ ] Real-time sync verified
- [ ] Physical buttons tested
- [ ] Schedule created and executed

---

**Happy Home Automation! 🏠✨**
