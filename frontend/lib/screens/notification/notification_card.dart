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
    return 'Penugasan Baru Diterima';
  }

  String? get cleanNotes {
    if (notes == null) return null;

    final trimmed = notes!.trim();

    if (trimmed.isEmpty ||
        trimmed == '-' ||
        trimmed.toLowerCase() == 'null') {
      return null;
    }

    return trimmed;
  }

  String get formattedDescription {
    final hasProj = projectName != null &&
        projectName!.trim().isNotEmpty &&
        projectName!.trim() != '-' &&
        projectName!.trim().toLowerCase() != 'null';

    if (hasProj && assignedAt != null) {
      return 'Anda telah ditugaskan untuk proyek ${projectName!.trim()} pada tanggal $formattedDate.';
    }

    if (hasProj) {
      return 'Anda telah ditugaskan untuk proyek ${projectName!.trim()}.';
    }

    if (content.isNotEmpty && !content.startsWith('Project:')) {
      return content;
    }

    return 'Anda telah ditugaskan untuk proyek baru.';
  }

  String get formattedDate {
    if (assignedAt == null) return '';

    try {
      return DateFormat(
        'dd/MM/yyyy',
      ).format(assignedAt!.toLocal());
    } catch (_) {
      return assignedAt!.toLocal().toIso8601String().split('T').first;
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
    final notifDay = DateTime(
      local.year,
      local.month,
      local.day,
    );

    final daysDiff = today.difference(notifDay).inDays;

    if (daysDiff == 0) {
      final hours = diff.inHours;
      return '$hours jam yang lalu';
    } else if (daysDiff == 1) {
      return 'Kemarin';
    } else if (daysDiff > 1 && daysDiff < 7) {
      return '$daysDiff hari yang lalu';
    }

    try {
      return DateFormat(
        'dd MMM yyyy',
      ).format(local);
    } catch (_) {
      return local.toIso8601String().split('T').first;
    }
  }

  static String resolveSection(DateTime? dt) {
    if (dt == null) return 'TERBARU';

    final now = DateTime.now();
    final local = dt.toLocal();

    final diff = now.difference(local);

    if (diff.isNegative || diff.inHours < 24) {
      return 'TERBARU';
    }

    return 'SEBELUMNYA';
  }

  factory NotificationItem.fromModel(
    NotificationModel model,
  ) {
    return NotificationItem(
      id: model.id,
      title: 'Penugasan Baru Diterima',
      time: model.assignedAt != null
          ? formatHeaderTime(model.assignedAt)
          : (model.time.isNotEmpty
              ? model.time
              : 'Baru saja'),
      content: model.content,
      projectName: model.projectName,
      notes: model.notes,
      assignedAt: model.assignedAt,
      isUnread: model.isUnread,
      section: resolveSection(model.assignedAt),
      boldText: model.boldText,
    );
  }

  factory NotificationItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final bool unread =
        json['is_unread'] == true ||
        json['is_read'] == false ||
        json['is_read'] == 0 ||
        (json.containsKey('read_at') && json['read_at'] == null);

    DateTime? assignedDate;

    if (json['assigned_at'] != null) {
      assignedDate = DateTime.tryParse(
        json['assigned_at'].toString(),
      );
    }

    return NotificationItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(
                json['id']?.toString() ?? '0',
              ) ??
              0,
      title: 'Penugasan Baru Diterima',
      time: json['time']?.toString() ??
          formatHeaderTime(assignedDate),
      content: json['content']?.toString() ??
          json['message']?.toString() ??
          '',
      projectName:
          json['project_name']?.toString() ??
          json['project']?['name']?.toString(),
      notes: json['notes']?.toString(),
      assignedAt: assignedDate,
      isUnread: unread,
      section:
          json['section']?.toString() ??
          resolveSection(assignedDate),
      boldText: json['bold_text']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'content': content,
      'project_name': projectName,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE1EAF5),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
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
            padding: const EdgeInsets.fromLTRB(
              18,
              18,
              18,
              20,
            ),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ICON
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3FF),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.assignment_outlined,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // CONTENT
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // TITLE
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 18,
                            ),
                            child: Text(
                              notification.displayTitle,
                              style: const TextStyle(
                                color: Color(0xFF172033),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.25,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // DESCRIPTION
                          _buildDescription(),

                          const SizedBox(height: 12),

                          // TIME
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                color: AppColors.primary,
                                size: 17,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                notification.time,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          // NOTES
                          if (notification.cleanNotes != null) ...[
                            const SizedBox(height: 14),
                            _buildNotes(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                // BLUE DOT
                if (isTerbaru && notification.isUnread)
                  Positioned(
                    top: 1,
                    right: 1,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFEAF3FF),
                          width: 3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    final project = notification.projectName?.trim();
    final date = notification.formattedDate;

    final hasProject = project != null &&
        project.isNotEmpty &&
        project != '-';

    if (!hasProject) {
      return Text(
        notification.content,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 14.5,
          height: 1.5,
        ),
      );
    }

    return Text.rich(
      TextSpan(
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 14.5,
          height: 1.5,
        ),
        children: [
          const TextSpan(
            text: 'Anda telah ditugaskan untuk proyek ',
          ),
          TextSpan(
            text: project,
            style: const TextStyle(
              color: Color(0xFF172033),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (date.isNotEmpty)
            TextSpan(
              text: ' pada tanggal $date.',
            )
          else
            const TextSpan(
              text: '.',
            ),
        ],
      ),
    );
  }

  Widget _buildNotes() {
    final notes = notification.cleanNotes!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD9E9FF),
          width: 1,
        ),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: 'Catatan: ',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: notes,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}