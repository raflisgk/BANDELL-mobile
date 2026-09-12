import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';

class LampuHeaderCard extends StatelessWidget {
  final String code;
  final bool? isTersimpan;
  final dynamic updatedAt;

  const LampuHeaderCard({
    super.key,
    required this.code,
    this.isTersimpan,
    this.updatedAt,
  });

  String _formatUpdatedAt() {
    DateTime? date;
    if (updatedAt is DateTime) {
      date = updatedAt as DateTime;
    } else if (updatedAt is String &&
        (updatedAt as String).trim().isNotEmpty &&
        (updatedAt as String).trim() != '-') {
      date = DateTime.tryParse((updatedAt as String).trim());
    }

    if (date == null) {
      return 'Diperbarui -';
    }

    final localDate = date.toLocal();
    String formatted;
    try {
      formatted = DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(localDate);
    } catch (_) {
      formatted = DateFormat('dd MMM yyyy, HH:mm').format(localDate);
    }

    return 'Diperbarui $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      code.isNotEmpty ? code : '-',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Lamp Record',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.sync_rounded,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                _formatUpdatedAt(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
