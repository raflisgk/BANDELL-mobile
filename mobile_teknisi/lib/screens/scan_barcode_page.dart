import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'manual_page.dart';

class ScanBarcodePage extends StatefulWidget {
  const ScanBarcodePage({super.key});

  @override
  State<ScanBarcodePage> createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage> {
  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _handleFlashlight() {
    debugPrint('Flashlight clicked');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Flashlight (Simulasi UI)'),
        backgroundColor: AppColors.scanCardDark,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleGallery() {
    debugPrint('Gallery clicked');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gallery (Simulasi UI)'),
        backgroundColor: AppColors.scanCardDark,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleInputManual() {
    debugPrint('Input ID Manual clicked');
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
      backgroundColor: AppColors.scanBackgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                // Header Row: Back Arrow & Centered Title
                Row(
                  children: [
                    IconButton(
                      onPressed: _handleBack,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.scanCyan,
                        size: 28,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 28.0),
                        child: Column(
                          children: const [
                            Text(
                              'Scan Barcode',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Project Jakarta',
                              style: TextStyle(
                                color: AppColors.cardTextSubtle,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // Scanner Frame with Glowing Corners
                _buildScannerFrame(),

                const SizedBox(height: 32),

                // Instruction Texts
                const Text(
                  'Scan Barcode Lampu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Arahkan kamera ke barcode atau QR code pada\nlampu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pastikan barcode berada di dalam area scan.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11.5,
                  ),
                ),

                const SizedBox(height: 36),

                // Controls Row: Flash, Scanning Indicator, Gallery
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Flashlight Button
                    GestureDetector(
                      onTap: _handleFlashlight,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.scanCardDark,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.scanIconDark,
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.flashlight_on_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),

                    const SizedBox(width: 32),

                    // Center SCANNING... Indicator
                    Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.scanCardDark,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.scanCyan,
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.scanCyanLight,
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E293B),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'SCANNING...',
                          style: TextStyle(
                            color: AppColors.scanCyan,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 32),

                    // Gallery Button
                    GestureDetector(
                      onTap: _handleGallery,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.scanCardDark,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.scanIconDark,
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // Manual Input Link Footer
                GestureDetector(
                  onTap: _handleInputManual,
                  child: Text.rich(
                    TextSpan(
                      text: 'Tidak dapat memindai barcode? ',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12.5,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Masukkan ID\nsecara manual',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScannerFrame() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer L-corner indicators box
        Container(
          width: 270,
          height: 270,
          decoration: const BoxDecoration(),
          child: Stack(
            children: [
              // Top Left Corner
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.scanCyan, width: 3.5),
                      left: BorderSide(color: AppColors.scanCyan, width: 3.5),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                    ),
                  ),
                ),
              ),
              // Top Right Corner
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.scanCyan, width: 3.5),
                      right: BorderSide(color: AppColors.scanCyan, width: 3.5),
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                    ),
                  ),
                ),
              ),
              // Bottom Left Corner
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.scanCyan, width: 3.5),
                      left: BorderSide(color: AppColors.scanCyan, width: 3.5),
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
              ),
              // Bottom Right Corner
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.scanCyan, width: 3.5),
                      right: BorderSide(color: AppColors.scanCyan, width: 3.5),
                    ),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Inner dark scanner box
        Container(
          width: 246,
          height: 246,
          decoration: BoxDecoration(
            color: AppColors.scanCardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.scanIconDark,
              width: 1,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.qr_code_2_rounded,
              color: AppColors.scanIconDark,
              size: 88,
            ),
          ),
        ),
      ],
    );
  }
}
