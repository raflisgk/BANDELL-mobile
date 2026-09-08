import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/installation_model.dart';
import '../../services/auth_service.dart';
import '../../services/installation_service.dart';
import '../../services/project_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/dokumentasi.dart';
import '../../widgets/kode_panel.dart';
import '../../widgets/pop_up_sukses.dart';
import '../../widgets/tombol_simpan_data.dart';
import 'realtime_barcode.dart';
import 'realtime_location.dart';
import 'scan_barcode_page.dart';

class RealtimePage extends StatefulWidget {
  final int? idProject;
  final int? idArea;
  final String? areaName;
  final String? lampType;

  const RealtimePage({
    super.key,
    this.idProject,
    this.idArea,
    this.areaName,
    this.lampType,
  });

  @override
  State<RealtimePage> createState() => _RealtimePageState();
}

class _RealtimePageState extends State<RealtimePage> {
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _panelCodeController = TextEditingController();

  final FocusNode _latitudeFocusNode = FocusNode();
  final FocusNode _longitudeFocusNode = FocusNode();
  final FocusNode _panelCodeFocusNode = FocusNode();

  String? _scannedBarcode;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  final List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    _latitudeFocusNode.addListener(_onFocusChange);
    _longitudeFocusNode.addListener(_onFocusChange);
    _panelCodeFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _panelCodeController.dispose();

    _latitudeFocusNode.removeListener(_onFocusChange);
    _longitudeFocusNode.removeListener(_onFocusChange);
    _panelCodeFocusNode.removeListener(_onFocusChange);

    _latitudeFocusNode.dispose();
    _longitudeFocusNode.dispose();
    _panelCodeFocusNode.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleScanBarcode() async {
    debugPrint('Scan Barcode clicked');
    final String? result = await AppNavigator.push<String>(
      context,
      const ScanBarcodePage(),
    );

    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        _scannedBarcode = result.trim();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Barcode berhasil discan: $_scannedBarcode'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleGetLocation() async {
    if (_isLoadingLocation) return;
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Layanan lokasi (GPS) tidak aktif.'),
              backgroundColor: Color(0xFFDC2626),
            ),
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Izin akses lokasi ditolak.'),
                backgroundColor: Color(0xFFDC2626),
              ),
            );
          }
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin lokasi ditolak secara permanen.'),
              backgroundColor: Color(0xFFDC2626),
            ),
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mounted) {
        setState(() {
          _latitudeController.text = position.latitude.toStringAsFixed(6);
          _longitudeController.text = position.longitude.toStringAsFixed(6);
          _isLoadingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lokasi berhasil diperbarui dari GPS.'),
            backgroundColor: Color(0xFF16A34A),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting GPS location: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil lokasi: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  Future<void> _handleTambahFoto() async {
    if (_photos.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimal 4 foto dokumentasi.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _photos.add(image.path);
      });
    }
  }

  void _removePhoto(int index) {
    if (index >= 0 && index < _photos.length) {
      setState(() {
        _photos.removeAt(index);
      });
    }
  }

  Future<void> _handleSimpanData() async {
    if (_isSubmitting) return;

    final isProjectClosed =
        ProjectService.selectedProject?.status == 'closed' ||
            ProjectService.selectedProject?.status == 'selesai';
    if (isProjectClosed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat menyimpan data. Project telah Selesai.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    if (_scannedBarcode == null || _scannedBarcode!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan scan barcode terlebih dahulu.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    if (_latitudeController.text.isEmpty ||
        _longitudeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan ambil koordinat lokasi (GPS).'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final installationData = InstallationModel(
        idInstallation: 0,
        idProject: widget.idProject ?? ProjectService.selectedProject?.idProject,
        idUser: AuthService.currentUser?.idUser ?? 0,
        idArea: widget.idArea ?? 0,
        lampCode: _scannedBarcode!,
        lampType: widget.lampType ?? '',
        latitude: _latitudeController.text.trim(),
        longitude: _longitudeController.text.trim(),
        panelCode: _panelCodeController.text.trim().isNotEmpty
            ? _panelCodeController.text.trim()
            : null,
        photos: List.from(_photos),
        inputMethod: 'Realtime',
        status: 'Tersimpan',
        createdAt: DateTime.now(),
      );

      await InstallationService().createInstallation(installationData);

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        PopUpSukses.show(
          context,
          lampCode: _scannedBarcode!,
        );
      }
    } catch (e) {
      debugPrint('Error creating installation: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan data pendataan. Silakan coba lagi.'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              showDropdown: false,
              onBackPressed: _handleBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    // Header Title & Subtitle
                    const Center(
                      child: Text(
                        'Metode Input Real-time',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Center(
                      child: Text(
                        'Ambil data lampu secara langsung di lokasi',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 1. BARCODE SECTION
                    RealtimeBarcodeSection(
                      scannedBarcode: _scannedBarcode,
                      onScanBarcode: _handleScanBarcode,
                    ),

                    const SizedBox(height: 20),
                    const Divider(
                        color: Color(0xFFE2E8F0), height: 1, thickness: 1),
                    const SizedBox(height: 20),

                    // 2. LOKASI KOORDINAT SECTION (GPS)
                    RealtimeLocationSection(
                      latitudeController: _latitudeController,
                      longitudeController: _longitudeController,
                      latitudeFocusNode: _latitudeFocusNode,
                      longitudeFocusNode: _longitudeFocusNode,
                      isLoadingLocation: _isLoadingLocation,
                      onGetLocation: _handleGetLocation,
                    ),

                    const SizedBox(height: 20),
                    const Divider(
                        color: Color(0xFFE2E8F0), height: 1, thickness: 1),
                    const SizedBox(height: 20),

                    // 3. KODE PANEL SECTION
                    KodePanel(
                      controller: _panelCodeController,
                      focusNode: _panelCodeFocusNode,
                    ),

                    const SizedBox(height: 20),
                    const Divider(
                        color: Color(0xFFE2E8F0), height: 1, thickness: 1),
                    const SizedBox(height: 20),

                    // 4. DOKUMENTASI SECTION
                    Dokumentasi(
                      photos: _photos,
                      onAddPhoto: _handleTambahFoto,
                      onRemovePhoto: _removePhoto,
                    ),

                    const SizedBox(height: 28),

                    // 5. SIMPAN DATA BUTTON SECTION
                    TombolSimpanData(
                      isLoading: _isSubmitting,
                      onPressed: _handleSimpanData,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
