class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool isGoogleUser;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.isGoogleUser = false,
    required this.createdAt,
    this.lastLoginAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'isGoogleUser': isGoogleUser,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? 'User',
      photoUrl: json['photoUrl'],
      phoneNumber: json['phoneNumber'],
      isGoogleUser: json['isGoogleUser'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastLoginAt'])
          : null,
    );
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool? isGoogleUser,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isGoogleUser: isGoogleUser ?? this.isGoogleUser,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
