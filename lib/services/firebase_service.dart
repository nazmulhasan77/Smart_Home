import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_home/models/device_model.dart';
import 'package:smart_home/models/schedule_model.dart';
import 'package:uuid/uuid.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ Authentication & User Services ============

  /// Sign up with email and password
  Future<User?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update Firebase Auth display name
      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.reload();

      // ✅ Store user profile in Cloud Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  /// Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Listen to auth state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // ============ Device Services ============

  /// Add a new device
  Future<Device> addDevice({
    required String deviceName,
    required String userId,
  }) async {
    try {
      const uuid = Uuid();
      final deviceId = uuid.v4();

      final deviceRef = _database.ref('users/$userId/devices/$deviceId');

      final device = Device(
        deviceId: deviceId,
        userId: userId,
        deviceName: deviceName,
        switches: {
          'switch1': {'name': 'Light', 'state': false},
          'switch2': {'name': 'Fan', 'state': false},
          'switch3': {'name': 'AC', 'state': false},
          'switch4': {'name': 'Water Pump', 'state': false},
        },
        createdAt: DateTime.now(),
      );

      await deviceRef.set(device.toJson());
      return device;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all devices for a user
  Future<List<Device>> getDevices(String userId) async {
    try {
      final snapshot = await _database.ref('users/$userId/devices').get();

      if (snapshot.exists) {
        final devices = <Device>[];
        final data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          devices.add(Device.fromJson(Map<String, dynamic>.from(value)));
        });

        return devices;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Stream of devices for a user (real-time updates)
  Stream<List<Device>> getDevicesStream(String userId) {
    return _database.ref('users/$userId/devices').onValue.map((event) {
      if (event.snapshot.exists) {
        final devices = <Device>[];
        final data = event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          devices.add(Device.fromJson(Map<String, dynamic>.from(value)));
        });

        return devices;
      }
      return [];
    });
  }

  /// Update device name
  Future<void> updateDeviceName({
    required String userId,
    required String deviceId,
    required String newName,
  }) async {
    try {
      await _database
          .ref('users/$userId/devices/$deviceId/deviceName')
          .set(newName);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete device
  Future<void> deleteDevice({
    required String userId,
    required String deviceId,
  }) async {
    try {
      // Delete device
      await _database.ref('users/$userId/devices/$deviceId').remove();
      // Delete associated schedules
      await _database.ref('users/$userId/schedules').once().then((event) {
        final snapshot = event.snapshot;
        if (snapshot.exists) {
          final schedules = snapshot.value as Map<dynamic, dynamic>;
          schedules.forEach((key, value) {
            if (value['deviceId'] == deviceId) {
              _database.ref('users/$userId/schedules/$key').remove();
            }
          });
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  // ============ Switch Control Services ============

  /// Update switch state
  Future<void> updateSwitchState({
    required String userId,
    required String deviceId,
    required String switchId,
    required bool state,
  }) async {
    try {
      await _database
          .ref('users/$userId/devices/$deviceId/switches/$switchId/state')
          .set(state);
    } catch (e) {
      rethrow;
    }
  }

  /// Get switch state
  Future<bool> getSwitchState({
    required String userId,
    required String deviceId,
    required String switchId,
  }) async {
    try {
      final snapshot = await _database
          .ref('users/$userId/devices/$deviceId/switches/$switchId/state')
          .get();

      if (snapshot.exists) {
        return snapshot.value as bool;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  /// Stream of switch state (real-time updates)
  Stream<bool> getSwitchStateStream({
    required String userId,
    required String deviceId,
    required String switchId,
  }) {
    return _database
        .ref('users/$userId/devices/$deviceId/switches/$switchId/state')
        .onValue
        .map((event) {
          if (event.snapshot.exists) {
            return event.snapshot.value as bool;
          }
          return false;
        });
  }

  /// Update switch name
  Future<void> updateSwitchName({
    required String userId,
    required String deviceId,
    required String switchId,
    required String newName,
  }) async {
    try {
      await _database
          .ref('users/$userId/devices/$deviceId/switches/$switchId/name')
          .set(newName);
    } catch (e) {
      rethrow;
    }
  }

  // ============ Schedule Services ============

  /// Add schedule
  Future<Schedule> addSchedule({
    required String deviceId,
    required String userId,
    required String switchId,
    required DateTime scheduledTime,
    required String action,
    required bool isRecurring,
    String? recurringPattern,
  }) async {
    try {
      const uuid = Uuid();
      final scheduleId = uuid.v4();

      final schedule = Schedule(
        scheduleId: scheduleId,
        deviceId: deviceId,
        userId: userId,
        switchId: switchId,
        scheduledTime: scheduledTime,
        action: action,
        isRecurring: isRecurring,
        recurringPattern: recurringPattern,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await _database
          .ref('users/$userId/schedules/$scheduleId')
          .set(schedule.toJson());

      return schedule;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all schedules for a user
  Future<List<Schedule>> getSchedules(String userId) async {
    try {
      final snapshot = await _database.ref('users/$userId/schedules').get();

      if (snapshot.exists) {
        final schedules = <Schedule>[];
        final data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          schedules.add(Schedule.fromJson(Map<String, dynamic>.from(value)));
        });

        return schedules;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get schedules for a specific device
  Future<List<Schedule>> getDeviceSchedules({
    required String userId,
    required String deviceId,
  }) async {
    try {
      final allSchedules = await getSchedules(userId);
      return allSchedules
          .where((schedule) => schedule.deviceId == deviceId)
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Stream of schedules for a user
  Stream<List<Schedule>> getSchedulesStream(String userId) {
    return _database.ref('users/$userId/schedules').onValue.map((event) {
      if (event.snapshot.exists) {
        final schedules = <Schedule>[];
        final data = event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          schedules.add(Schedule.fromJson(Map<String, dynamic>.from(value)));
        });

        return schedules;
      }
      return [];
    });
  }

  /// Update schedule
  Future<void> updateSchedule(String userId, Schedule schedule) async {
    try {
      await _database
          .ref('users/$userId/schedules/${schedule.scheduleId}')
          .set(schedule.toJson());
    } catch (e) {
      rethrow;
    }
  }

  /// Delete schedule
  Future<void> deleteSchedule({
    required String userId,
    required String scheduleId,
  }) async {
    try {
      await _database.ref('users/$userId/schedules/$scheduleId').remove();
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle schedule active status
  Future<void> toggleScheduleStatus({
    required String userId,
    required String scheduleId,
    required bool newStatus,
  }) async {
    try {
      await _database
          .ref('users/$userId/schedules/$scheduleId/isActive')
          .set(newStatus);
    } catch (e) {
      rethrow;
    }
  }
}
