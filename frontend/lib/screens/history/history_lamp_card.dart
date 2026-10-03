import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/history_lamp_model.dart';
import '../../services/project_service.dart';
import '../../utils/app_colors.dart';

class HistoryLampCard extends StatelessWidget {
  final HistoryLampModel item;
  final VoidCallback? onTap;

  const HistoryLampCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool hasPhotos = !item.fotoCount.toLowerCase().contains('belum');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.historyCardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowFaint,
            blurRadius: 8,
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
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Kode & Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.kode.isNotEmpty
                                ? item.kode
                                : ((item.idLcu != null &&
                                          item.idLcu!.trim().isNotEmpty)
                                      ? item.idLcu!
                                      : '-'),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.jenis,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(),
                  ],
                ),

                const SizedBox(height: 12),

                // Lokasi & Koordinat Row (Baris 1: Icon + Nama District, Baris 2: Latitude, Longitude)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textSubtle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getDistrictName(),
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _getCoordinates(),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const Divider(
                  color: AppColors.divider,
                  height: 1,
                  thickness: 1,
                ),

                const SizedBox(height: 10),

                // Bottom Row: Foto & Waktu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Foto info
                    Row(
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 15,
                          color: hasPhotos
                              ? AppColors.accentBlue
                              : AppColors.manualOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.fotoCount,
                          style: TextStyle(
                            color: hasPhotos
                                ? AppColors.accentBlue
                                : AppColors.manualOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Waktu info (HANYA gunakan created_at sesuai aturan)
                    Text(
                      _formatWaktu(item.createdAt ?? item.installation?.createdAt),
                      style: const TextStyle(
                        color: AppColors.textSubtle,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatWaktu(DateTime? createdAt) {
    if (createdAt == null) return '-';
    final local = createdAt.isUtc ? createdAt.toLocal() : createdAt;
    try {
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(local);
    } catch (_) {
      return DateFormat('dd MMM yyyy, HH:mm').format(local);
    }
  }

  Widget _buildStatusBadge() {
    if (item.isMenungguJaringan ||
        item.status.trim().toLowerCase().contains('menunggu jaringan')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFDBA74), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.wifi_off_rounded,
              size: 13,
              color: Color(0xFFEA580C),
            ),
            SizedBox(width: 4),
            Text(
              'Menunggu Jaringan',
              style: TextStyle(
                color: Color(0xFFEA580C),
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (item.isDitolak) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.statusDitolakBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.cancel_outlined,
              size: 13,
              color: AppColors.statusDitolakText,
            ),
            SizedBox(width: 4),
            Text(
              'Ditolak',
              style: TextStyle(
                color: AppColors.statusDitolakText,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (item.isVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.statusTerverifikasiBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 13,
              color: AppColors.realtimeGreen,
            ),
            SizedBox(width: 4),
            Text(
              'Terverifikasi',
              style: TextStyle(
                color: AppColors.realtimeGreen,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.statusMenungguBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.warning_amber_rounded,
              size: 13,
              color: AppColors.statusRevisiText,
            ),
            SizedBox(width: 4),
            Text(
              'Menunggu Verifikasi',
              style: TextStyle(
                color: AppColors.statusRevisiText,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }

  String _getDistrictName() {
    final rawName = (item.districtName != null &&
            item.districtName!.trim().isNotEmpty &&
            item.districtName!.trim() != '-')
        ? item.districtName!.trim()
        : (item.installation?.districtName != null &&
                item.installation!.districtName!.trim().isNotEmpty &&
                item.installation!.districtName!.trim() != '-')
            ? item.installation!.districtName!.trim()
            : null;

    if (rawName != null) return rawName;

    final areaId = item.areaId;
    final projectId = item.projectId;
    return ProjectService.getAreaName(projectId, areaId) ?? '-';
  }

  String _getCoordinates() {
    final lat = item.latitude ?? item.installation?.latitude;
    final lng = item.longitude ?? item.installation?.longitude;
    if (lat != null &&
        lng != null &&
        lat.trim().isNotEmpty &&
        lng.trim().isNotEmpty &&
        lat.trim() != '-' &&
        lng.trim() != '-') {
      return '${lat.trim()}, ${lng.trim()}';
    }
    if (item.koordinat.trim().isNotEmpty && item.koordinat.trim() != '-') {
      return item.koordinat.trim();
    }
    return '-';
  }
}
