# API Reference & Code Examples

## 📚 Complete API Documentation

### Table of Contents
1. [Firebase Service API](#firebase-service-api)
2. [State Management (Providers)](#state-management-providers)
3. [Models](#models)
4. [Code Examples](#code-examples)
5. [NodeMCU API](#nodemcu-api)

---

## 🔥 Firebase Service API

### Singleton Pattern
```dart
// Get Firebase Service instance
final firebaseService = FirebaseService();

// All methods are static and accessible from anywhere
```

### Authentication Methods

#### `signUp()`
Signs up a new user with email and password.

```dart
Future<User?> signUp({
  required String email,
  required String password,
  required String displayName,
})
```

**Parameters:**
- `email`: User's email address
- `password`: User's password (min 6 chars recommended)
- `displayName`: User's display name

**Returns:** Firebase `User` object or throws exception

**Example:**
```dart
try {
  final user = await FirebaseService().signUp(
    email: 'user@example.com',
    password: 'password123',
    displayName: 'John Doe',
  );
  print('Signup successful: ${user?.uid}');
} catch (e) {
  print('Signup failed: $e');
}
```

#### `signIn()`
Signs in an existing user.

```dart
Future<User?> signIn({
  required String email,
  required String password,
})
```

**Parameters:**
- `email`: User's email
- `password`: User's password

**Returns:** Firebase `User` object or throws exception

**Example:**
```dart
try {
  final user = await FirebaseService().signIn(
    email: 'user@example.com',
    password: 'password123',
  );
  print('Login successful: ${user?.email}');
} catch (e) {
  print('Login failed: $e');
}
```

#### `signOut()`
Signs out the current user.

```dart
Future<void> signOut()
```

**Example:**
```dart
await FirebaseService().signOut();
print('Signed out successfully');
```

#### `getCurrentUser()`
Gets the currently logged-in user.

```dart
User? getCurrentUser()
```

**Returns:** Current `User` or `null` if not logged in

**Example:**
```dart
final user = FirebaseService().getCurrentUser();
if (user != null) {
  print('Current user: ${user.email}');
} else {
  print('No user logged in');
}
```

#### `authStateChanges()`
Listens to authentication state changes.

```dart
Stream<User?> authStateChanges()
```

**Returns:** Stream of `User` or `null`

**Example:**
```dart
FirebaseService().authStateChanges().listen((user) {
  if (user != null) {
    print('User logged in: ${user.uid}');
  } else {
    print('User logged out');
  }
});
```

---

### Device Methods

#### `addDevice()`
Adds a new device to the user's account.

```dart
Future<Device> addDevice({
  required String deviceName,
  required String userId,
})
```

**Parameters:**
- `deviceName`: Name for the device
- `userId`: Current user's ID

**Returns:** Created `Device` object

**Example:**
```dart
final device = await FirebaseService().addDevice(
  deviceName: 'Living Room',
  userId: 'user123',
);
print('Device created: ${device.deviceId}');
```

#### `getDevices()`
Gets all devices for a user (one-time fetch).

```dart
Future<List<Device>> getDevices(String userId)
```

**Parameters:**
- `userId`: User's ID

**Returns:** List of `Device` objects

**Example:**
```dart
final devices = await FirebaseService().getDevices('user123');
for (var device in devices) {
  print('Device: ${device.deviceName}');
}
```

#### `getDevicesStream()`
Gets real-time stream of devices.

```dart
Stream<List<Device>> getDevicesStream(String userId)
```

**Parameters:**
- `userId`: User's ID

**Returns:** Stream of device lists

**Example:**
```dart
FirebaseService().getDevicesStream('user123').listen((devices) {
  print('Devices updated: ${devices.length}');
});
```

#### `updateDeviceName()`
Updates a device's name.

```dart
Future<void> updateDeviceName({
  required String userId,
  required String deviceId,
  required String newName,
})
```

**Example:**
```dart
await FirebaseService().updateDeviceName(
  userId: 'user123',
  deviceId: 'device456',
  newName: 'Master Bedroom',
);
```

#### `deleteDevice()`
Deletes a device and its associated schedules.

```dart
Future<void> deleteDevice({
  required String userId,
  required String deviceId,
})
```

**Example:**
```dart
await FirebaseService().deleteDevice(
  userId: 'user123',
  deviceId: 'device456',
);
```

---

### Switch Methods

#### `updateSwitchState()`
Updates the state of a switch (ON/OFF).

```dart
Future<void> updateSwitchState({
  required String userId,
  required String deviceId,
  required String switchId,
  required bool state,
})
```

**Parameters:**
- `state`: `true` for ON, `false` for OFF

**Example:**
```dart
await FirebaseService().updateSwitchState(
  userId: 'user123',
  deviceId: 'device456',
  switchId: 'switch1',
  state: true,  // Turn ON
);
```

#### `getSwitchState()`
Gets current state of a switch.

```dart
Future<bool> getSwitchState({
  required String userId,
  required String deviceId,
  required String switchId,
})
```

**Returns:** `true` if ON, `false` if OFF

**Example:**
```dart
final state = await FirebaseService().getSwitchState(
  userId: 'user123',
  deviceId: 'device456',
  switchId: 'switch1',
);
print('Switch is ${state ? "ON" : "OFF"}');
```

#### `getSwitchStateStream()`
Listens to real-time switch state changes.

```dart
Stream<bool> getSwitchStateStream({
  required String userId,
  required String deviceId,
  required String switchId,
})
```

**Returns:** Stream of boolean state

**Example:**
```dart
FirebaseService().getSwitchStateStream(
  userId: 'user123',
  deviceId: 'device456',
  switchId: 'switch1',
).listen((state) {
  print('Switch state changed: $state');
});
```

#### `updateSwitchName()`
Updates the name of a switch.

```dart
Future<void> updateSwitchName({
  required String userId,
  required String deviceId,
  required String switchId,
  required String newName,
})
```

**Example:**
```dart
await FirebaseService().updateSwitchName(
  userId: 'user123',
  deviceId: 'device456',
  switchId: 'switch1',
  newName: 'Ceiling Light',
);
```

---

### Schedule Methods

#### `addSchedule()`
Creates a new schedule.

```dart
Future<Schedule> addSchedule({
  required String deviceId,
  required String userId,
  required String switchId,
  required DateTime scheduledTime,
  required String action,
  required bool isRecurring,
  String? recurringPattern,
})
```

**Parameters:**
- `action`: "ON" or "OFF"
- `isRecurring`: `true` for recurring schedules
- `recurringPattern`: "daily", "weekly", "monthly"

**Example:**
```dart
final schedule = await FirebaseService().addSchedule(
  deviceId: 'device456',
  userId: 'user123',
  switchId: 'switch1',
  scheduledTime: DateTime(2024, 1, 1, 6, 0),  // 6 AM
  action: 'ON',
  isRecurring: true,
  recurringPattern: 'daily',
);
print('Schedule created: ${schedule.scheduleId}');
```

#### `getSchedules()`
Gets all schedules for a user.

```dart
Future<List<Schedule>> getSchedules(String userId)
```

**Returns:** List of `Schedule` objects

**Example:**
```dart
final schedules = await FirebaseService().getSchedules('user123');
for (var schedule in schedules) {
  print('Schedule: ${schedule.getFormattedTime()}');
}
```

#### `getDeviceSchedules()`
Gets schedules for a specific device.

```dart
Future<List<Schedule>> getDeviceSchedules({
  required String userId,
  required String deviceId,
})
```

**Example:**
```dart
final schedules = await FirebaseService().getDeviceSchedules(
  userId: 'user123',
  deviceId: 'device456',
);
```

#### `getSchedulesStream()`
Listens to real-time schedule updates.

```dart
Stream<List<Schedule>> getSchedulesStream(String userId)
```

**Example:**
```dart
FirebaseService().getSchedulesStream('user123').listen((schedules) {
  print('Schedules updated: ${schedules.length}');
});
```

#### `updateSchedule()`
Updates an existing schedule.

```dart
Future<void> updateSchedule(String userId, Schedule schedule)
```

**Example:**
```dart
final updatedSchedule = existingSchedule.copyWith(
  action: 'OFF',
  isActive: false,
);
await FirebaseService().updateSchedule('user123', updatedSchedule);
```

#### `deleteSchedule()`
Deletes a schedule.

```dart
Future<void> deleteSchedule({
  required String userId,
  required String scheduleId,
})
```

**Example:**
```dart
await FirebaseService().deleteSchedule(
  userId: 'user123',
  scheduleId: 'schedule789',
);
```

#### `toggleScheduleStatus()`
Enables or disables a schedule.

```dart
Future<void> toggleScheduleStatus({
  required String userId,
  required String scheduleId,
  required bool newStatus,
})
```

**Example:**
```dart
await FirebaseService().toggleScheduleStatus(
  userId: 'user123',
  scheduleId: 'schedule789',
  newStatus: false,  // Disable
);
```

---

## 🎯 State Management (Providers)

### AuthProvider

#### Properties
```dart
AppUser? currentUser          // Current logged-in user
bool isLoading               // Whether operation in progress
String? error                // Last error message
bool isAuthenticated         // Whether user is logged in
```

#### Methods

**`signUp()`**
```dart
Future<void> signUp({
  required String email,
  required String password,
  required String displayName,
})
```

**`signIn()`**
```dart
Future<void> signIn({
  required String email,
  required String password,
})
```

**`signOut()`**
```dart
Future<void> signOut()
```

**`clearError()`**
```dart
void clearError()
```

#### Usage in Widget
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    if (authProvider.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (authProvider.error != null) {
      return Text('Error: ${authProvider.error}');
    }
    
    if (authProvider.isAuthenticated) {
      return Text('Logged in as: ${authProvider.currentUser?.email}');
    }
    
    return Text('Not logged in');
  },
)
```

---

### DeviceProvider

#### Properties
```dart
List<Device> devices         // List of devices
bool isLoading              // Loading state
String? error               // Error message
```

#### Methods

**`loadDevices()`**
```dart
Future<void> loadDevices()
```

**`getDevicesStream()`**
```dart
Stream<List<Device>> getDevicesStream()
```

**`addDevice()`**
```dart
Future<void> addDevice(String deviceName)
```

**`updateDeviceName()`**
```dart
Future<void> updateDeviceName(String deviceId, String newName)
```

**`deleteDevice()`**
```dart
Future<void> deleteDevice(String deviceId)
```

**`updateSwitchState()`**
```dart
Future<void> updateSwitchState(String deviceId, String switchId, bool state)
```

**`updateSwitchName()`**
```dart
Future<void> updateSwitchName(String deviceId, String switchId, String newName)
```

**`clearError()`**
```dart
void clearError()
```

#### Usage Example
```dart
// In a widget
Consumer<DeviceProvider>(
  builder: (context, deviceProvider, _) {
    if (deviceProvider.devices.isEmpty) {
      return Text('No devices');
    }
    
    return ListView(
      children: deviceProvider.devices.map((device) {
        return ListTile(
          title: Text(device.deviceName),
          onTap: () {
            deviceProvider.updateSwitchState(
              device.deviceId,
              'switch1',
              true,
            );
          },
        );
      }).toList(),
    );
  },
)
```

---

### ScheduleProvider

#### Properties
```dart
List<Schedule> schedules    // All schedules
bool isLoading             // Loading state
String? error              // Error message
```

#### Methods

**`loadSchedules()`**
```dart
Future<void> loadSchedules()
```

**`getSchedulesStream()`**
```dart
Stream<List<Schedule>> getSchedulesStream()
```

**`getDeviceSchedules()`**
```dart
List<Schedule> getDeviceSchedules(String deviceId)
```

**`addSchedule()`**
```dart
Future<void> addSchedule({
  required String deviceId,
  required String switchId,
  required DateTime scheduledTime,
  required String action,
  required bool isRecurring,
  String? recurringPattern,
})
```

**`updateSchedule()`**
```dart
Future<void> updateSchedule(Schedule schedule)
```

**`deleteSchedule()`**
```dart
Future<void> deleteSchedule(String scheduleId)
```

**`toggleScheduleStatus()`**
```dart
Future<void> toggleScheduleStatus(String scheduleId, bool newStatus)
```

---

## 📦 Models

### Device
```dart
class Device {
  final String deviceId;          // Unique device ID
  final String userId;            // Owner's user ID
  final String deviceName;        // Display name
  final Map<String, dynamic> switches;  // Switch states
  final DateTime createdAt;       // Creation timestamp
}

// Methods
Device.copyWith({...})           // Create modified copy
Map<String, dynamic> toJson()    // Convert to JSON
factory Device.fromJson(json)    // Create from JSON
```

### Schedule
```dart
class Schedule {
  final String scheduleId;
  final String deviceId;
  final String userId;
  final String switchId;
  final DateTime scheduledTime;
  final String action;            // "ON" or "OFF"
  final bool isRecurring;
  final String? recurringPattern; // "daily", "weekly", "monthly"
  final bool isActive;
  final DateTime createdAt;
}

// Methods
String getFormattedTime()       // Format: "HH:MM"
String getRecurringDisplay()   // Format: "Daily", "Weekly", etc.
Schedule.copyWith({...})
Map<String, dynamic> toJson()
factory Schedule.fromJson(json)
```

### AppUser
```dart
class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;
}

// Methods
AppUser.copyWith({...})
Map<String, dynamic> toJson()
factory AppUser.fromJson(json)
```

---

## 💻 Code Examples

### Example 1: Complete Login Flow
```dart
class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _handleLogin() async {
    context.read<AuthProvider>().signIn(
      email: emailController.text,
      password: passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(authProvider.error!)),
            );
            authProvider.clearError();
          }

          return Column(
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _handleLogin,
                child: authProvider.isLoading
                    ? CircularProgressIndicator()
                    : Text('Login'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
```

### Example 2: Device Control with Real-time Updates
```dart
class DeviceControlWidget extends StatelessWidget {
  final Device device;

  const DeviceControlWidget({required this.device});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().currentUser?.uid ?? '';

    return StreamBuilder<List<Device>>(
      stream: FirebaseService().getDevicesStream(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final devices = snapshot.data!;
        final currentDevice = devices.firstWhere(
          (d) => d.deviceId == device.deviceId,
        );

        return GridView.count(
          crossAxisCount: 2,
          children: currentDevice.switches.entries.map((entry) {
            final switchId = entry.key;
            final switchData = entry.value as Map<String, dynamic>;
            final state = switchData['state'] as bool;
            final name = switchData['name'] as String;

            return GestureDetector(
              onTap: () {
                context.read<DeviceProvider>().updateSwitchState(
                  device.deviceId,
                  switchId,
                  !state,
                );
              },
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: state ? Colors.yellow : Colors.grey,
                      size: 48,
                    ),
                    SizedBox(height: 8),
                    Text(name),
                    Text(state ? 'ON' : 'OFF'),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
```

### Example 3: Create Schedule
```dart
Future<void> createDailySchedule({
  required BuildContext context,
  required String deviceId,
  required String switchId,
  required TimeOfDay time,
}) async {
  final scheduledDateTime = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    time.hour,
    time.minute,
  );

  await context.read<ScheduleProvider>().addSchedule(
    deviceId: deviceId,
    switchId: switchId,
    scheduledTime: scheduledDateTime,
    action: 'ON',
    isRecurring: true,
    recurringPattern: 'daily',
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Schedule created successfully')),
  );
}
```

### Example 4: Monitor All Schedules
```dart
class ScheduleListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().currentUser?.uid ?? '';

    return StreamBuilder<List<Schedule>>(
      stream: FirebaseService().getSchedulesStream(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final schedules = snapshot.data!;

        if (schedules.isEmpty) {
          return Center(child: Text('No schedules'));
        }

        return ListView.builder(
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return ListTile(
              title: Text('${schedule.switchId} - ${schedule.action}'),
              subtitle: Text(
                '${schedule.getFormattedTime()} ${schedule.getRecurringDisplay()}',
              ),
              trailing: Switch(
                value: schedule.isActive,
                onChanged: (value) {
                  context.read<ScheduleProvider>().toggleScheduleStatus(
                    schedule.scheduleId,
                    value,
                  );
                },
              ),
              onLongPress: () {
                context.read<ScheduleProvider>().deleteSchedule(
                  schedule.scheduleId,
                );
              },
            );
          },
        );
      },
    );
  }
}
```

---

## 🛠️ NodeMCU API

### Core Functions

```cpp
// Initialization
void setup()                    // Initial setup
void loop()                     // Main loop

// WiFi Management
void connectToWiFi()            // Connect to WiFi network

// Relay Control
void setRelayState(int index, bool state)  // Set relay ON/OFF

// Firebase Sync
void updateSwitchStatesFromFirebase()      // Read from Firebase
void updateSwitchStateToFirebase(int index, bool state)  // Write to Firebase

// Schedule Management
void loadSchedulesFromFirebase()           // Load schedules
void checkAndExecuteSchedules()            // Execute if time matched

// Button Handling
void checkButtons()                        // Check button presses

// Utilities
void printSystemStatus()                   // Print current status
```

### Global Variables
```cpp
bool currentSwitchState[4]     // Current state of each switch
bool lastButtonState[4]        // Last button state for debouncing
unsigned long lastButtonPressTime[4]  // For debounce timing
unsigned long lastUpdateTime   // For throttling Firebase reads
unsigned long lastScheduleCheckTime   // For schedule checking interval

Schedule localSchedules[10]    // Local cache of schedules
int scheduleCount             // Number of loaded schedules
```

---

## 🔗 Integration Example

```cpp
// Main setup example for NodeMCU

#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include <ArduinoJson.h>

#define WIFI_SSID "YOUR_SSID"
#define WIFI_PASSWORD "YOUR_PASSWORD"
#define FIREBASE_HOST "your-project.firebaseio.com"
#define FIREBASE_AUTH "YOUR_SECRET"
#define USER_ID "user123"
#define DEVICE_ID "device456"

#define RELAY_PIN_1 D1
#define BUTTON_PIN_1 D5

FirebaseData firebaseData;

void setup() {
  Serial.begin(115200);
  
  // Initialize relay
  pinMode(RELAY_PIN_1, OUTPUT);
  digitalWrite(RELAY_PIN_1, HIGH);  // OFF
  
  // Initialize button
  pinMode(BUTTON_PIN_1, INPUT_PULLUP);
  
  // Connect WiFi
  connectToWiFi();
  
  // Configure Firebase
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);
}

void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    connectToWiFi();
  }
  
  // Check buttons
  checkButtons();
  
  // Update from Firebase
  updateSwitchStatesFromFirebase();
  
  // Check and execute schedules
  checkAndExecuteSchedules();
  
  delay(50);
}

void updateSwitchStatesFromFirebase() {
  String path = "/users/" + String(USER_ID) + "/devices/" + 
                String(DEVICE_ID) + "/switches/switch1/state";
  
  if (Firebase.getBool(firebaseData, path)) {
    bool state = firebaseData.boolData();
    digitalWrite(RELAY_PIN_1, state ? LOW : HIGH);
  }
}
```

---

**Complete API Reference Ends Here! 🎉**

For more examples and use cases, check the actual implementation files in the `lib/` directory.
