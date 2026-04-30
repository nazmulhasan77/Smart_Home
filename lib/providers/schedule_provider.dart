import 'package:flutter/material.dart';
import 'package:smart_home/models/schedule_model.dart';
import 'package:smart_home/services/firebase_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final String userId;

  List<Schedule> _schedules = [];
  bool _isLoading = false;
  String? _error;

  List<Schedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ScheduleProvider({required this.userId}) {
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _schedules = await _firebaseService.getSchedules(userId);
      _isLoading = false;
    } catch (e) {
      _error = 'Failed to load schedules: $e';
      _isLoading = false;
    }
    notifyListeners();
  }

  Stream<List<Schedule>> getSchedulesStream() {
    return _firebaseService.getSchedulesStream(userId);
  }

  List<Schedule> getDeviceSchedules(String deviceId) {
    return _schedules.where((s) => s.deviceId == deviceId).toList();
  }

  Future<void> addSchedule({
    required String deviceId,
    required String switchId,
    required DateTime scheduledTime,
    required String action,
    required bool isRecurring,
    String? recurringPattern,
  }) async {
    try {
      _error = null;
      final schedule = await _firebaseService.addSchedule(
        deviceId: deviceId,
        userId: userId,
        switchId: switchId,
        scheduledTime: scheduledTime,
        action: action,
        isRecurring: isRecurring,
        recurringPattern: recurringPattern,
      );
      _schedules.add(schedule);
    } catch (e) {
      _error = 'Failed to add schedule: $e';
    }
    notifyListeners();
  }

  Future<void> updateSchedule(Schedule schedule) async {
    try {
      _error = null;
      await _firebaseService.updateSchedule(userId, schedule);

      final index = _schedules.indexWhere(
        (s) => s.scheduleId == schedule.scheduleId,
      );
      if (index != -1) {
        _schedules[index] = schedule;
      }
    } catch (e) {
      _error = 'Failed to update schedule: $e';
    }
    notifyListeners();
  }

  Future<void> deleteSchedule(String scheduleId) async {
    try {
      _error = null;
      await _firebaseService.deleteSchedule(
        userId: userId,
        scheduleId: scheduleId,
      );
      _schedules.removeWhere((s) => s.scheduleId == scheduleId);
    } catch (e) {
      _error = 'Failed to delete schedule: $e';
    }
    notifyListeners();
  }

  Future<void> toggleScheduleStatus(String scheduleId, bool newStatus) async {
    try {
      _error = null;
      await _firebaseService.toggleScheduleStatus(
        userId: userId,
        scheduleId: scheduleId,
        newStatus: newStatus,
      );

      final index = _schedules.indexWhere((s) => s.scheduleId == scheduleId);
      if (index != -1) {
        _schedules[index] = _schedules[index].copyWith(isActive: newStatus);
      }
    } catch (e) {
      _error = 'Failed to update schedule status: $e';
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
