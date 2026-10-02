import 'package:flutter/material.dart';

import '../../models/notification_model.dart';
import '../../utils/app_colors.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isExpanded;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.isExpanded = false,
    this.onTap,
  });

  static String formatHeaderTime(DateTime? dt) {
    if (dt == null) return 'Baru saja';

    final now = DateTime.now();
    final local = dt.toLocal();
    final diff = now.difference(local);

    final today = DateTime(now.year, now.month, now.day);
    final notifDay = DateTime(local.year, local.month, local.day);
    final daysDiff = today.difference(notifDay).inDays;

    final hourStr = local.hour.toString().padLeft(2, '0');
    final minStr = local.minute.toString().padLeft(2, '0');
    final timeStr = '$hourStr:$minStr';

    // Hari ini (notif dibuat hari ini)
    if (daysDiff == 0) {
      if (diff.inMinutes < 1) {
        return 'Baru saja';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes} menit yang lalu';
      } else {
        return '${diff.inHours} jam yang lalu';
      }
    } else if (daysDiff == 1) {
      // Kemarin baru jamnya
      return 'Kemarin $timeStr';
    } else {
      // 2 hari yang lalu atau lebih lama: tanggal bulan tahun sama jamnya
      final day = local.day.toString().padLeft(2, '0');
      final month = _monthName(local.month);
      final year = local.year;
      return '$day $month $year $timeStr';
    }
  }

  static String formatFullDateTime(DateTime? dt) {
    if (dt == null) return '-';
    final local = dt.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = _monthName(local.month);
    final y = local.year;
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$d $m $y • $h:$min WIB';
  }

  static String _monthName(int month) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return (month >= 1 && month <= 12) ? months[month] : '';
  }

  @override
  Widget build(BuildContext context) {
    final bool isAssignment =
        notification.notificationType == NotificationType.assignment;

    final Color iconBg = isAssignment
        ? AppColors
              .notifUnreadAvatarBg // Soft light blue circle
        : AppColors.statusDitolakCircleBg; // Soft light pink/red circle

    final Color iconColor = isAssignment ? AppColors.primary : AppColors.error;

    final IconData iconData = isAssignment
        ? Icons.assignment_rounded
        : Icons.close_rounded;

    final String timeText = notification.time.isNotEmpty
        ? notification.time
        : formatHeaderTime(notification.createdAt ?? notification.assignedAt);

    final Color badgeBg = isAssignment
        ? AppColors.roleBadgeBackground
        : AppColors.statusDitolakCircleBg;

    final Color badgeTextColor = isAssignment
        ? AppColors.primary
        : AppColors.error;

    final String badgeLabel = isAssignment ? 'Penugasan' : 'Ditolak';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (isExpanded) ...[
            BoxShadow(
              color: (isAssignment ? AppColors.primary : AppColors.error)
                  .withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
            const BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ] else
            const BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 12,
              offset: Offset(0, 3),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================== TOP SUMMARY ROW ====================
                Row(
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
                        child: Icon(iconData, color: iconColor, size: 22),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title, Badge, Time, and Chevron
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Title & Unread indicator
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  notification.displayTitle,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textHeading,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                              const SizedBox(width: 6),
                              AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOutCubic,
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 22,
                                  color: isExpanded
                                      ? (isAssignment
                                            ? AppColors.primary
                                            : AppColors.error)
                                      : AppColors.textSubtle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),

                          // Badge Type & Relative Time
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  badgeLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: badgeTextColor,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                timeText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Message description
                          Text(
                            notification.displayMessage,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: AppColors.textBody,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ==================== EXPANDED DETAIL SECTION ====================
                ClipRect(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOutCubic,
                    alignment: Alignment.topCenter,
                    child: isExpanded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: AppColors.borderLight,
                                ),
                              ),
                              if (isAssignment)
                                _buildAssignmentDetail(context)
                              else
                                _buildRejectedDetail(context),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Detail section untuk Notifikasi Penugasan
  Widget _buildAssignmentDetail(BuildContext context) {
    final String projectName =
        notification.projectName.isNotEmpty && notification.projectName != '-'
        ? notification.projectName
        : 'Proyek';

    final String rawNotes = (() {
      final raw = notification.cleanNotes ?? notification.notes;
      if (raw == null || raw.trim().isEmpty) return '';
      return raw
          .replaceFirst(RegExp(r'^catatan:\s*', caseSensitive: false), '')
          .trim();
    })();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Box Nama Proyek (Navy elegan)
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardPrimary,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.domain_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NAMA PROYEK',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      projectName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 2. Catatan / Instruksi Khusus
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.notifSubCardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight, width: 1),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'CATATAN KHUSUS',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textHeading,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                rawNotes.isNotEmpty
                    ? rawNotes
                    : 'Tidak ada catatan khusus dari admin.',
                style: TextStyle(
                  fontSize: 13,
                  color: rawNotes.isNotEmpty
                      ? AppColors.textDark
                      : AppColors.textMuted,
                  height: 1.4,
                  fontStyle: rawNotes.isNotEmpty
                      ? FontStyle.normal
                      : FontStyle.italic,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Detail section untuk Notifikasi Laporan Ditolak
  Widget _buildRejectedDetail(BuildContext context) {
    final String projectName =
        notification.projectName.isNotEmpty && notification.projectName != '-'
        ? notification.projectName
        : 'Laporan Proyek';

    final String district = notification.district.isNotEmpty
        ? notification.district
        : '-';

    final String idLcu = notification.idLcu.isNotEmpty
        ? notification.idLcu
        : '-';

    final String noteText = (() {
      final rawAdminNote =
          notification.noteByAdmin?.trim() ??
          notification.installation?.note_by_admin?.trim() ??
          notification.installation?.noteByAdmin?.trim() ??
          (notification.notificationType == NotificationType.rejected
              ? notification.message?.trim()
              : null) ??
          notification.notes?.trim();
      if (rawAdminNote != null &&
          rawAdminNote.isNotEmpty &&
          rawAdminNote != '-' &&
          rawAdminNote.toLowerCase() != 'null') {
        return rawAdminNote
            .replaceFirst(RegExp(r'^(catatan:\s*|Catatan:\s*)', caseSensitive: false), '')
            .trim();
      }
      final clean = notification.cleanNotes;
      if (clean != null && clean.isNotEmpty) {
        return clean
            .replaceFirst(RegExp(r'^catatan:\s*', caseSensitive: false), '')
            .trim();
      }
      return 'Tidak ada catatan penolakan spesifik dari admin.';
    })();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Box Proyek & Status Ditolak
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.statusDitolakCircleBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: AppColors.error,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STATUS LAPORAN: DITOLAK',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      projectName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHeading,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 2. Detail Pemasangan (Lokasi & ID LCU)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight, width: 1),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DETAIL PEMASANGAN',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHeading,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 15,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      district,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textHeading,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_2_rounded,
                    size: 15,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'ID LCU: $idLcu',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 3. Alasan Penolakan dari Admin
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.statusDitolakCircleBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.cancel_outlined, size: 15, color: AppColors.error),
                  SizedBox(width: 6),
                  Text(
                    'ALASAN PENOLAKAN DARI ADMIN',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                noteText,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textDark,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
