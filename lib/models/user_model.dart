class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photo;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final int savedPlayersCount;
  final int reportsRequestedCount;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photo,
    required this.isPremium,
    required this.createdAt,
    this.lastLoginAt,
    this.savedPlayersCount = 0,
    this.reportsRequestedCount = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      photo: json['photo'],
      isPremium: json['isPremium'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      savedPlayersCount: json['savedPlayersCount'] ?? 0,
      reportsRequestedCount: json['reportsRequestedCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photo': photo,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'savedPlayersCount': savedPlayersCount,
      'reportsRequestedCount': reportsRequestedCount,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photo,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    int? savedPlayersCount,
    int? reportsRequestedCount,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      savedPlayersCount: savedPlayersCount ?? this.savedPlayersCount,
      reportsRequestedCount: reportsRequestedCount ?? this.reportsRequestedCount,
    );
  }
}
