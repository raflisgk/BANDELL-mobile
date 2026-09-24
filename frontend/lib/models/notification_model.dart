import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import 'installation_model.dart';

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
  final int? installationId;
  final InstallationModel? installation;

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
    this.installationId,
    this.installation,
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

  String get district {
    final d = installation?.districtName ?? installation?.district;
    if (d != null && d.trim().isNotEmpty && d.trim() != '-') {
      return d.trim();
    }
    return '-';
  }

  String get idLcu {
    final l = installation?.idLcu ?? installation?.lcu_id;
    if (l != null && l.trim().isNotEmpty && l.trim() != '-') {
      return l.trim();
    }
    return '-';
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

    final installationId = json['installation_id'] is int
        ? json['installation_id']
        : int.tryParse(json['installation_id']?.toString() ?? '');

    final String? rootDistrict = json['district'] is Map
        ? (json['district']['name']?.toString() ??
            json['district']['district_name']?.toString())
        : (json['district']?.toString() ??
            json['district_name']?.toString() ??
            json['area_name']?.toString());

    final String? rootLcu = json['id_lcu']?.toString() ??
        json['lcu_id']?.toString() ??
        json['lcuId']?.toString();

    InstallationModel? installation;
    if (json['installation'] is Map<String, dynamic>) {
      installation = InstallationModel.fromJson(
          json['installation'] as Map<String, dynamic>);
    } else if (json['installation'] is Map) {
      installation = InstallationModel.fromJson(
          Map<String, dynamic>.from(json['installation'] as Map));
    } else if (json['note_by_admin'] != null ||
        json['verification_status'] != null ||
        rootLcu != null ||
        rootDistrict != null) {
      installation = InstallationModel(
        idInstallation: installationId ?? 0,
        idArea: 0,
        lampCode: rootLcu ?? '',
        lampType: '',
        idLcu: rootLcu,
        districtName: rootDistrict,
        noteByAdmin: json['note_by_admin']?.toString(),
        verificationStatus: json['verification_status']?.toString(),
      );
    }

    if (installation != null) {
      if ((installation.districtName == null || installation.districtName!.isEmpty) &&
          rootDistrict != null &&
          rootDistrict.isNotEmpty) {
        installation = InstallationModel(
          idInstallation: installation.idInstallation,
          idProject: installation.idProject,
          idUser: installation.idUser,
          idArea: installation.idArea,
          districtName: rootDistrict,
          lampTypeId: installation.lampTypeId,
          idLcu: installation.idLcu ?? rootLcu,
          lampCode: installation.lampCode,
          lampType: installation.lampType,
          wattage: installation.wattage,
          status: installation.status,
          latitude: installation.latitude,
          longitude: installation.longitude,
          panelCode: installation.panelCode,
          photos: installation.photos,
          inputMethod: installation.inputMethod,
          photoUrl: installation.photoUrl,
          notes: installation.notes,
          noteByAdmin: installation.noteByAdmin,
          verificationStatus: installation.verificationStatus,
          installedAt: installation.installedAt,
          createdAt: installation.createdAt,
          updatedAt: installation.updatedAt,
        );
      } else if ((installation.idLcu == null || installation.idLcu!.isEmpty) &&
          rootLcu != null &&
          rootLcu.isNotEmpty) {
        installation = InstallationModel(
          idInstallation: installation.idInstallation,
          idProject: installation.idProject,
          idUser: installation.idUser,
          idArea: installation.idArea,
          districtName: installation.districtName,
          lampTypeId: installation.lampTypeId,
          idLcu: rootLcu,
          lampCode: installation.lampCode.isNotEmpty ? installation.lampCode : rootLcu,
          lampType: installation.lampType,
          wattage: installation.wattage,
          status: installation.status,
          latitude: installation.latitude,
          longitude: installation.longitude,
          panelCode: installation.panelCode,
          photos: installation.photos,
          inputMethod: installation.inputMethod,
          photoUrl: installation.photoUrl,
          notes: installation.notes,
          noteByAdmin: installation.noteByAdmin,
          verificationStatus: installation.verificationStatus,
          installedAt: installation.installedAt,
          createdAt: installation.createdAt,
          updatedAt: installation.updatedAt,
        );
      }
    }

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
      installationId: installationId,
      installation: installation,
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
      'installation_id': installationId,
      'installation': installation?.toJson(),
    };
  }
}
