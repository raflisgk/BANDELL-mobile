class LampTypeModel {
  final int id;
  final String name;
  final String description;

  LampTypeModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory LampTypeModel.fromJson(Map<String, dynamic> json) {
    return LampTypeModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,

      // Laravel menggunakan lamp_name
      name: json['lamp_name']?.toString() ?? '',

      // API saat ini belum memiliki description
      description: json['description']?.toString() ?? '',
    );
  }
}