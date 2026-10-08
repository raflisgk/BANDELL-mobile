import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';

// ==========================================
// 1. LAMPU HEADER CARD
// ==========================================
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
                decoration: const BoxDecoration(
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

// ==========================================
// 2. LOKASI CARD
// ==========================================
class LokasiCard extends StatelessWidget {
  final String? districtName;
  final String? latitude;
  final String? longitude;
  final String? coordinates;
  final String? address;

  const LokasiCard({
    super.key,
    this.districtName,
    this.latitude,
    this.longitude,
    this.coordinates,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDistrict =
        (districtName != null &&
            districtName!.trim().isNotEmpty &&
            districtName!.trim() != '-')
        ? districtName!.trim()
        : '-';

    String effectiveCoords;
    final lat = latitude?.trim();
    final lng = longitude?.trim();
    if (lat != null &&
        lng != null &&
        lat.isNotEmpty &&
        lng.isNotEmpty &&
        lat != '-' &&
        lng != '-') {
      effectiveCoords = '$lat, $lng';
    } else if (coordinates != null &&
        coordinates!.trim().isNotEmpty &&
        coordinates!.trim() != '-') {
      effectiveCoords = coordinates!.trim();
    } else {
      effectiveCoords = '-';
    }

    return Container(
      width: double.infinity,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.location_on_outlined,
              color: AppColors.textSubtle,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  effectiveDistrict,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  effectiveCoords,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. INFORMASI LAMPU CARD
// ==========================================
class InformasiLampuCard extends StatelessWidget {
  final String code;
  final String type;
  final String? panelCode;
  final String status;
  final String inputMethod;

  const InformasiLampuCard({
    super.key,
    required this.code,
    required this.type,
    this.panelCode,
    required this.status,
    required this.inputMethod,
  });

  @override
  Widget build(BuildContext context) {
    final String method = inputMethod.trim().toLowerCase();
    final bool isRealtime = method == 'realtime' || method == 'real-time';

    final String methodText = isRealtime
        ? 'Realtime'
        : method == 'manual'
        ? 'Manual'
        : '-';

    final IconData methodIcon = isRealtime
        ? Icons.bolt_rounded
        : Icons.edit_note_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSubtle,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  label: 'TIPE LAMPU',
                  value: type.isNotEmpty ? type : '-',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _StatusItem(status: status)),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoItem(
                  label: 'KODE PANEL',
                  value: panelCode != null && panelCode!.trim().isNotEmpty
                      ? panelCode!.trim()
                      : '-',
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: _MethodItem(
                  label: 'METODE INPUT',
                  icon: methodIcon,
                  value: methodText,
                  isRealtime: isRealtime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.hintColor,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String status;

  const _StatusItem({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.trim().toLowerCase();
    final bool isDitolak = s == 'ditolak' || s == 'rejected';
    final bool isVerified = s == 'terverifikasi' || s == 'verified' || s == 'terinput';

    final Color dotColor = isDitolak
        ? AppColors.statusDitolakText
        : (isVerified ? AppColors.success : AppColors.warning);

    final String displayStatus = isDitolak
        ? 'Ditolak'
        : (isVerified
              ? 'Terverifikasi'
              : (status.trim().isNotEmpty ? status : '-'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'STATUS LAMPU',
          style: TextStyle(
            color: AppColors.hintColor,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                displayStatus,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MethodItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final bool isRealtime;

  const _MethodItem({
    required this.label,
    required this.icon,
    required this.value,
    required this.isRealtime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.hintColor,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 36,
              height: 30,
              decoration: BoxDecoration(
                color: isRealtime
                    ? AppColors.successLight
                    : AppColors.manualBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isRealtime ? AppColors.success : AppColors.manualOrange,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ==========================================
// 4. BARCODE CARD
// ==========================================
class BarcodeCard extends StatelessWidget {
  final String? barcode;

  const BarcodeCard({
    super.key,
    this.barcode,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BARCODE',
                style: TextStyle(
                  color: AppColors.hintColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                (barcode != null && barcode!.isNotEmpty && barcode != '-')
                    ? barcode!
                    : '-',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. INFORMASI RECORD CARD
// ==========================================
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

    final created = DateTime.tryParse(createdAt ?? '');
    final updated = DateTime.tryParse(updatedAt!);

    if (created == null || updated == null) {
      return _formatDate(updatedAt);
    }

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

// ==========================================
// 6. CATATAN PENOLAKAN CARD (ALASAN PENOLAKAN)
// ==========================================
class CatatanPenolakanCard extends StatelessWidget {
  final String? note;

  const CatatanPenolakanCard({
    super.key,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveNote = (note != null && note!.trim().isNotEmpty && note != '-')
        ? note!.trim()
        : 'Tidak ada catatan penolakan spesifik dari admin.';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.statusDitolakBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.statusDitolakBorder,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12DC2626),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.statusDitolakCircleBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_rounded,
                  color: AppColors.statusDitolakText,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATUS: DITOLAK',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.statusDitolakText,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Catatan dari Admin',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHeading,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.statusDitolakBorder,
                width: 1.2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3.5,
                  height: 20,
                  margin: const EdgeInsets.only(right: 10, top: 1),
                  decoration: BoxDecoration(
                    color: AppColors.statusDitolakText,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Text(
                    effectiveNote,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
