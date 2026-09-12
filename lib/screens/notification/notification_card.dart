import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/notification_model.dart';
import '../../utils/app_colors.dart';

class NotificationItem {
  final int id;
  final String title;
  final String time;
  final String content;
  final String? projectName;
  final String? districtName;
  final String? notes;
  final DateTime? assignedAt;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  bool isUnread;
  final String section;
  final String? boldText;

  NotificationItem({
    required this.id,
    required this.title,
    required this.time,
    required this.content,
    this.projectName,
    this.districtName,
    this.notes,
    this.assignedAt,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.isUnread = false,
    this.section = 'TERBARU',
    this.boldText,
  });

  String get displayTitle {
    if (title.isNotEmpty &&
        title != 'Penugasan Project' &&
        title != 'Penugasan Proyek' &&
        title != 'Notifikasi Penugasan') {
      return title;
    }
    return 'Penugasan Baru Diterima';
  }

  bool get hasAssignmentDetails {
    final hasProj = projectName != null &&
        projectName!.trim().isNotEmpty &&
        projectName!.trim() != '-' &&
        projectName!.trim().toLowerCase() != 'null';
    final hasDist = districtName != null &&
        districtName!.trim().isNotEmpty &&
        districtName!.trim() != '-' &&
        districtName!.trim().toLowerCase() != 'null';
    return hasProj || hasDist;
  }

  String? get cleanNotes {
    if (notes == null) return null;
    final trimmed = notes!.trim();
    if (trimmed.isEmpty || trimmed == '-' || trimmed.toLowerCase() == 'null') {
      return null;
    }
    return trimmed;
  }

  String get formattedDescription {
    final hasProj = projectName != null &&
        projectName!.trim().isNotEmpty &&
        projectName!.trim() != '-' &&
        projectName!.trim().toLowerCase() != 'null';

    final hasDist = districtName != null &&
        districtName!.trim().isNotEmpty &&
        districtName!.trim() != '-' &&
        districtName!.trim().toLowerCase() != 'null';

    if (hasProj && hasDist) {
      return 'Anda telah ditugaskan untuk proyek ${projectName!.trim()} di Area ${districtName!.trim()}.';
    } else if (hasProj) {
      return 'Anda telah ditugaskan untuk proyek ${projectName!.trim()}.';
    } else if (hasDist) {
      return 'Anda telah ditugaskan di Area ${districtName!.trim()}.';
    } else {
      if (content.isNotEmpty && !content.startsWith('Project:')) {
        return content;
      }
      return 'Anda telah ditugaskan untuk proyek baru.';
    }
  }

  String get formattedDate {
    if (assignedAt == null) return '';
    try {
      return DateFormat('dd MMMM yyyy', 'id_ID').format(assignedAt!.toLocal());
    } catch (_) {
      try {
        return DateFormat('dd MMMM yyyy').format(assignedAt!.toLocal());
      } catch (_) {
        return assignedAt!.toIso8601String().split('T').first;
      }
    }
  }

  static String formatHeaderTime(DateTime? dt) {
    if (dt == null) return 'Baru saja';
    final now = DateTime.now();
    final local = dt.toLocal();
    final diff = now.difference(local);

    if (diff.isNegative || diff.inSeconds < 60) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit yang lalu';
    }

    final today = DateTime(now.year, now.month, now.day);
    final notifDay = DateTime(local.year, local.month, local.day);
    final daysDiff = today.difference(notifDay).inDays;

    if (daysDiff == 0) {
      final hours = diff.inHours;
      return '$hours jam yang lalu';
    } else if (daysDiff == 1) {
      return 'Kemarin';
    } else if (daysDiff > 1 && daysDiff < 7) {
      return '$daysDiff hari yang lalu';
    } else {
      try {
        return DateFormat('dd MMM yyyy', 'id_ID').format(local);
      } catch (_) {
        return DateFormat('dd MMM yyyy').format(local);
      }
    }
  }

  static String resolveSection(DateTime? dt) {
    if (dt == null) return 'TERBARU';
    final now = DateTime.now();
    final local = dt.toLocal();
    if (now.day == local.day && now.month == local.month && now.year == local.year) {
      return 'TERBARU';
    }
    final diff = now.difference(local);
    if (diff.inHours < 24) {
      return 'TERBARU';
    }
    return 'SEBELUMNYA';
  }

  factory NotificationItem.fromModel(NotificationModel model) {
    final rawTitle = model.title;
    final title = (rawTitle.isEmpty ||
            rawTitle == 'Penugasan Project' ||
            rawTitle == 'Penugasan Proyek' ||
            rawTitle == 'Notifikasi Penugasan')
        ? 'Penugasan Baru Diterima'
        : rawTitle;

    return NotificationItem(
      id: model.id,
      title: title,
      time: model.assignedAt != null
          ? formatHeaderTime(model.assignedAt)
          : (model.time.isNotEmpty ? model.time : 'Baru saja'),
      content: model.content,
      projectName: model.projectName,
      districtName: model.districtName,
      notes: model.notes,
      assignedAt: model.assignedAt,
      isUnread: model.isUnread,
      section: resolveSection(model.assignedAt),
      boldText: model.boldText,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final bool unread = json['is_unread'] == true ||
        json['is_read'] == false ||
        json['read_at'] == null;
    DateTime? assignedDate;
    if (json['assigned_at'] != null) {
      assignedDate = DateTime.tryParse(json['assigned_at'].toString());
    }

    final rawTitle = json['title']?.toString();
    final title = (rawTitle == null ||
            rawTitle.isEmpty ||
            rawTitle == 'Penugasan Project' ||
            rawTitle == 'Penugasan Proyek' ||
            rawTitle == 'Notifikasi Penugasan')
        ? 'Penugasan Baru Diterima'
        : rawTitle;

    return NotificationItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: title,
      time: json['time'] ?? formatHeaderTime(assignedDate),
      content: json['content'] ?? json['message'] ?? '',
      projectName: json['project_name']?.toString() ?? json['project']?['name']?.toString(),
      districtName: json['district_name']?.toString() ?? json['district']?['name']?.toString(),
      notes: json['notes']?.toString(),
      assignedAt: assignedDate,
      isUnread: unread,
      section: json['section'] ?? resolveSection(assignedDate),
      boldText: json['bold_text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'content': content,
      'project_name': projectName,
      'district_name': districtName,
      'notes': notes,
      'assigned_at': assignedAt?.toIso8601String(),
      'is_unread': isUnread,
      'section': section,
      'bold_text': boldText,
    };
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback? onTap;
  final bool isTerbaru;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.isTerbaru = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool showBlueDot = isTerbaru;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EAF4), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Icon Circle Badge
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F1FC),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.assignment_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // 2. Content Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Title & Time / Status Indicator
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              notification.displayTitle,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                notification.time,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: showBlueDot
                                      ? AppColors.primary
                                      : const Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: showBlueDot
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                              if (showBlueDot) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Description Message / Assignment Details
                      if (notification.hasAssignmentDetails)
                        _buildAssignmentDetails()
                      else
                        _buildMessageText(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentDetails() {
    final description = notification.formattedDescription;
    final notes = notification.cleanNotes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 13.5,
            height: 1.45,
            fontWeight: FontWeight.w400,
          ),
        ),
        if (notes != null && notes.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.description_outlined,
                  size: 15,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Catatan: ',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: notes,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMessageText() {
    const regularStyle = TextStyle(
      color: Color(0xFF64748B),
      fontSize: 12.5,
      height: 1.4,
    );

    const boldStyle = TextStyle(
      color: Color(0xFF1E293B),
      fontSize: 12.5,
      fontWeight: FontWeight.bold,
      height: 1.4,
    );

    final content = notification.content;

    // Check for markdown bold syntax: **keyword**
    if (content.contains('**')) {
      final List<TextSpan> spans = [];
      final parts = content.split('**');
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].isEmpty) continue;
        if (i % 2 == 1) {
          spans.add(TextSpan(text: parts[i], style: boldStyle));
        } else {
          spans.add(TextSpan(text: parts[i], style: regularStyle));
        }
      }
      return Text.rich(TextSpan(children: spans));
    }

    // Check for boldText property
    final boldText = notification.boldText;
    if (boldText != null && boldText.isNotEmpty && content.contains(boldText)) {
      final parts = content.split(boldText);
      return Text.rich(
        TextSpan(
          style: regularStyle,
          children: [
            TextSpan(text: parts[0]),
            TextSpan(text: boldText, style: boldStyle),
            if (parts.length > 1) TextSpan(text: parts[1]),
          ],
        ),
      );
    }

    return Text(content, style: regularStyle);
  }
}
