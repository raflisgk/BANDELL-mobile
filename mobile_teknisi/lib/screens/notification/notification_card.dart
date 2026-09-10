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

  bool get hasAssignmentDetails =>
      (projectName != null && projectName!.isNotEmpty && projectName != '-') ||
      (districtName != null && districtName!.isNotEmpty && districtName != '-');

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

  static String _formatHeaderTime(DateTime? dt) {
    if (dt == null) return 'Baru saja';
    final now = DateTime.now();
    final local = dt.toLocal();
    final diff = now.difference(local);

    if (diff.inMinutes < 1) {
      return 'Baru saja';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} mnt lalu';
    } else if (diff.inDays == 0 && now.day == local.day) {
      try {
        return DateFormat('HH:mm').format(local);
      } catch (_) {
        return '${local.hour}:${local.minute.toString().padLeft(2, '0')}';
      }
    } else if (diff.inDays < 7) {
      try {
        return DateFormat('dd MMM', 'id_ID').format(local);
      } catch (_) {
        return DateFormat('dd MMM').format(local);
      }
    } else {
      try {
        return DateFormat('dd/MM/yy').format(local);
      } catch (_) {
        return '${local.day}/${local.month}';
      }
    }
  }

  static String _resolveSection(DateTime? dt) {
    if (dt == null) return 'TERBARU';
    final now = DateTime.now();
    final diff = now.difference(dt.toLocal());
    if (diff.inDays <= 1) {
      return 'TERBARU';
    }
    return 'SEBELUMNYA';
  }

  factory NotificationItem.fromModel(NotificationModel model) {
    return NotificationItem(
      id: model.id,
      title: model.title,
      time: model.time.isNotEmpty ? model.time : _formatHeaderTime(model.assignedAt),
      content: model.content,
      projectName: model.projectName,
      districtName: model.districtName,
      notes: model.notes,
      assignedAt: model.assignedAt,
      isUnread: model.isUnread,
      section: _resolveSection(model.assignedAt),
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

    return NotificationItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? 'Penugasan Project',
      time: json['time'] ?? _formatHeaderTime(assignedDate),
      content: json['content'] ?? json['message'] ?? '',
      projectName: json['project_name']?.toString() ?? json['project']?['name']?.toString(),
      districtName: json['district_name']?.toString() ?? json['district']?['name']?.toString(),
      notes: json['notes']?.toString(),
      assignedAt: assignedDate,
      isUnread: unread,
      section: json['section'] ?? _resolveSection(assignedDate),
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

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _resolveIcon();
    final iconColor = _resolveIconColor();
    final iconBgColor = _resolveIconBgColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Icon Circle Badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      iconData,
                      color: iconColor,
                      size: 22,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                height: 1.25,
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
                                  color: notification.isUnread
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontSize: notification.isUnread ? 11.5 : 11,
                                  fontWeight: notification.isUnread
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                              if (notification.isUnread) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (notification.projectName != null &&
            notification.projectName!.isNotEmpty &&
            notification.projectName != '-')
          _buildDetailRow('Project', notification.projectName!),
        if (notification.districtName != null &&
            notification.districtName!.isNotEmpty &&
            notification.districtName != '-') ...[
          const SizedBox(height: 3),
          _buildDetailRow('Area', notification.districtName!),
        ],
        if (notification.notes != null &&
            notification.notes!.trim().isNotEmpty &&
            notification.notes != '-') ...[
          const SizedBox(height: 3),
          _buildDetailRow('Catatan', notification.notes!),
        ],
        if (notification.formattedDate.isNotEmpty) ...[
          const SizedBox(height: 3),
          _buildDetailRow('Tanggal', notification.formattedDate),
        ],
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12.5,
          height: 1.35,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageText() {
    const regularStyle = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 12.5,
      height: 1.4,
    );

    const boldStyle = TextStyle(
      color: AppColors.textPrimary,
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
      return RichText(text: TextSpan(children: spans));
    }

    // Check for boldText property
    final boldText = notification.boldText;
    if (boldText != null && boldText.isNotEmpty && content.contains(boldText)) {
      final parts = content.split(boldText);
      return RichText(
        text: TextSpan(
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

  IconData _resolveIcon() {
    if (notification.icon != null) return notification.icon!;

    final lowerTitle = notification.title.toLowerCase();
    if (lowerTitle.contains('penugasan') || lowerTitle.contains('project') || lowerTitle.contains('tugas')) {
      return Icons.assignment_outlined;
    } else if (lowerTitle.contains('terkirim') || lowerTitle.contains('selesai')) {
      return Icons.assignment_turned_in_rounded;
    } else if (lowerTitle.contains('menunggu') || lowerTitle.contains('verifikasi')) {
      return Icons.pending_actions_rounded;
    } else if (lowerTitle.contains('setuju') || lowerTitle.contains('sukses')) {
      return Icons.check_circle_rounded;
    } else if (lowerTitle.contains('tolak') || lowerTitle.contains('catatan')) {
      return Icons.error_outline_rounded;
    }

    return notification.isUnread
        ? Icons.assignment_outlined
        : Icons.notifications_none_rounded;
  }

  Color _resolveIconColor() {
    if (notification.iconColor != null) return notification.iconColor!;

    final lowerTitle = notification.title.toLowerCase();
    if (lowerTitle.contains('penugasan') || lowerTitle.contains('project') || lowerTitle.contains('tugas')) {
      return AppColors.primary;
    } else if (lowerTitle.contains('setuju') || lowerTitle.contains('sukses')) {
      return AppColors.realtimeGreen;
    } else if (lowerTitle.contains('menunggu') || lowerTitle.contains('verifikasi')) {
      return AppColors.textSecondary;
    } else if (lowerTitle.contains('tolak') || lowerTitle.contains('catatan')) {
      return AppColors.error;
    }

    return notification.isUnread ? AppColors.primary : AppColors.textSecondary;
  }

  Color _resolveIconBgColor() {
    if (notification.iconBackgroundColor != null) {
      return notification.iconBackgroundColor!;
    }

    final lowerTitle = notification.title.toLowerCase();
    if (lowerTitle.contains('penugasan') || lowerTitle.contains('project') || lowerTitle.contains('tugas')) {
      return AppColors.infoBackground;
    } else if (lowerTitle.contains('setuju') || lowerTitle.contains('sukses')) {
      return AppColors.realtimeBackground;
    } else if (lowerTitle.contains('menunggu') || lowerTitle.contains('verifikasi')) {
      return AppColors.inputBackground;
    } else if (lowerTitle.contains('tolak') || lowerTitle.contains('catatan')) {
      return AppColors.popupRedLight;
    }

    return notification.isUnread
        ? AppColors.infoBackground
        : AppColors.inputBackground;
  }
}
