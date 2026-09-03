import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class LampuHeaderCard extends StatelessWidget {
  final String code;
  final bool isTersimpan;
  final String? updatedAt;

  const LampuHeaderCard({
    super.key,
    required this.code,
    required this.isTersimpan,
    this.updatedAt,
  });

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        code,
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
                ],
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isTersimpan
                      ? AppColors.successLight
                      : AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isTersimpan
                          ? Icons.check_circle_outline_rounded
                          : Icons.warning_amber_rounded,
                      color:
                          isTersimpan ? AppColors.success : AppColors.warning,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isTersimpan ? 'Tersimpan' : 'Belum Lengkap',
                      style: TextStyle(
                        color: isTersimpan
                            ? AppColors.success
                            : AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
                Icons.history_rounded,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                updatedAt ?? '-',
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
