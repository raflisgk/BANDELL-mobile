import 'package:intl/intl.dart';

class NotificationModel {
  final int id;
  final int? projectId;
  final String projectName;
  final String? notes;
  final DateTime? assignedAt;
  final String title;
  final String time;
  bool isUnread;
  final String? type;
  final String? boldText;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    this.projectId,
    this.projectName = '-',
    this.notes,
    this.assignedAt,
    this.title = 'Penugasan Baru Diterima',
    this.time = '',
    this.isUnread = false,
    this.type,
    this.boldText,
    this.createdAt,
  });

  String get displayTitle => title.isNotEmpty ? title : 'Penugasan Baru Diterima';

  String? get cleanNotes {
    if (notes == null) return null;
    final trimmed = notes!.trim();
    if (trimmed.isEmpty || trimmed == '-' || trimmed.toLowerCase() == 'null') {
      return null;
    }
    return trimmed;
  }

  String get formattedDate {
    if (assignedAt == null) return '';
    try {
      return DateFormat('dd/MM/yyyy').format(assignedAt!.toLocal());
    } catch (_) {
      return assignedAt!.toLocal().toIso8601String().split('T').first;
    }
  }

  String get content {
    final buffer = StringBuffer();
    if (projectName.isNotEmpty && projectName != '-') {
      buffer.writeln('Project: $projectName');
    }
    if (notes != null && notes!.isNotEmpty && notes != '-') {
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

    final rawNotes = json['notes']?.toString() ??
        json['content']?.toString() ??
        json['message']?.toString();

    final String? notes = (rawNotes != null &&
            rawNotes.trim().isNotEmpty &&
            rawNotes.trim() != '-' &&
            rawNotes.trim().toLowerCase() != 'null')
        ? rawNotes.trim()
        : null;

    return NotificationModel(
      id: id,
      projectId: json['project_id'] is int
          ? json['project_id']
          : int.tryParse(json['project_id']?.toString() ?? ''),
      projectName: projectName,
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
          (json.containsKey('read_at') && json['read_at'] == null),
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
