import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class RealtimeBarcodeSection extends StatelessWidget {
  final String? scannedBarcode;
  final bool isInvalid;
  final VoidCallback onScanBarcode;

  const RealtimeBarcodeSection({
    super.key,
    required this.scannedBarcode,
    this.isInvalid = false,
    required this.onScanBarcode,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasScanned =
        scannedBarcode != null && scannedBarcode!.isNotEmpty;

    if (hasScanned || isInvalid) {
      final Color cardBg = isInvalid
          ? AppColors.popupRedLight
          : const Color(0xFFC7DBEC);
      final Color cardBorder = isInvalid
          ? const Color(0xFFFECACA)
          : const Color(0xFFA3C7E8);
      final Color iconCircleBg = isInvalid
          ? AppColors.error
          : const Color(0xFF16A34A);
      final IconData statusIcon = isInvalid
          ? Icons.close_rounded
          : Icons.check_rounded;
      final String statusTitle = isInvalid
          ? 'TIDAK TERIDENTIFIKASI'
          : 'TERIDENTIFIKASI';
      final Color titleColor = isInvalid
          ? AppColors.error
          : const Color(0xFF16A34A);
      final String statusSubtitle = isInvalid
          ? 'Kode panel tidak valid'
          : scannedBarcode!;
      final Color subtitleColor = isInvalid
          ? AppColors.textSecondary
          : const Color(0xFF1E2B45);
      final double subtitleSize = isInvalid ? 15.0 : 21.0;
      final FontWeight subtitleWeight = isInvalid
          ? FontWeight.w600
          : FontWeight.w800;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cardBorder,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconCircleBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                statusIcon,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    statusTitle,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusSubtitle,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: subtitleSize,
                      fontWeight: subtitleWeight,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: onScanBarcode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.15),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              label: const Text(
                'Scan Ulang',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0C5DA5),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Decorative Corner Brackets (Figma reticle styling)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0x66FFFFFF), width: 2),
                    left: BorderSide(color: Color(0x66FFFFFF), width: 2),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0x66FFFFFF), width: 2),
                    right: BorderSide(color: Color(0x66FFFFFF), width: 2),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0x66FFFFFF), width: 2),
                    left: BorderSide(color: Color(0x66FFFFFF), width: 2),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0x66FFFFFF), width: 2),
                    right: BorderSide(color: Color(0x66FFFFFF), width: 2),
                  ),
                ),
              ),
            ),

            // Content Row
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Row(
                children: [
                  const Icon(
                    Icons.qr_code_2_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Scan Barcode',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Pindai barcode / QR code pada lampu',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: onScanBarcode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(
                            Icons.qr_code_scanner,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            'Scan Barcode Disini',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
