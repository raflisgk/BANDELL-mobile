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
import '../../widgets/custom_feedback_message.dart';
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
  final int? lampTypeId;

  const RealtimePage({
  super.key,
  this.idProject,
  this.idArea,
  this.areaName,
  this.lampType,
  this.lampTypeId,
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
          setState(() {
            _isLoadingLocation = false;
          });
          CustomFeedbackMessage.showError(
            context,
            'Layanan lokasi (GPS) tidak aktif.',
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _isLoadingLocation = false;
            });
            CustomFeedbackMessage.showError(
              context,
              'Izin akses lokasi ditolak.',
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
          CustomFeedbackMessage.showError(
            context,
            'Izin lokasi ditolak secara permanen.',
          );
        }
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
      }
    } catch (e) {
      debugPrint('Error getting GPS location: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        CustomFeedbackMessage.showError(
          context,
          'Gagal mengambil lokasi GPS.',
        );
      }
    }
  }

  void _handleTambahFoto() {
    if (_photos.length >= 4) {
      CustomFeedbackMessage.showError(
        context,
        'Maksimal 4 foto sudah tercapai.',
      );
      return;
    }

    _showPhotoSourcePicker();
  }

  void _showPhotoSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tambah Foto Dokumentasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: AppColors.primary),
                  ),
                  title: const Text(
                    'Ambil Foto Kamera',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle:
                      const Text('Buka kamera untuk mengambil foto baru'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library_rounded,
                        color: AppColors.primary),
                  ),
                  title: const Text(
                    'Pilih dari Galeri',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Buka galeri hp untuk memilih foto'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _photos.add(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        CustomFeedbackMessage.showError(
          context,
          'Gagal mengambil foto.',
        );
      }
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
      CustomFeedbackMessage.showError(
        context,
        'Tidak dapat menyimpan data. Project telah Selesai.',
      );
      return;
    }

    final projectId =
        widget.idProject ?? ProjectService.selectedProject?.idProject;
    if (projectId == null || projectId <= 0) {
      CustomFeedbackMessage.showError(
        context,
        'Project belum dipilih.',
      );
      return;
    }

    final areaId = widget.idArea ?? 0;
    if (areaId <= 0) {
      CustomFeedbackMessage.showError(
        context,
        'Area operasional belum dipilih.',
      );
      return;
    }

    final userId = AuthService.currentUser?.idUser ?? 0;
    if (userId <= 0) {
      CustomFeedbackMessage.showError(
        context,
        'Sesi pengguna tidak valid. Silakan login kembali.',
      );
      return;
    }

    final lampTypeId = widget.lampTypeId;
    if ((lampTypeId == null || lampTypeId <= 0) &&
        (widget.lampType == null || widget.lampType!.trim().isEmpty)) {
      CustomFeedbackMessage.showError(
        context,
        'Jenis lampu belum dipilih.',
      );
      return;
    }

    if (_scannedBarcode == null || _scannedBarcode!.trim().isEmpty) {
      CustomFeedbackMessage.showError(
        context,
        'Silakan scan barcode terlebih dahulu.',
      );
      return;
    }

    if (_scannedBarcode!.trim().length > 12) {
      CustomFeedbackMessage.showError(
        context,
        'ID Barcode (LCU) maksimal 12 karakter.',
      );
      return;
    }

    if (_latitudeController.text.trim().isEmpty ||
        _longitudeController.text.trim().isEmpty) {
      CustomFeedbackMessage.showError(
        context,
        'Silakan ambil koordinat lokasi (GPS).',
      );
      return;
    }

    if (_panelCodeController.text.trim().length > 12) {
      CustomFeedbackMessage.showError(
        context,
        'Kode panel maksimal 12 karakter.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final installationData = InstallationModel(
        idInstallation: 0,
        idProject: projectId,
        idUser: userId,
        idArea: areaId,
        lampTypeId: lampTypeId,
        lampCode: _scannedBarcode!.trim(),
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

        CustomFeedbackMessage.showSuccess(
          context,
          'Data berhasil disimpan',
        );

        PopUpSukses.show(
          context,
          lampCode: _scannedBarcode!,
          onAddData: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        );
      }
    } catch (e) {
      debugPrint('Error creating installation: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        final errorMsg = e.toString().replaceFirst('Exception: ', '').trim();
        CustomFeedbackMessage.showError(
          context,
          errorMsg.isNotEmpty ? errorMsg : 'Data gagal disimpan',
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
