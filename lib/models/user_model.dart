class UserModel {
  final int idUser;
  final String username;
  final String name;
  final String role;
  final String? email;
  final String? phone;
  final String? placementArea;

  UserModel({
    required this.idUser,
    required this.username,
    required this.name,
    required this.role,
    this.email,
    this.phone,
    this.placementArea,
  });

  int get id => idUser;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: json['id_user'] is int
          ? json['id_user']
          : int.tryParse(json['id_user']?.toString() ?? json['id']?.toString() ?? '0') ?? 0,
      username: json['username'] ?? json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'teknisi',
      email: json['email'],
      phone: json['phone'] ?? json['no_hp'] ?? json['phone_number'],
      placementArea: json['placement_area']?.toString()
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
