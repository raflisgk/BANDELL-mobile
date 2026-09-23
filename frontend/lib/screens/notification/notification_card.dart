import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../utils/app_colors.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
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

    return '${notifDay.day}/${notifDay.month}/${notifDay.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isAssignment =
        notification.notificationType == NotificationType.assignment;

    final Color iconBg = isAssignment
        ? const Color(0xFFE2EFFC) // Soft light blue circle
        : const Color(0xFFFDE2E2); // Soft light pink/red circle

    final Color iconColor = isAssignment
        ? AppColors.primary
        : AppColors.error;

    final IconData iconData = isAssignment
        ? Icons.assignment_rounded
        : Icons.close_rounded;

    final String timeText = notification.time.isNotEmpty
        ? notification.time
        : formatHeaderTime(notification.assignedAt ?? notification.createdAt);

    final Color timeColor = isAssignment
        ? AppColors.primary
        : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8EEF5),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
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

                // Main Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Title, Time, Unread Dot
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              notification.displayTitle,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeText,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isAssignment
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                              color: timeColor,
                            ),
                          ),
                          if (notification.isUnread) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Description
                      Text(
                        notification.displayMessage,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF475569),
                          height: 1.35,
                        ),
                      ),

                      // Catatan container (only if notes available)
                      if (notification.cleanNotes != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F2FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            notification.cleanNotes!,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
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
}