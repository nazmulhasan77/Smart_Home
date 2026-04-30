import 'package:flutter/material.dart';
import 'package:smart_home/models/device_model.dart';
import 'package:smart_home/services/firebase_service.dart';

class DeviceProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final String userId;

  List<Device> _devices = [];
  bool _isLoading = false;
  String? _error;

  List<Device> get devices => _devices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DeviceProvider({required this.userId}) {
    loadDevices();
  }

  Future<void> loadDevices() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _devices = await _firebaseService.getDevices(userId);
      _isLoading = false;
    } catch (e) {
      _error = 'Failed to load devices: $e';
      _isLoading = false;
    }
    notifyListeners();
  }

  Stream<List<Device>> getDevicesStream() {
    return _firebaseService.getDevicesStream(userId);
  }

  Future<void> addDevice(String deviceName) async {
    try {
      _error = null;
      final device = await _firebaseService.addDevice(
        deviceName: deviceName,
        userId: userId,
      );
      _devices.add(device);
    } catch (e) {
      _error = 'Failed to add device: $e';
    }
    notifyListeners();
  }

  Future<void> updateDeviceName(String deviceId, String newName) async {
    try {
      _error = null;
      await _firebaseService.updateDeviceName(
        userId: userId,
        deviceId: deviceId,
        newName: newName,
      );

      final index = _devices.indexWhere(
        (device) => device.deviceId == deviceId,
      );
      if (index != -1) {
        _devices[index] = _devices[index].copyWith(deviceName: newName);
      }
    } catch (e) {
      _error = 'Failed to update device: $e';
    }
    notifyListeners();
  }

  Future<void> deleteDevice(String deviceId) async {
    try {
      _error = null;
      await _firebaseService.deleteDevice(userId: userId, deviceId: deviceId);
      _devices.removeWhere((device) => device.deviceId == deviceId);
    } catch (e) {
      _error = 'Failed to delete device: $e';
    }
    notifyListeners();
  }

  Future<void> updateSwitchState(
    String deviceId,
    String switchId,
    bool state,
  ) async {
    try {
      _error = null;
      await _firebaseService.updateSwitchState(
        userId: userId,
        deviceId: deviceId,
        switchId: switchId,
        state: state,
      );

      // Update local state
      final deviceIndex = _devices.indexWhere(
        (device) => device.deviceId == deviceId,
      );
      if (deviceIndex != -1) {
        final switches = Map<String, dynamic>.from(
          _devices[deviceIndex].switches,
        );
        if (switches.containsKey(switchId)) {
          switches[switchId] = {
            'name': switches[switchId]['name'] ?? 'Switch',
            'state': state,
          };
          _devices[deviceIndex] = _devices[deviceIndex].copyWith(
            switches: switches,
          );
        }
      }
    } catch (e) {
      _error = 'Failed to update switch: $e';
    }
    notifyListeners();
  }

  Future<void> updateSwitchName(
    String deviceId,
    String switchId,
    String newName,
  ) async {
    try {
      _error = null;
      await _firebaseService.updateSwitchName(
        userId: userId,
        deviceId: deviceId,
        switchId: switchId,
        newName: newName,
      );

      // Update local state
      final deviceIndex = _devices.indexWhere(
        (device) => device.deviceId == deviceId,
      );
      if (deviceIndex != -1) {
        final switches = Map<String, dynamic>.from(
          _devices[deviceIndex].switches,
        );
        if (switches.containsKey(switchId)) {
          switches[switchId] = {
            'name': newName,
            'state': switches[switchId]['state'] ?? false,
          };
          _devices[deviceIndex] = _devices[deviceIndex].copyWith(
            switches: switches,
          );
        }
      }
    } catch (e) {
      _error = 'Failed to update switch name: $e';
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setUser(String uid) {}
}
