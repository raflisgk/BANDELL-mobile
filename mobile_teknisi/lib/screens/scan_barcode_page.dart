import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/app_colors.dart';
import 'form_pendataan_page.dart';
import 'manual_page.dart';

class ScanBarcodePage extends StatefulWidget {
  const ScanBarcodePage({super.key});

  @override
  State<ScanBarcodePage> createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  late AnimationController _spinController;

  bool _isScanned = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleFlashlight() async {
    try {
      await _cameraController.toggleTorch();
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    } catch (e) {
      debugPrint('Error toggling flashlight: $e');
    }
  }

  void _handleGallery() {
    debugPrint('Gallery clicked');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pilih foto dari galeri (Fitur mendatang)'),
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

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? value = barcode.rawValue ?? barcode.displayValue;
      if (value != null && value.trim().isNotEmpty) {
        setState(() {
          _isScanned = true;
        });
        _spinController.stop();
        _cameraController.stop();

        // Tampilkan centang sejenak sebelum pindah ke Form Pendataan
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FormPendataanPage(
                  scannedCode: value.trim(),
                ),
              ),
            );
          }
        });
        break;
      }
    }
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

                // Scanner Frame with Real Camera
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
                          color: _isTorchOn
                              ? AppColors.scanCyan
                              : AppColors.scanCardDark,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isTorchOn
                                ? AppColors.scanCyan
                                : AppColors.scanIconDark,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          _isTorchOn
                              ? Icons.flashlight_on_rounded
                              : Icons.flashlight_off_rounded,
                          color: _isTorchOn ? Colors.black : Colors.white,
                          size: 22,
                        ),
                      ),
                    ),

                    const SizedBox(width: 32),

                    // Center SCANNING... Indicator with continuous rotation and automatic checkmark
                    _buildCenterScanningButton(),

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

  Widget _buildCenterScanningButton() {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isScanned
              ? Container(
                  key: const ValueKey('scanned_check'),
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.scanCyan,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.scanCyanLight,
                        blurRadius: 18,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                )
              : RotationTransition(
                  key: const ValueKey('scanning_spinner'),
                  turns: _spinController,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          Colors.transparent,
                          Color(0x3338BDF8),
                          AppColors.scanCyan,
                        ],
                        stops: [0.0, 0.6, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.scanCyanLight,
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.scanCardDark,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E293B),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 10),
        Text(
          _isScanned ? 'TERDETEKSI' : 'SCANNING...',
          style: const TextStyle(
            color: AppColors.scanCyan,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
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

        // Inner live camera scanner box
        Container(
          width: 246,
          height: 246,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.scanIconDark,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: MobileScanner(
              controller: _cameraController,
              onDetect: _onDetect,
              errorBuilder: (context, error, child) {
                return Container(
                  color: AppColors.scanCardDark,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.videocam_off_rounded,
                        color: Colors.white54,
                        size: 40,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Izin kamera diperlukan untuk memindai barcode.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
