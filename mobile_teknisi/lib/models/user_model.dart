class UserModel {
  final int idUser;
  final String username;
  final String name;
  final String role;
  final String? email;
  final String? phone;

  UserModel({
    required this.idUser,
    required this.username,
    required this.name,
    required this.role,
    this.email,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: json['id_user'] is int
          ? json['id_user']
          : int.tryParse(json['id_user']?.toString() ?? '0') ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'teknisi',
      email: json['email'],
      phone: json['phone'] ?? json['no_hp'] ?? json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'username': username,
      'name': name,
      'role': role,
      'email': email,
      'phone': phone,
    };
  }
}
