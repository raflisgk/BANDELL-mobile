import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/auth_service.dart';
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

  String _formatDate(String? value) {
    if (value == null || value.trim().isEmpty || value == '-') {
      return '-';
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    try {
      return DateFormat(
        'dd MMMM yyyy, HH:mm',
        'id_ID',
      ).format(date.toLocal());
    } catch (_) {
      return DateFormat(
        'dd MMMM yyyy, HH:mm',
      ).format(date.toLocal());
    }
  }

  String _formatUpdatedDate() {
    if (updatedAt == null ||
        updatedAt!.trim().isEmpty ||
        updatedAt == '-') {
      return '-';
    }

    if (createdAt != null && createdAt!.trim() == updatedAt!.trim()) {
      return '-';
    }

    final created = DateTime.tryParse(
      createdAt ?? '',
    );

    final updated = DateTime.tryParse(
      updatedAt!,
    );

    if (created == null || updated == null) {
      return _formatDate(updatedAt);
    }

    // Jika belum pernah diedit,
    // created_at dan updated_at sama.
    if (created.isAtSameMomentAs(updated) ||
        created.toLocal().isAtSameMomentAs(updated.toLocal())) {
      return '-';
    }

    return _formatDate(updatedAt);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveCreatedBy = (createdBy != null &&
            createdBy!.trim().isNotEmpty &&
            createdBy != '-')
        ? createdBy!.trim()
        : (AuthService.currentUser?.name ?? '-');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRecordInfoRow(
            label: 'Dibuat',
            value: _formatDate(createdAt),
          ),

          const SizedBox(height: 10),

          _buildRecordInfoRow(
            label: 'Terakhir diperbarui',
            value: _formatUpdatedDate(),
          ),

          const SizedBox(height: 10),

          _buildRecordInfoRow(
            label: 'Dibuat oleh',
            value: effectiveCreatedBy,
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

        const SizedBox(width: 16),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: isBoldValue
                  ? FontWeight.bold
                  : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}