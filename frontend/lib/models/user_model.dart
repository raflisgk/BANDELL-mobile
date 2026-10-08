class UserModel {
  final int idUser;
  final String username;
  final String name;
  final String role;
  final String? email;
  final String? phone;
  final String? placementArea;
  final int totalInstallations;
  final int totalProjects;

  UserModel({
    required this.idUser,
    required this.username,
    required this.name,
    required this.role,
    this.email,
    this.phone,
    this.placementArea,
    this.totalInstallations = 0,
    this.totalProjects = 0,
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
      placementArea: json['placement_area']?.toString(),
      totalInstallations: json['total_installations'] is int
          ? json['total_installations']
          : int.tryParse(json['total_installations']?.toString() ?? json['total_lamps']?.toString() ?? '0') ?? 0,
      totalProjects: json['total_projects'] is int
          ? json['total_projects']
          : int.tryParse(json['total_projects']?.toString() ?? '0') ?? 0,
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
      'placement_area': placementArea,
      'total_installations': totalInstallations,
      'total_projects': totalProjects,
    };
  }
}
