import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'manual_page.dart';
import 'realtime_page.dart';

class MetodePendataanPage extends StatelessWidget {
  const MetodePendataanPage({super.key});

  void _handleBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _handleSelectRealtime(BuildContext context) {
    debugPrint('Realtime dipilih');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RealtimePage(),
      ),
    );
  }

  void _handleSelectManual(BuildContext context) {
    debugPrint('Manual dipilih');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManualPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Header: Back Arrow Icon
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => _handleBack(context),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),

              const SizedBox(height: 24),

              // Centered Title & Subtitle
              const Center(
                child: Text(
                  'Pilih Metode Input',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Bagaimana Anda ingin menambahkan data\nlampu?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Card 1: Realtime
              _buildRealtimeCard(context),

              const SizedBox(height: 20),

              // Card 2: Manual
              _buildManualCard(context),

              const SizedBox(height: 24),

              // Information / Tips Card
              _buildTipsCard(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealtimeCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.realtimeBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.realtimeBorder,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleSelectRealtime(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Icon & Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.realtimeBorder,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppColors.realtimeGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Realtime',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Description
                const Text(
                  'Gunakan kamera dan GPS untuk mendapatkan data lampu secara langsung dari lokasi.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Features Checklist
                _buildCheckFeature(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Scan Barcode',
                  color: AppColors.realtimeGreen,
                ),
                const SizedBox(height: 6),
                _buildCheckFeature(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'GPS Otomatis',
                  color: AppColors.realtimeGreen,
                ),
                const SizedBox(height: 6),
                _buildCheckFeature(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Lokasi Terkini',
                  color: AppColors.realtimeGreen,
                ),

                const SizedBox(height: 16),
                const Divider(color: AppColors.realtimeBorder, height: 1),
                const SizedBox(height: 14),

                // Card Action Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Gunakan Realtime',
                      style: TextStyle(
                        color: AppColors.realtimeGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.realtimeGreen,
                      size: 20,
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

  Widget _buildManualCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.manualBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.manualBorder,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleSelectManual(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Icon & Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.manualBorder,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.keyboard_outlined,
                        color: AppColors.manualOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Manual',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Description
                const Text(
                  'Masukkan koordinat, alamat, dan informasi lampu secara manual.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Features Checklist
                _buildCheckFeature(
                  icon: Icons.bolt_rounded,
                  label: 'Input Long / Lat',
                  color: AppColors.manualOrange,
                ),
                const SizedBox(height: 6),
                _buildCheckFeature(
                  icon: Icons.bolt_rounded,
                  label: 'Input Address',
                  color: AppColors.manualOrange,
                ),
                const SizedBox(height: 6),
                _buildCheckFeature(
                  icon: Icons.bolt_rounded,
                  label: 'Dokumentasi Manual',
                  color: AppColors.manualOrange,
                ),

                const SizedBox(height: 16),
                const Divider(color: AppColors.manualBorder, height: 1),
                const SizedBox(height: 14),

                // Card Action Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Gunakan Manual',
                      style: TextStyle(
                        color: AppColors.manualOrange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.manualOrange,
                      size: 20,
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

  Widget _buildCheckFeature({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.infoBorder,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.infoBlue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Tips: ',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
                children: const [
                  TextSpan(
                    text:
                        'Gunakan Realtime jika barcode dan GPS tersedia. Pilih Manual jika Anda perlu memasukkan data secara langsung karena kendala sinyal atau perangkat.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
