# 🚀 Smart Home IoT - Quick Reference Card

## 📱 Flutter Commands

```bash
# Initial setup
flutter pub get                 # Install dependencies
flutter clean                   # Clean build
flutter run                     # Run app

# Development
flutter run -v                  # Verbose output
flutter run --release           # Release build
flutter format lib/            # Format code
flutter analyze                # Check for issues

# Testing
flutter test                    # Run tests
flutter devices                 # List connected devices

# Building
flutter build apk              # Android APK
flutter build ios              # iOS app
flutter build web              # Web version
```

---

## 🔥 Firebase Console

```
Navigation:
1. Authentication → Enable Email/Password
2. Realtime Database → Create Database (Test Mode)
3. Database → Rules → Paste FIREBASE_RULES.json
4. Project Settings → Service Accounts → Database Secrets

Key URLs:
- Console: https://console.firebase.google.com
- Docs: https://firebase.google.com/docs
- Flutter Integration: https://firebase.flutter.dev
```

---

## 🛠️ Arduino IDE for NodeMCU

```
Board Manager URL:
http://arduino.esp8266.com/stable/package_esp8266com_index.json

Required Libraries:
1. Firebase ESP8266 (by mobizt)
2. ArduinoJson (by Benoit Blanchon)
3. ESP8266 Core (installed via board manager)

Upload Settings:
- Board: NodeMCU 1.0 (ESP-12E Module)
- Upload Speed: 115200
- CPU Frequency: 80 MHz
- Flash Size: 4M (1M SPIFFS)
```

---

## 📁 File Structure Quick Reference

```
smart_home/
├── lib/
│   ├── main.dart                    ← App entry point
│   ├── models/                      ← Data models
│   ├── services/                    ← Firebase operations
│   ├── providers/                   ← State management
│   ├── screens/                     ← UI pages
│   └── widgets/                     ← Reusable components
├── esp8266_nodeMCU_code.ino         ← NodeMCU firmware
├── SETUP_GUIDE.md                   ← Setup instructions
├── HARDWARE_GUIDE.md                ← Wiring guide
├── API_REFERENCE.md                 ← API docs
└── README.md                        ← Project overview
```

---

## 🔑 Environment Configuration

### Flutter App (lib/main.dart)
```dart
// Already configured with:
- Firebase initialization
- Provider setup
- Navigation routes
- Theme configuration
```

### NodeMCU (esp8266_nodeMCU_code.ino)
```cpp
// Update these values:
#define WIFI_SSID "YOUR_SSID"
#define WIFI_PASSWORD "YOUR_PASSWORD"
#define FIREBASE_HOST "project.firebaseio.com"
#define FIREBASE_AUTH "YOUR_SECRET"
#define USER_ID "user_id"
#define DEVICE_ID "device_id"
```

---

## 🎯 Common Tasks

### Add New Device Type
```dart
// In device_card.dart
// Add new case in switch statement:
case 'switch5':
  return _SwitchTile(
    device: device,
    switchId: 'switch5',
    switchName: 'New Device',
    switchState: false,
  );
```

### Add New Schedule Type
```dart
// In add_schedule_screen.dart
// Update recurringPattern dropdown:
DropdownMenuItem(value: 'biweekly', child: Text('Bi-weekly')),

// Update schedule execution in NodeMCU
```

### Change GPIO Pin Assignment
```cpp
// In esp8266_nodeMCU_code.ino
#define RELAY_PIN_1 D1      // Change this pin
#define BUTTON_PIN_1 D5     // Or change button pin
```

### Modify Database Schema
```json
// Update in esp8266_nodeMCU_code.ino:
localSchedule.hour = timeinfo->tm_hour;
localSchedule.minute = timeinfo->tm_min;
// Add more fields as needed
```

---

## 🔐 Security Quick Checklist

```
Firebase:
☐ Security rules set (FIREBASE_RULES.json)
☐ Authentication enabled
☐ Database test mode disabled in production
☐ Backup enabled
☐ Activity monitoring enabled

App:
☐ No hardcoded credentials
☐ Error messages don't reveal sensitive data
☐ Session management implemented
☐ Input validation in place

Hardware:
☐ WiFi password strong
☐ Firebase secret not visible
☐ Physical device in secure location
☐ Regular firmware updates
```

---

## 🐛 Debug Mode

### Flutter Debug
```dart
// Add to main.dart for verbose logging:
void main() {
  print('Starting app...');
  debugPrint('Debug mode enabled');
  runApp(const MyApp());
}

// Check provider values:
Consumer<AuthProvider>(
  builder: (context, auth, _) {
    print('Auth state: ${auth.isAuthenticated}');
    return SizedBox.shrink();
  },
)
```

### NodeMCU Debug
```cpp
// Serial output in Arduino IDE:
Serial.begin(115200);
Serial.println("DEBUG: Relay ON");
Serial.print("WiFi Status: ");
Serial.println(WiFi.status());

// Monitor output:
Tools → Serial Monitor → 115200 baud
```

### Firebase Debug
```
Check at:
1. Firebase Console → Database
2. View JSON structure
3. Check realtime activity
4. Review authentication logs
```

---

## 📊 Data Flow Quick Reference

### Device Control
```
User UI → Provider → Firebase → NodeMCU → Relay → Device
  ↓         ↓           ↓         ↓        ↓       ↓
Tap       Update     Write to   Listen   Toggle  Physical
Switch    State      Database   Stream   Output  Change
   ← ← ← Real-time Sync Back to App ← ← ←
```

### Schedule Execution
```
Firebase → NodeMCU → Local Memory → Check Time
  ↓          ↓           ↓            ↓
Load     Cache in   Store until    Execute
Schedules Memory    Needed         Action
```

---

## 📱 UI Routes

```
/                          → AuthWrapper
├── /login                 → LoginScreen
├── /signup                → SignupScreen
├── /home                  → HomeScreen
│   ├── /device-detail     → DeviceDetailScreen
│   └── /add-schedule      → AddScheduleScreen
├── /schedules             → ScheduleListScreen
└── /device-selector       → DeviceSelectorScreen
```

---

## 🔌 GPIO Pin Quick Reference

```
NodeMCU Pin → GPIO → Function
D0          → 16   → Wake-up (avoid)
D1          → 5    → Relay 1 ✓
D2          → 4    → Relay 2 ✓
D3          → 0    → Relay 3 (boot sensitive)
D4          → 2    → Relay 4 (boot sensitive)
D5          → 14   → Button 1 ✓
D6          → 12   → Button 2 ✓
D7          → 13   → Button 3 ✓
D8          → 15   → Button 4 (boot sensitive)
```

---

## ⚡ Power Specifications

```
NodeMCU:
- Voltage: 5V
- Current: 100-500mA
- Via: USB or VIN pin

Relay Module (4x):
- Voltage: 5V
- Current: 500mA-1A each
- Total: 2A-4A

Recommended Supply: 3A-5A @ 5V
```

---

## 📈 Performance Optimization

```
Firebase:
- Throttle updates: 5 seconds default
- Batch operations when possible
- Use transactions for critical updates
- Index frequently queried fields

App:
- Use StreamBuilder for real-time
- Dispose streams properly
- Cache device list locally
- Limit simultaneous requests

NodeMCU:
- Check WiFi status before writes
- Use local storage for schedules
- Debounce button inputs: 50ms
- Minimize Firebase reads
```

---

## 🆘 Error Codes & Solutions

```
Firebase Error 401:
→ Check authentication token
→ User may be logged out
→ Check security rules

WiFi Connection Failed:
→ Verify SSID and password
→ Check 2.4GHz band
→ Check signal strength
→ Restart NodeMCU

Relay Not Responding:
→ Check GPIO connections
→ Verify relay powered
→ Check pin logic (HIGH=OFF)
→ Test with simple digitalWrite

Button Not Detected:
→ Check GPIO connection
→ Verify INPUT_PULLUP enabled
→ Check debounce timing
→ Test with digitalRead()
```

---

## 📚 Documentation Files

```
README.md              - Project overview
SETUP_GUIDE.md         - Complete setup (45 min read)
HARDWARE_GUIDE.md      - Wiring & circuit (30 min read)
API_REFERENCE.md       - API documentation (40 min read)
PROJECT_SUMMARY.md     - Navigation guide (10 min read)
FIREBASE_RULES.json    - Security rules (5 min read)
```

---

## 🚀 Deployment Steps

```
1. Test locally first
   flutter run --release

2. Build APK (Android)
   flutter build apk --release

3. Sign APK
   Configure key.properties

4. Upload NodeMCU
   Upload sketch to device
   Configure WiFi credentials

5. Test integration
   Create device in app
   Test device control
   Test schedules

6. Deploy to production
   Use release builds
   Enable Firebase backups
   Monitor device logs
```

---

## 💾 Backup & Restore

```
Firebase Data:
1. Go to Firebase Console
2. Firestore → Backups (enable if using Firestore)
3. Realtime DB → export JSON regularly

App Data:
1. User accounts: In Firebase Auth
2. Device config: Realtime Database
3. Schedules: Realtime Database
4. Settings: SharedPreferences (local)

NodeMCU:
1. Firmware: Save .ino file
2. Credentials: Keep copy of configuration
3. Schedules: Synced with Firebase
```

---

## 🎓 Learning Path

```
Day 1: Setup (2 hours)
- Firebase project
- Flutter environment
- First run

Day 2: App (3 hours)
- Study code structure
- Create device
- Test controls

Day 3: Hardware (3 hours)
- Assemble circuits
- Upload NodeMCU
- Test relays

Day 4: Integration (2 hours)
- Real-time sync
- Physical buttons
- Schedule execution

Total: ~10 hours to full working system
```

---

## 🎯 Success Criteria

```
✓ Firebase project created
✓ Flutter app runs
✓ User can sign up/login
✓ Device creation works
✓ Switch control works
✓ Real-time updates work
✓ NodeMCU connects
✓ Relays toggle
✓ Physical buttons work
✓ Schedules execute
✓ Offline mode works
```

---

## 📞 Quick Help

| Problem | Solution | Docs |
|---------|----------|------|
| App won't start | flutter clean | SETUP_GUIDE.md |
| Firebase error | Check google-services.json | SETUP_GUIDE.md |
| Device not showing | Create device in app | README.md |
| NodeMCU won't upload | Check USB driver | HARDWARE_GUIDE.md |
| Relay not switching | Check GPIO connections | HARDWARE_GUIDE.md |
| Real-time not working | Check WiFi connection | SETUP_GUIDE.md |
| Schedule not executing | Check time format | API_REFERENCE.md |
| Button not working | Check GPIO pin | HARDWARE_GUIDE.md |

---

## 🔗 Important Links

```
Firebase:        https://console.firebase.google.com
Flutter Docs:    https://flutter.dev/docs
ESP8266 Docs:    https://arduino-esp8266.readthedocs.io
Arduino IDE:     https://www.arduino.cc/en/software
GitHub:          https://github.com/espressif/arduino-esp32
```

---

## ✨ Pro Tips

```
1. Always check Firebase console for data
2. Use Serial Monitor to debug NodeMCU
3. Test Firebase rules before deployment
4. Keep NodeMCU powered for 24/7 operation
5. Back up Firebase data regularly
6. Monitor database usage
7. Test edge cases (offline, disconnect)
8. Document custom changes
9. Keep dependencies updated
10. Follow coding best practices
```

---

**This Quick Reference Card covers 80% of common tasks!**

**For detailed information, refer to full documentation files.**

**Happy Building! 🏠✨**
