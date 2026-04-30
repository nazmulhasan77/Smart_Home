class Device {
  final String deviceId;
  final String userId;
  final String deviceName;
  final Map<String, dynamic> switches;
  final DateTime createdAt;

  Device({
    required this.deviceId,
    required this.userId,
    required this.deviceName,
    required this.switches,
    required this.createdAt,
  });

  // Convert Device to JSON
  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'userId': userId,
      'deviceName': deviceName,
      'switches': switches,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create Device from JSON
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['deviceId'] ?? '',
      userId: json['userId'] ?? '',
      deviceName: json['deviceName'] ?? 'Device',
      switches:
          json['switches'] ??
          {
            'switch1': {'name': 'Light', 'state': false},
            'switch2': {'name': 'Fan', 'state': false},
            'switch3': {'name': 'AC', 'state': false},
            'switch4': {'name': 'Water Pump', 'state': false},
          },
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
    );
  }

  Device copyWith({
    String? deviceId,
    String? userId,
    String? deviceName,
    Map<String, dynamic>? switches,
    DateTime? createdAt,
  }) {
    return Device(
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      deviceName: deviceName ?? this.deviceName,
      switches: switches ?? this.switches,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SwitchInfo {
  final String switchId;
  final String name;
  final bool state;

  SwitchInfo({required this.switchId, required this.name, required this.state});

  Map<String, dynamic> toJson() {
    return {'name': name, 'state': state};
  }

  factory SwitchInfo.fromJson(String switchId, Map<String, dynamic> json) {
    return SwitchInfo(
      switchId: switchId,
      name: json['name'] ?? 'Unknown',
      state: json['state'] ?? false,
    );
  }

  SwitchInfo copyWith({String? name, bool? state}) {
    return SwitchInfo(
      switchId: switchId,
      name: name ?? this.name,
      state: state ?? this.state,
    );
  }
}
