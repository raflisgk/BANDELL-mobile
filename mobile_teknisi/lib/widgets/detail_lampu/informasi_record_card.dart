import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class InformasiRecordCard extends StatelessWidget {
  final String? createdAt;
  final String? updatedAt;
  final String? createdBy;

  const InformasiRecordCard({
    super.key,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
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
        children: [
          _buildRecordInfoRow(
            label: 'Dibuat',
            value: createdAt ?? '-',
          ),
          const SizedBox(height: 10),
          _buildRecordInfoRow(
            label: 'Terakhir diperbarui',
            value: updatedAt ?? '-',
          ),
          const SizedBox(height: 10),
          _buildRecordInfoRow(
            label: 'Dibuat oleh',
            value: createdBy ?? '-',
            isBoldValue: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordInfoRow({
    required String label,
    required String value,
    bool isBoldValue = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
