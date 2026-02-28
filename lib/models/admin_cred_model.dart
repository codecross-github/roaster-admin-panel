class AdminCredModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  AdminCredModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.role = 'admin',
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory AdminCredModel.fromJson(Map<String, dynamic> json, String docId) {
    return AdminCredModel(
      id: docId,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? 'admin',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }
}
