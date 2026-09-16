import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../utils/app_colors.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/custom_feedback_message.dart';
import '../edit_data_lampu/edit_data_lampu_page.dart';


class ScanBarcodePage extends StatefulWidget {
  const ScanBarcodePage({super.key});

  @override
  State<ScanBarcodePage> createState() => _ScanBarcodePageState();
}


class _ScanBarcodePageState extends State<ScanBarcodePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final MobileScannerController _cameraController;

  late AnimationController _spinController;

  bool _isScanned = false;
  bool _isTorchOn = false;


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      returnImage: false,
      autoStart: false,
    );

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _startCamera();
  }


  Future<void> _startCamera() async {
    try {
      if (!_cameraController.value.isRunning && !_isScanned) {
        await _cameraController.start();
      }
    } catch (e) {
      debugPrint('Error starting camera: $e');
    }
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_cameraController.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;

      case AppLifecycleState.resumed:
        if (!_isScanned && !_cameraController.value.isRunning) {
          _startCamera();
        }
        break;

      case AppLifecycleState.inactive:
        _cameraController.stop();
        break;
    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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

      if (mounted) {
        setState(() {
          _isTorchOn = !_isTorchOn;
        });
      }
    } catch (e) {
      debugPrint('Error toggling flashlight: $e');
    }
  }


  Future<void> _handleGallery() async {
    if (_isScanned) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);

      if (!mounted || file == null) {
        // User membatalkan pemilihan foto
        return;
      }

      final BarcodeCapture? barcodeCapture =
          await _cameraController.analyzeImage(file.path);

      if (!mounted) return;

      String? foundCode;
      if (barcodeCapture != null && barcodeCapture.barcodes.isNotEmpty) {
        for (final barcode in barcodeCapture.barcodes) {
          final String? value = barcode.rawValue ?? barcode.displayValue;
          if (value != null && value.trim().isNotEmpty) {
            foundCode = value.trim();
            break;
          }
        }
      }

      if (foundCode != null) {
        _handleScanResult(foundCode);
      } else {
        if (mounted) {
          CustomFeedbackMessage.showError(
            context,
            'Barcode tidak ditemukan pada gambar.',
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking or analyzing image: $e');
      if (mounted) {
        CustomFeedbackMessage.showError(
          context,
          'Gagal membaca gambar barcode.',
        );
      }
    }
  }

  void _handleScanResult(String scannedCode) {
    if (_isScanned) return;

    setState(() {
      _isScanned = true;
    });

    _spinController.stop();
    _cameraController.stop();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      if (Navigator.canPop(context)) {
        Navigator.pop(context, scannedCode);
      } else {
        AppNavigator.pushReplacement(
          context,
          EditDataLampuPage(
            scannedCode: scannedCode,
          ),
        );
      }
    });
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      final String? value =
          barcode.rawValue ?? barcode.displayValue;

      if (value != null && value.trim().isNotEmpty) {
        _handleScanResult(value.trim());
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

                // HEADER
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
                        padding:
                            const EdgeInsets.only(right: 28.0),
                        child: const Text(
                          'Scan Barcode',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 56),

                // SCANNER
                _buildScannerFrame(),

                // JARAK DARI SCANNER KE TEKS
                const SizedBox(height: 90),

                // INSTRUCTION
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
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11.5,
                  ),
                ),

                const SizedBox(height: 36),

                // CONTROLS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // FLASHLIGHT
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
                          color: _isTorchOn
                              ? Colors.black
                              : Colors.white,
                          size: 22,
                        ),
                      ),
                    ),

                    const SizedBox(width: 32),

                    // SCANNING INDICATOR
                    _buildCenterScanningButton(),

                    const SizedBox(width: 32),

                    // GALLERY
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

                const SizedBox(height: 32),
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
        // OUTER FRAME
        Container(
          width: 310,
          height: 310,
          decoration: const BoxDecoration(),
          child: Stack(
            children: [
              // TOP LEFT
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.scanCyan,
                        width: 4.0,
                      ),
                      left: BorderSide(
                        color: AppColors.scanCyan,
                        width: 4.0,
                      ),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                    ),
                  ),
                ),
              ),

              // TOP RIGHT
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.scanCyan,
                        width: 4.0,
                      ),
                      right: BorderSide(
                        color: AppColors.scanCyan,
                        width: 4.0,
                      ),
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(14),
                    ),
                  ),
                ),
              ),

              // BOTTOM LEFT
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.scanCyan,
                        width: 4.0,
                      ),
                      left: BorderSide(
                        color: AppColors.scanCyan,
                        width: 4.0,
                      ),
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
              ),

              // BOTTOM RIGHT
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.scanCyan,
                        width: 4.0,
                      ),
                      right: BorderSide(
                        color: AppColors.scanCyan,
                        width: 4.0,
                      ),
                    ),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // LIVE CAMERA
        Container(
          width: 286,
          height: 286,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.scanIconDark,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: MobileScanner(
              controller: _cameraController,
              fit: BoxFit.cover,
              onDetect: _onDetect,

              placeholderBuilder: (context, child) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.scanCyan,
                    strokeWidth: 2.5,
                  ),
                );
              },

              errorBuilder: (context, error, child) {
                String errorMessage =
                    'Kamera tidak dapat dibuka. Pastikan izin kamera telah diberikan.';

                if (error.errorCode ==
                    MobileScannerErrorCode.permissionDenied) {
                  errorMessage =
                      'Izin kamera belum diberikan. Aktifkan izin kamera pada Pengaturan HP untuk memindai barcode.';
                }

                return Container(
                  color: AppColors.scanCardDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.videocam_off_rounded,
                        color: Colors.white54,
                        size: 36,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 12),

                      InkWell(
                        onTap: _startCamera,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.scanCyan,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Coba Lagi',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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