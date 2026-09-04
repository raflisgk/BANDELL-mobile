import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class HistoryLampItem {
  final int? idHistory;
  final int userId;
  final int projectId;
  final int? areaId;
  final String kode;
  final String jenis;
  final String status;
  final bool isVerified;
  final String lokasi;
  final String koordinat;
  final String fotoCount;
  final String waktu;
  final DateTime? tanggal;

  const HistoryLampItem({
    this.idHistory,
    required this.userId,
    required this.projectId,
    this.areaId,
    required this.kode,
    required this.jenis,
    required this.status,
    required this.isVerified,
    required this.lokasi,
    required this.koordinat,
    required this.fotoCount,
    required this.waktu,
    this.tanggal,
  });
}

class HistoryLampCard extends StatelessWidget {
  final HistoryLampItem item;
  final VoidCallback? onTap;

  const HistoryLampCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPhotos = !item.fotoCount.toLowerCase().contains('belum');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
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
                            item.kode,
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
                              color: Color(0xFF64748B),
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

                // Lokasi & Koordinat Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.lokasi,
                            style: const TextStyle(
                              color: Color(0xFF334155),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.koordinat,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(
                  color: Color(0xFFF1F5F9),
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
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFEA580C),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.fotoCount,
                          style: TextStyle(
                            color: hasPhotos
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFEA580C),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Waktu info
                    Text(
                      item.waktu,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
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

  Widget _buildStatusBadge() {
    if (item.isVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 13,
              color: Color(0xFF16A34A),
            ),
            SizedBox(width: 4),
            Text(
              'Terverifikasi',
              style: TextStyle(
                color: Color(0xFF16A34A),
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
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.warning_amber_rounded,
              size: 13,
              color: Color(0xFFD97706),
            ),
            SizedBox(width: 4),
            Text(
              'Menunggu Verifikasi',
              style: TextStyle(
                color: Color(0xFFD97706),
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }
}
