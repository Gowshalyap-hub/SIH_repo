class User {
  final String id;
  final String? name;
  final String email;
  final String role;
  final String farmId;
  final String? phone;

  User({
    required this.id,
    this.name,
    required this.email,
    required this.role,
    required this.farmId,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String?,
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      farmId: json['farm_id']?.toString() ?? '',
      phone: json['phone'] as String?,
    );
  }
}
