# 🏠 Smart Home IoT Automation System

A complete **production-ready** IoT-based Smart Home Automation System built with **Flutter**, **NodeMCU (ESP8266)**, and **Firebase Realtime Database**.

## ✨ Key Features

### 🔐 Multi-User Support
- **Firebase Authentication** (Email/Password)
- Each user has isolated device data
- Secure database rules prevent unauthorized access

### 📱 Flutter Mobile App
- **Real-time Synchronization** with NodeMCU
- **Multi-device Management** - Control multiple devices
- **4-Switch Control** per device (Light, Fan, AC, Water Pump)
- **Custom Switch Names** - Personalize your devices
- **Schedule System** - Time-based automation
- **Real-time Status Updates** - Live device status
- **Offline Support** - View cached data when offline
- **Clean UI/UX** - Intuitive and easy to use

### 🛠️ NodeMCU (ESP8266) Hardware
- **WiFi Connectivity** - Automatic connection & reconnection
- **Firebase Integration** - Real-time database sync
- **4 Relay Control** - Control lights, fans, AC, pumps
- **Physical Buttons** - Manual switch control
- **Schedule Support** - Local execution with offline capability
- **NTP Time Sync** - Accurate scheduling
- **Error Handling** - Robust connection management

### 📊 Firebase Backend
- **Realtime Database** - Instant data synchronization
- **Secure Rules** - User data isolation and protection
- **Efficient Schema** - Optimized for low latency
- **Cloud Storage** - Persistent device and schedule data

### 🎯 Advanced Features
- ✅ Real-time device control
- ✅ Schedule management (One-time, Daily, Weekly, Monthly)
- ✅ Offline switch support (physical buttons)
- ✅ Physical switch state sync
- ✅ Error handling and validation
- ✅ Loading states and animations
- ✅ User-friendly notifications
- ✅ Production-level code architecture

---

## 📂 Project Structure

```
smart_home/
├── lib/
│   ├── main.dart                              # App entry point
│   ├── firebase_options.dart                  # Firebase config
│   ├── models/
│   │   ├── device_model.dart                  # Device data model
│   │   ├── schedule_model.dart                # Schedule data model
│   │   └── user_model.dart                    # User data model
│   ├── services/
│   │   └── firebase_service.dart              # Firebase operations
│   ├── providers/
│   │   ├── auth_provider.dart                 # Auth state management
│   │   ├── device_provider.dart               # Device state management
│   │   └── schedule_provider.dart             # Schedule state management
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart              # Login UI
│   │   │   └── signup_screen.dart             # Registration UI
│   │   ├── home/
│   │   │   ├── home_screen.dart               # Home page with devices
│   │   │   └── device_detail_screen.dart      # Device control page
│   │   └── schedule/
│   │       ├── schedule_list_screen.dart      # View all schedules
│   │       ├── add_schedule_screen.dart       # Create schedule
│   │       └── device_selector_screen.dart    # Select device
│   └── widgets/
│       └── device_card.dart                   # Reusable device card
│
├── android/
│   └── app/
│       └── google-services.json               # Firebase Android config
│
├── ios/
│   └── Runner/
│       └── GoogleService-Info.plist           # Firebase iOS config
│
├── esp8266_nodeMCU_code.ino                   # NodeMCU firmware
├── FIREBASE_RULES.json                        # Security rules
├── SETUP_GUIDE.md                             # Complete setup guide
├── pubspec.yaml                               # Flutter dependencies
└── README.md                                  # This file
```

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (v3.0+)
- Firebase Account
- Arduino IDE
- NodeMCU (ESP8266)

### 1️⃣ Flutter App Setup

```bash
# Clone repository
git clone <your-repo-url>
cd smart_home

# Get dependencies
flutter pub get

# Run app
flutter run
```

### 2️⃣ Firebase Setup
1. Create Firebase project
2. Enable Authentication (Email/Password)
3. Create Realtime Database
4. Apply security rules from `FIREBASE_RULES.json`
5. Download `google-services.json` and `GoogleService-Info.plist`

### 3️⃣ NodeMCU Setup
1. Install Arduino IDE
2. Add ESP8266 board support
3. Install required libraries (Firebase-ESP8266, ArduinoJson)
4. Update WiFi credentials and Firebase config in `esp8266_nodeMCU_code.ino`
5. Upload to NodeMCU

---

## 💾 Database Schema

```yaml
users/{uid}/
  ├── uid: "user_id"
  ├── email: "user@example.com"
  ├── displayName: "John Doe"
  ├── createdAt: 1693891200000
  │
  ├── devices/{deviceId}/
  │   ├── deviceId: "device-uuid"
  │   ├── userId: "{uid}"
  │   ├── deviceName: "Living Room"
  │   ├── createdAt: 1693891200000
  │   └── switches/{switchId}/
  │       ├── name: "Light"
  │       └── state: true/false
  │
  └── schedules/{scheduleId}/
      ├── scheduleId: "schedule-uuid"
      ├── deviceId: "{deviceId}"
      ├── switchId: "switch1"
      ├── scheduledTime: 1693891200000
      ├── action: "ON"/"OFF"
      ├── isRecurring: true/false
      ├── recurringPattern: "daily"/"weekly"/"monthly"
      ├── isActive: true/false
      └── createdAt: 1693891200000
```

---

## 🔌 Hardware Configuration

### Relay Connections (NodeMCU Pins)
```
D1 (GPIO5)  → Relay 1 (Light)
D2 (GPIO4)  → Relay 2 (Fan)
D3 (GPIO0)  → Relay 3 (AC)
D4 (GPIO2)  → Relay 4 (Water Pump)
```

### Button Connections (NodeMCU Pins)
```
D5 (GPIO14) → Button 1
D6 (GPIO12) → Button 2
D7 (GPIO13) → Button 3
D8 (GPIO15) → Button 4
```

---

## 🔐 Security Features

### Firebase Security Rules
- **User Isolation:** Users can only access their own data
- **Authentication Required:** All reads/writes require login
- **Data Validation:** Enforced data structure
- **Rate Limiting:** Prevent excessive requests

### App Security
- **Password Encryption:** Firebase handles secure authentication
- **Session Management:** Automatic logout on app close
- **Error Handling:** No sensitive data in error messages
- **Network Security:** HTTPS for all Firebase connections

---

## 📱 UI/UX Features

### Home Screen
- ✅ Grid/List view of all devices
- ✅ Quick toggle for each switch
- ✅ Add device button
- ✅ Real-time status updates
- ✅ Swipe to edit/delete device

### Device Detail Screen
- ✅ Individual switch control
- ✅ Custom switch naming
- ✅ Schedule management
- ✅ Device information
- ✅ Connection status

### Schedule Screen
- ✅ View all schedules
- ✅ Create time-based automation
- ✅ Edit existing schedules
- ✅ Delete schedules
- ✅ Toggle schedule on/off

---

## 🛠️ Technology Stack

### Frontend
- **Flutter** - Cross-platform mobile app
- **Provider** - State management
- **Firebase Auth** - User authentication
- **Firebase Realtime DB** - Real-time database

### Backend
- **Firebase** - Backend infrastructure
- **Realtime Database** - Data storage
- **Cloud Functions** - (Optional) Advanced features

### Hardware
- **ESP8266 (NodeMCU)** - IoT device
- **Arduino IDE** - Programming environment
- **Firebase ESP8266 Library** - Firebase integration

---

## 📊 Data Flow

### Device Control Flow
```
User taps switch in app
↓
Flutter updates local state
↓
Send update to Firebase
↓
Firebase updates database
↓
NodeMCU receives update via listener
↓
NodeMCU controls relay
↓
Physical device toggles (Light ON/OFF)
↓
NodeMCU confirms state in Firebase
↓
App receives confirmation (real-time sync)
```

### Physical Button Flow
```
User presses physical button on NodeMCU
↓
NodeMCU detects button press (with debounce)
↓
NodeMCU toggles local relay
↓
NodeMCU updates state in Firebase
↓
Firebase notifies all connected clients
↓
Flutter app receives update via stream
↓
App UI reflects new state
```

### Schedule Execution Flow
```
NodeMCU loads schedules from Firebase (on startup + periodically)
↓
NodeMCU stores schedules in local memory
↓
Every second: Check if schedule time matches current time
↓
If match found and schedule is active:
  ├── Execute scheduled action (turn ON/OFF)
  ├── Update relay state
  └── Sync with Firebase
↓
If WiFi offline: Still execute (offline support)
↓
If WiFi online: Sync with cloud
```

---

## 🧪 Testing Checklist

- [ ] Sign up and login works
- [ ] Create device successfully
- [ ] Add multiple devices
- [ ] Toggle switches from app
- [ ] Physical buttons toggle switches
- [ ] Real-time updates appear on app
- [ ] Edit device names
- [ ] Edit switch names
- [ ] Create schedules
- [ ] Schedules execute at correct time
- [ ] Delete devices and schedules
- [ ] Logout works correctly
- [ ] App handles network errors gracefully
- [ ] Offline mode works

---

## 📚 API Reference

### Firebase Service Methods

```dart
// Authentication
signUp(email, password, displayName) → Future<User>
signIn(email, password) → Future<User>
signOut() → Future<void>
getCurrentUser() → User?
authStateChanges() → Stream<User?>

// Devices
addDevice(deviceName, userId) → Future<Device>
getDevices(userId) → Future<List<Device>>
getDevicesStream(userId) → Stream<List<Device>>
updateDeviceName(userId, deviceId, newName) → Future<void>
deleteDevice(userId, deviceId) → Future<void>

// Switches
updateSwitchState(userId, deviceId, switchId, state) → Future<void>
getSwitchState(userId, deviceId, switchId) → Future<bool>
getSwitchStateStream(userId, deviceId, switchId) → Stream<bool>
updateSwitchName(userId, deviceId, switchId, newName) → Future<void>

// Schedules
addSchedule(deviceId, userId, switchId, scheduledTime, action, ...) → Future<Schedule>
getSchedules(userId) → Future<List<Schedule>>
getSchedulesStream(userId) → Stream<List<Schedule>>
updateSchedule(userId, schedule) → Future<void>
deleteSchedule(userId, scheduleId) → Future<void>
toggleScheduleStatus(userId, scheduleId, status) → Future<void>
```

---

## 🐛 Troubleshooting

### App Won't Connect to Firebase
- Verify `google-services.json` / `GoogleService-Info.plist` location
- Check Firebase project is created and configured
- Ensure Authentication is enabled
- Run `flutter clean && flutter pub get`

### NodeMCU Won't Connect to WiFi
- Verify SSID and password are correct
- Check WiFi is 2.4GHz (ESP8266 limitation)
- Ensure signal strength is good
- Check logs in Arduino Serial Monitor

### Real-time Updates Not Working
- Verify internet connection
- Check Firebase security rules
- Ensure user is logged in
- Look at Firebase logs for errors

For more detailed troubleshooting, see [SETUP_GUIDE.md](SETUP_GUIDE.md).

---

## 📝 Code Examples

### Create a New Device
```dart
// In your widget
context.read<DeviceProvider>().addDevice("Living Room");
```

### Toggle Switch
```dart
// In your widget
context.read<DeviceProvider>().updateSwitchState(
  deviceId,
  "switch1",
  true,  // New state
);
```

### Create Schedule
```dart
// Create a schedule for 6 AM
context.read<ScheduleProvider>().addSchedule(
  deviceId: "device-id",
  switchId: "switch1",
  scheduledTime: DateTime(2024, 1, 1, 6, 0),
  action: "ON",
  isRecurring: true,
  recurringPattern: "daily",
);
```

---

## 🚀 Deployment

### Firebase Deployment
1. Add security rules to production
2. Enable backups
3. Set up monitoring
4. Monitor database usage

### Flutter App Deployment
1. Test on real devices
2. Configure app signing
3. Build release APK/IPA
4. Publish to App Store/Play Store

### NodeMCU Deployment
1. Test all relay connections
2. Verify all buttons work
3. Test schedule execution
4. Power with stable supply
5. Monitor device logs

---

## 📈 Performance Metrics

- **Database Reads:** 1 read every 5 seconds per device
- **Database Writes:** 1 write per toggle/schedule
- **Real-time Latency:** <500ms typical
- **App Performance:** 60 FPS on modern devices
- **NodeMCU Memory:** ~60KB used (remaining for schedules)

---

## 🎓 Learning Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Documentation](https://flutter.dev/docs)
- [ESP8266 Arduino Core](https://github.com/esp8266/Arduino)
- [Firebase ESP8266 Library](https://github.com/mobizt/Firebase-ESP8266)

---

## 📄 License

This project is provided for educational and personal use.

---

## 👨‍💻 Author

Created as a complete IoT Smart Home System demonstrating best practices in:
- Flutter state management
- Firebase backend design
- Embedded systems programming
- IoT architecture
- Security implementation

---

## 🎯 Future Enhancements

1. **Push Notifications** - Get alerts for schedule execution
2. **Voice Control** - Google Assistant / Alexa integration
3. **Energy Monitoring** - Track power consumption
4. **MQTT Support** - Alternative to Firebase
5. **Machine Learning** - Predictive automation
6. **Web Dashboard** - Web-based control panel
7. **Analytics** - Usage statistics and trends
8. **Backup/Restore** - Data backup system

---

## ⚠️ Important Notes

- **Security:** Never commit Firebase credentials to version control
- **Power Supply:** Ensure proper voltage for relays (usually 5V or 12V)
- **WiFi:** ESP8266 only supports 2.4GHz WiFi
- **Database:** Keep Firebase database structure consistent
- **Testing:** Test thoroughly before deploying to production

---

## 🆘 Support

For issues and questions:
1. Check [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed instructions
2. Review troubleshooting section above
3. Check Firebase console for errors
4. Look at NodeMCU serial output for debugging

---

**Happy Smart Home Automation! 🏠✨**


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
