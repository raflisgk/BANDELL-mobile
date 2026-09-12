class NotificationModel {
  final int id;
  final int? projectId;
  final String projectName;
  final int? districtId;
  final String districtName;
  final String notes;
  final DateTime? assignedAt;
  final String title;
  final String time;
  final bool isUnread;
  final String? type;
  final String? boldText;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    this.projectId,
    this.projectName = '-',
    this.districtId,
    this.districtName = '-',
    required this.notes,
    this.assignedAt,
    this.title = 'Penugasan Baru Diterima',
    this.time = '',
    this.isUnread = false,
    this.type,
    this.boldText,
    this.createdAt,
  });

  String get content {
    final buffer = StringBuffer();
    if (projectName.isNotEmpty && projectName != '-') {
      buffer.writeln('Project: $projectName');
    }
    if (districtName.isNotEmpty && districtName != '-') {
      buffer.writeln('Area: $districtName');
    }
    if (notes.isNotEmpty && notes != '-') {
      buffer.writeln('Catatan: $notes');
    }
    return buffer.toString().trim();
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? assignedDate;
    if (json['assigned_at'] != null) {
      assignedDate = DateTime.tryParse(json['assigned_at'].toString());
    }

    final id = json['id'] is int
        ? json['id']
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;

    final projectName = json['project_name']?.toString() ??
        json['project']?['name']?.toString() ??
        '-';

    final districtName = json['district_name']?.toString() ??
        json['district']?['name']?.toString() ??
        '-';

    final notes = json['notes']?.toString() ??
        json['content']?.toString() ??
        json['message']?.toString() ??
        '-';

    return NotificationModel(
      id: id,
      projectId: json['project_id'] is int
          ? json['project_id']
          : int.tryParse(json['project_id']?.toString() ?? ''),
      projectName: projectName,
      districtId: json['district_id'] is int
          ? json['district_id']
          : int.tryParse(json['district_id']?.toString() ?? ''),
      districtName: districtName,
      notes: notes,
      assignedAt: assignedDate,
      title: (json['title'] == null ||
              json['title'] == 'Penugasan Project' ||
              json['title'] == 'Penugasan Proyek')
          ? 'Penugasan Baru Diterima'
          : json['title'].toString(),
      time: json['time']?.toString() ?? '',
      isUnread: json['is_unread'] == true ||
          json['is_read'] == false ||
          json['is_read'] == 0 ||
          json['read_at'] == null,
      type: json['type']?.toString(),
      boldText: json['bold_text']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : assignedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'project_name': projectName,
      'district_id': districtId,
      'district_name': districtName,
      'notes': notes,
      'assigned_at': assignedAt?.toIso8601String(),
      'title': title,
      'time': time,
      'is_unread': isUnread,
      'type': type,
      'bold_text': boldText,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
