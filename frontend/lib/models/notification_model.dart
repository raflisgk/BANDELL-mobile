import 'package:intl/intl.dart';
import '../services/notification_service.dart';

enum NotificationType {
  assignment,
  rejected,
}

class NotificationModel {
  final int id;
  final NotificationType type;
  final int? projectId;
  final String projectName;
  final String? message;
  final String? notes;
  final DateTime? assignedAt;
  final String title;
  final String time;
  bool isUnread;
  final String? boldText;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    this.type = NotificationType.assignment,
    this.projectId,
    this.projectName = '-',
    this.message,
    String? notes,
    String? note,
    this.assignedAt,
    this.title = '',
    this.time = '',
    this.isUnread = false,
    this.boldText,
    this.createdAt,
  }) : notes = note ?? notes;

  NotificationType get notificationType => type;

  String get displayTitle {
    if (title.isNotEmpty &&
        title != 'Penugasan Project' &&
        title != 'Penugasan Proyek') {
      return title;
    }
    return type == NotificationType.rejected
        ? 'Laporan Ditolak'
        : 'Penugasan Baru Diterima';
  }

  String get displayMessage {
    if (message != null && message!.trim().isNotEmpty) {
      return message!.trim();
    }
    final project = projectName.trim();
    final hasProject = project.isNotEmpty && project != '-';

    if (type == NotificationType.rejected) {
      return hasProject
          ? 'Laporan penugasan $project ditolak.'
          : 'Laporan penugasan ditolak.';
    } else {
      return hasProject
          ? 'Anda telah ditugaskan untuk proyek $project.'
          : 'Anda telah ditugaskan untuk sebuah proyek.';
    }
  }

  String? get cleanNotes {
    final raw = notes?.trim();
    if (raw == null || raw.isEmpty || raw == '-' || raw.toLowerCase() == 'null') {
      return null;
    }
    final stripped = raw
        .replaceFirst(RegExp(r'^(catatan:\s*|Catatan:\s*)', caseSensitive: false), '')
        .trim();
    if (stripped.isEmpty) return null;
    return 'catatan: $stripped';
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
        json['note']?.toString() ??
        json['content']?.toString();

    final String? notes = (rawNotes != null &&
            rawNotes.trim().isNotEmpty &&
            rawNotes.trim() != '-' &&
            rawNotes.trim().toLowerCase() != 'null')
        ? rawNotes.trim()
        : null;

    final rawType = json['type']?.toString().toLowerCase();
    final rawTitle = json['title']?.toString();

    NotificationType notifType = NotificationType.assignment;
    if (rawType == 'rejected' ||
        rawType == 'ditolak' ||
        (rawType != null &&
            (rawType.contains('reject') || rawType.contains('tolak'))) ||
        (rawTitle != null &&
            (rawTitle.toLowerCase().contains('tolak') ||
                rawTitle.toLowerCase().contains('reject')))) {
      notifType = NotificationType.rejected;
    }

    final String title = rawTitle != null && rawTitle.isNotEmpty
        ? rawTitle
        : (notifType == NotificationType.rejected
            ? 'Laporan Ditolak'
            : 'Penugasan Baru Diterima');

    final rawMessage = json['message']?.toString();

    final bool isUnread = !NotificationService.isReadLocally(id) &&
        (json['is_unread'] == true ||
            json['is_read'] == false ||
            json['is_read'] == 0 ||
            (json.containsKey('read_at') && json['read_at'] == null));

    return NotificationModel(
      id: id,
      type: notifType,
      projectId: json['project_id'] is int
          ? json['project_id']
          : int.tryParse(json['project_id']?.toString() ?? ''),
      projectName: projectName,
      message: rawMessage,
      notes: notes,
      assignedAt: assignedDate,
      title: title,
      time: json['time']?.toString() ?? '',
      isUnread: isUnread,
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
      'message': message,
      'notes': notes,
      'assigned_at': assignedAt?.toIso8601String(),
      'title': title,
      'time': time,
      'is_unread': isUnread,
      'type': type.name,
      'bold_text': boldText,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
