class LampTypeModel {
  final int id;
  final String name;
  final String description;
  final String? wattage;

  const LampTypeModel({
    required this.id,
    required this.name,
    required this.description,
    this.wattage,
  });

  factory LampTypeModel.fromJson(Map<String, dynamic> json) {
    return LampTypeModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? json['lamp_type'] ?? '',
      description: json['description'] ?? '',
      wattage: json['wattage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'wattage': wattage,
    };
  }
}
