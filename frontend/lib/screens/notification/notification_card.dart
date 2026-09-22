import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/notification_model.dart';
import '../../utils/app_colors.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final bool isTerbaru;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.isTerbaru = false,
  });

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
      return DateFormat('dd MMM yyyy').format(local);
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
    final project = notification.projectName.trim();
    final date = notification.formattedDate;

    final hasProject = project.isNotEmpty && project != '-';

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