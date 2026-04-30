class Schedule {
  final String scheduleId;
  final String deviceId;
  final String userId;
  final String switchId;
  final DateTime scheduledTime;
  final String action; // 'ON' or 'OFF'
  final bool isRecurring;
  final String? recurringPattern; // 'daily', 'weekly', 'monthly'
  final bool isActive;
  final DateTime createdAt;

  Schedule({
    required this.scheduleId,
    required this.deviceId,
    required this.userId,
    required this.switchId,
    required this.scheduledTime,
    required this.action,
    required this.isRecurring,
    this.recurringPattern,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'scheduleId': scheduleId,
      'deviceId': deviceId,
      'userId': userId,
      'switchId': switchId,
      'scheduledTime': scheduledTime.millisecondsSinceEpoch,
      'action': action,
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      scheduleId: json['scheduleId'] ?? '',
      deviceId: json['deviceId'] ?? '',
      userId: json['userId'] ?? '',
      switchId: json['switchId'] ?? '',
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['scheduledTime'])
          : DateTime.now(),
      action: json['action'] ?? 'ON',
      isRecurring: json['isRecurring'] ?? false,
      recurringPattern: json['recurringPattern'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
    );
  }

  Schedule copyWith({
    String? scheduleId,
    String? deviceId,
    String? userId,
    String? switchId,
    DateTime? scheduledTime,
    String? action,
    bool? isRecurring,
    String? recurringPattern,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Schedule(
      scheduleId: scheduleId ?? this.scheduleId,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      switchId: switchId ?? this.switchId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      action: action ?? this.action,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String getFormattedTime() {
    return '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}';
  }

  String getRecurringDisplay() {
    if (!isRecurring) return 'Once';
    switch (recurringPattern) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return 'Once';
    }
  }
}
