import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/installation_model.dart';
import '../../services/auth_service.dart';
import '../../services/installation_service.dart';
import '../../services/project_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/catatan.dart';
import '../../widgets/custom_feedback.dart';
import '../../widgets/dokumentasi.dart';
import '../../widgets/kode_panel.dart';
import '../../widgets/pop_up_sukses.dart';
import '../../widgets/pilih_tanggal.dart';
import '../../widgets/tombol_simpan_data.dart';
import '../metode_pendataan/metode_pendataan_page.dart';

class ManualPage extends StatefulWidget {
  final int? idProject;
  final int? idArea;
  final String? areaName;
  final String? lampType;
  final int? lampTypeId;

  const ManualPage({
    super.key,
    this.idProject,
    this.idArea,
    this.areaName,
    this.lampType,
    this.lampTypeId,
  });

  @override
  State<ManualPage> createState() => _ManualPageState();
}

class _ManualPageState extends State<ManualPage>
    with TickerProviderStateMixin {
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _panelCodeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  final FocusNode _barcodeFocusNode = FocusNode();
  final FocusNode _panelCodeFocusNode = FocusNode();
  final FocusNode _notesFocusNode = FocusNode();
  final FocusNode _latitudeFocusNode = FocusNode();
  final FocusNode _longitudeFocusNode = FocusNode();

  DateTime? _installationDate;
  String? _dateError;

  bool _isSubmitting = false;
  final List<String> _photos = [];
  String? _coordinateError;

  AnimationController? _shakeController;
  Animation<double>? _shakeAnimation;
  bool _isBarcodeExceeded = false;
  Timer? _barcodeErrorTimer;

  AnimationController? _locationShakeController;
  Animation<double>? _locationShakeAnimation;
  bool _isLatitudeExceeded = false;
  Timer? _latitudeErrorTimer;
  bool _isLongitudeExceeded = false;
  Timer? _longitudeErrorTimer;

  void _initShakeAnimation() {
    _shakeController ??= AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _shakeAnimation ??= TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: -2.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController!,
      curve: Curves.easeInOut,
    ));

    _locationShakeController ??= AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _locationShakeAnimation ??= TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: -2.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _locationShakeController!,
      curve: Curves.easeInOut,
    ));
  }

  AnimationController get _effectiveShakeController {
    if (_shakeController == null) _initShakeAnimation();
    return _shakeController!;
  }

  Animation<double> get _effectiveShakeAnimation {
    if (_shakeAnimation == null) _initShakeAnimation();
    return _shakeAnimation!;
  }

  AnimationController get _effectiveLocationShakeController {
    if (_locationShakeController == null) _initShakeAnimation();
    return _locationShakeController!;
  }

  Animation<double> get _effectiveLocationShakeAnimation {
    if (_locationShakeAnimation == null) _initShakeAnimation();
    return _locationShakeAnimation!;
  }

  @override
  void initState() {
    super.initState();
    _initShakeAnimation();

    _barcodeFocusNode.addListener(_onFocusChange);
    _barcodeController.addListener(_onBarcodeChanged);
    _panelCodeFocusNode.addListener(_onFocusChange);
    _notesFocusNode.addListener(_onFocusChange);
    _latitudeFocusNode.addListener(_onFocusChange);
    _longitudeFocusNode.addListener(_onFocusChange);
    _latitudeController.addListener(_onCoordinateChanged);
    _latitudeController.addListener(_onLatitudeChanged);
    _longitudeController.addListener(_onCoordinateChanged);
    _longitudeController.addListener(_onLongitudeChanged);
  }

  void _onBarcodeChanged() {
    if (_isBarcodeExceeded && _barcodeController.text.length < 11) {
      _barcodeErrorTimer?.cancel();
      setState(() {
        _isBarcodeExceeded = false;
      });
    }
  }

  void _onBarcodeLimitExceeded() {
    _barcodeErrorTimer?.cancel();
    if (!_isBarcodeExceeded) {
      setState(() {
        _isBarcodeExceeded = true;
      });
    }
    _effectiveShakeController.forward(from: 0.0);

    // Otomatis kembalikan ke warna normal & hapus tulisan merah setelah berhenti mengetik
    _barcodeErrorTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted && _isBarcodeExceeded) {
        setState(() {
          _isBarcodeExceeded = false;
        });
      }
    });
  }

  void _onLatitudeChanged() {
    if (_isLatitudeExceeded && _latitudeController.text.length < 10) {
      _latitudeErrorTimer?.cancel();
      setState(() {
        _isLatitudeExceeded = false;
      });
    }
  }

  void _onLatitudeLimitExceeded() {
    _latitudeErrorTimer?.cancel();
    if (!_isLatitudeExceeded) {
      setState(() {
        _isLatitudeExceeded = true;
      });
    }
    _effectiveLocationShakeController.forward(from: 0.0);

    // Otomatis kembalikan ke warna normal & hapus tulisan merah setelah berhenti mengetik
    _latitudeErrorTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted && _isLatitudeExceeded) {
        setState(() {
          _isLatitudeExceeded = false;
        });
      }
    });
  }

  void _onLongitudeChanged() {
    if (_isLongitudeExceeded && _longitudeController.text.length < 11) {
      _longitudeErrorTimer?.cancel();
      setState(() {
        _isLongitudeExceeded = false;
      });
    }
  }

  void _onLongitudeLimitExceeded() {
    _longitudeErrorTimer?.cancel();
    if (!_isLongitudeExceeded) {
      setState(() {
        _isLongitudeExceeded = true;
      });
    }
    _effectiveLocationShakeController.forward(from: 0.0);

    // Otomatis kembalikan ke warna normal & hapus tulisan merah setelah berhenti mengetik
    _longitudeErrorTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted && _isLongitudeExceeded) {
        setState(() {
          _isLongitudeExceeded = false;
        });
      }
    });
  }

  void _onFocusChange() {
    if (!_barcodeFocusNode.hasFocus && _isBarcodeExceeded) {
      _barcodeErrorTimer?.cancel();
      _isBarcodeExceeded = false;
    }
    if (!_latitudeFocusNode.hasFocus && _isLatitudeExceeded) {
      _latitudeErrorTimer?.cancel();
      _isLatitudeExceeded = false;
    }
    if (!_longitudeFocusNode.hasFocus && _isLongitudeExceeded) {
      _longitudeErrorTimer?.cancel();
      _isLongitudeExceeded = false;
    }
    setState(() {});
  }

  void _onCoordinateChanged() {
    if (_coordinateError != null) {
      final lat = _latitudeController.text.trim();
      final lng = _longitudeController.text.trim();
      if (_isValidCoordinate(lat, lng)) {
        setState(() {
          _coordinateError = null;
        });
      }
    }
  }

  bool _isLatitudeValid(String latStr) {
    final text = latStr.replaceAll(',', '.').trim();
    if (text.isEmpty) return false;
    final lat = double.tryParse(text);
    if (lat == null) return false;
    return lat >= -90.0 && lat <= 90.0;
  }

  bool _isLongitudeValid(String lngStr) {
    final text = lngStr.replaceAll(',', '.').trim();
    if (text.isEmpty) return false;
    final lng = double.tryParse(text);
    if (lng == null) return false;
    return lng >= -180.0 && lng <= 180.0;
  }

  bool _isValidCoordinate(String latStr, String lngStr) {
    return _isLatitudeValid(latStr) && _isLongitudeValid(lngStr);
  }

  @override
  void dispose() {
    _barcodeErrorTimer?.cancel();
    _latitudeErrorTimer?.cancel();
    _longitudeErrorTimer?.cancel();
    _shakeController?.dispose();
    _locationShakeController?.dispose();
    _barcodeController.removeListener(_onBarcodeChanged);
    _barcodeController.dispose();
    _panelCodeController.dispose();
    _notesController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();

    _barcodeFocusNode.removeListener(_onFocusChange);
    _panelCodeFocusNode.removeListener(_onFocusChange);
    _notesFocusNode.removeListener(_onFocusChange);
    _latitudeFocusNode.removeListener(_onFocusChange);
    _longitudeFocusNode.removeListener(_onFocusChange);
    _latitudeController.removeListener(_onCoordinateChanged);
    _latitudeController.removeListener(_onLatitudeChanged);
    _longitudeController.removeListener(_onCoordinateChanged);
    _longitudeController.removeListener(_onLongitudeChanged);

    _barcodeFocusNode.dispose();
    _panelCodeFocusNode.dispose();
    _notesFocusNode.dispose();
    _latitudeFocusNode.dispose();
    _longitudeFocusNode.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
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
                const Divider(height: 1),
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
    setState(() {
      _photos.removeAt(index);
    });
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

    final barcode = _barcodeController.text.trim();
    final latitude = _latitudeController.text.trim();
    final longitude = _longitudeController.text.trim();

    if (barcode.isEmpty) {
      CustomFeedbackMessage.showError(
        context,
        'ID Barcode wajib diisi.',
      );
      _barcodeFocusNode.requestFocus();
      return;
    }

    if (barcode.length > 11) {
      CustomFeedbackMessage.showError(
        context,
        'ID Barcode maksimal 11 karakter.',
      );
      _barcodeFocusNode.requestFocus();
      return;
    }

    if (latitude.length > 10) {
      CustomFeedbackMessage.showError(
        context,
        'Latitude maksimal 10 karakter.',
      );
      _latitudeFocusNode.requestFocus();
      return;
    }

    if (longitude.length > 11) {
      CustomFeedbackMessage.showError(
        context,
        'Longitude maksimal 11 karakter.',
      );
      _longitudeFocusNode.requestFocus();
      return;
    }

    if (!_isValidCoordinate(latitude, longitude)) {
      setState(() {
        _coordinateError = '⚠️ Koordinat tidak valid';
      });
      if (!_isLatitudeValid(latitude)) {
        _latitudeFocusNode.requestFocus();
      } else {
        _longitudeFocusNode.requestFocus();
      }
      return;
    } else {
      if (_coordinateError != null) {
        setState(() {
          _coordinateError = null;
        });
      }
    }

    if (_panelCodeController.text.trim().length > 12) {
      CustomFeedbackMessage.showError(
        context,
        'Kode panel maksimal 12 karakter.',
      );
      _panelCodeFocusNode.requestFocus();
      return;
    }

    if (_installationDate == null) {
      setState(() {
        _dateError = 'Tanggal penugasan wajib diisi';
      });
      CustomFeedbackMessage.showError(
        context,
        'Tanggal penugasan wajib diisi.',
      );
      return;
    } else {
      if (_dateError != null) {
        setState(() {
          _dateError = null;
        });
      }
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
        lampTypeId: widget.lampTypeId,
        lampCode: barcode,
        lampType: widget.lampType ?? '',
        latitude: latitude.replaceAll(',', '.'),
        longitude: longitude.replaceAll(',', '.'),
        panelCode: _panelCodeController.text.trim().isNotEmpty
            ? _panelCodeController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        photos: List.from(_photos),
        inputMethod: 'Manual',
        status: 'Tersimpan',
        installedAt: _installationDate,
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

        _showSuccessDialog(barcode);
      }
    } catch (e) {
      debugPrint('Error creating manual installation: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        String errorMsg = e.toString().replaceFirst('Exception: ', '').trim();
        final lower = errorMsg.toLowerCase();
        if (lower.contains('sqlstate') ||
            lower.contains('numeric value out of range') ||
            lower.contains('queryexception') ||
            lower.contains('connection: mysql') ||
            lower.contains('database error')) {
          errorMsg = 'Data gagal disimpan. Terjadi kesalahan pada server.';
        }
        CustomFeedbackMessage.showError(
          context,
          errorMsg.isNotEmpty ? errorMsg : 'Data gagal disimpan',
        );
      }
    }
  }

  void _showSuccessDialog(String barcode) {
    final String lampCode = barcode.isNotEmpty
        ? barcode
        : (_panelCodeController.text.isNotEmpty
            ? _panelCodeController.text
            : '');

    PopUpSukses.show(
      context,
      lampCode: lampCode,
      onAddData: () {
        Navigator.popUntil(
          context,
          ModalRoute.withName(MetodePendataanPage.routeName),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTopBar(
                showDropdown: false,
                onBackPressed: _handleBack,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    // Centered Header Title & Subtitle
                    const Center(
                      child: Text(
                        'Metode Input Manual',
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
                        'Ambil data lampu secara manual',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Single Large White Form Container Matching Figma
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. ID BARCODE
                          _buildBarcodeInput(),

                          const SizedBox(height: 18),
                          const Divider(
                              color: Color(0xFFF1F5F9),
                              height: 1,
                              thickness: 1),
                          const SizedBox(height: 18),

                          // 2. KODE PANEL (SHARED WIDGET)
                          KodePanel(
                            controller: _panelCodeController,
                            focusNode: _panelCodeFocusNode,
                          ),

                          const SizedBox(height: 18),
                          const Divider(
                              color: Color(0xFFF1F5F9),
                              height: 1,
                              thickness: 1),
                          const SizedBox(height: 18),

                          // 3. LOKASI KOORDINAT (MANUAL INPUTS)
                          _buildLocationSection(),

                          const SizedBox(height: 18),
                          const Divider(
                              color: Color(0xFFF1F5F9),
                              height: 1,
                              thickness: 1),
                          const SizedBox(height: 18),

                          // 4. TANGGAL PENUGASAN (SHARED WIDGET)
                          TanggalPemasangan(
                            title: 'Tanggal Penugasan',
                            subtitle: 'Masukkan tanggal penugasan',
                            selectedDate: _installationDate,
                            onDateSelected: (date) {
                              setState(() {
                                _installationDate = date;
                                _dateError = null;
                              });
                            },
                            errorMessage: _dateError,
                          ),

                          const SizedBox(height: 18),
                          const Divider(
                              color: Color(0xFFF1F5F9),
                              height: 1,
                              thickness: 1),
                          const SizedBox(height: 18),

                          // 5. CATATAN (SHARED WIDGET)
                          Catatan(
                            controller: _notesController,
                            focusNode: _notesFocusNode,
                          ),

                          const SizedBox(height: 18),
                          const Divider(
                              color: Color(0xFFF1F5F9),
                              height: 1,
                              thickness: 1),
                          const SizedBox(height: 18),

                          // 6. DOKUMENTASI (SHARED WIDGET)
                          Dokumentasi(
                            photos: _photos,
                            onAddPhoto: _handleTambahFoto,
                            onRemovePhoto: _removePhoto,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 5. TOMBOL SIMPAN DATA (SHARED WIDGET)
                    TombolSimpanData(
                      isLoading: _isSubmitting,
                      onPressed: _handleSimpanData,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. ID Barcode Section
  Widget _buildBarcodeInput() {
    final bool isFocused = _barcodeFocusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _effectiveShakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_effectiveShakeAnimation.value, 0),
              child: child,
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _isBarcodeExceeded
                      ? AppColors.errorLight
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.wb_incandescent_outlined,
                  color: _isBarcodeExceeded
                      ? AppColors.error
                      : AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ID Barcode',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Masukkan kode barcode',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isFocused ? Colors.white : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isBarcodeExceeded
                  ? AppColors.error
                  : (isFocused ? AppColors.primary : AppColors.border),
              width: _isBarcodeExceeded || isFocused ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: _barcodeController,
            focusNode: _barcodeFocusNode,
            inputFormatters: [
              _BarcodeLimitFormatter(
                maxLength: 11,
                onExceeded: _onBarcodeLimitExceeded,
              ),
            ],
            style: TextStyle(
              color: _isBarcodeExceeded
                  ? AppColors.error
                  : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              hintText: 'Contoh: JKT-2025-001',
              hintStyle: TextStyle(
                color: AppColors.hintColor,
                fontSize: 14,
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        if (_isBarcodeExceeded) ...[
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.only(left: 2.0),
            child: Text(
              'Maksimal 11 karakter',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // 3. Lokasi Koordinat Section (Manual Lat/Long Inputs, No Get Location Button)
  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_coordinateError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
            child: Text(
              _coordinateError!,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
          ),
        AnimatedBuilder(
          animation: _effectiveLocationShakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_effectiveLocationShakeAnimation.value, 0),
              child: child,
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (_isLatitudeExceeded || _isLongitudeExceeded)
                      ? AppColors.errorLight
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.language,
                  color: (_isLatitudeExceeded || _isLongitudeExceeded)
                      ? AppColors.error
                      : AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Lokasi Koordinat',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '*',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Masukkan koordinat lampu (Lat/Long)',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 14),
        _buildLocationInputField(
          controller: _latitudeController,
          focusNode: _latitudeFocusNode,
          hint: 'Latitude',
          maxLength: 10,
          isExceeded: _isLatitudeExceeded,
          onExceeded: _onLatitudeLimitExceeded,
          hasError: _coordinateError != null &&
              !_isLatitudeValid(_latitudeController.text),
        ),
        const SizedBox(height: 10),
        _buildLocationInputField(
          controller: _longitudeController,
          focusNode: _longitudeFocusNode,
          hint: 'Longitude',
          maxLength: 11,
          isExceeded: _isLongitudeExceeded,
          onExceeded: _onLongitudeLimitExceeded,
          hasError: _coordinateError != null &&
              !_isLongitudeValid(_longitudeController.text),
        ),
      ],
    );
  }

  Widget _buildLocationInputField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String hint,
    required int maxLength,
    bool isExceeded = false,
    VoidCallback? onExceeded,
    bool hasError = false,
  }) {
    final bool isFocused = focusNode?.hasFocus ?? false;

    final borderColor = isExceeded
        ? AppColors.error
        : (hasError
            ? const Color(0xFFEF4444)
            : (isFocused ? AppColors.primary : AppColors.border));
    final borderWidth = (isExceeded || hasError || isFocused) ? 1.5 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isFocused ? Colors.white : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            inputFormatters: [
              if (onExceeded != null)
                _BarcodeLimitFormatter(
                  maxLength: maxLength,
                  onExceeded: onExceeded,
                )
              else
                LengthLimitingTextInputFormatter(maxLength),
            ],
            style: TextStyle(
              color: isExceeded ? AppColors.error : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.hintColor,
                fontSize: 14,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        if (isExceeded) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: Text(
              'Maksimal $maxLength karakter',
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BarcodeLimitFormatter extends TextInputFormatter {
  final int maxLength;
  final VoidCallback onExceeded;

  _BarcodeLimitFormatter({
    required this.maxLength,
    required this.onExceeded,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length > maxLength) {
      onExceeded();
      if (oldValue.text.length <= maxLength) {
        return oldValue;
      }
      return TextEditingValue(
        text: newValue.text.substring(0, maxLength),
        selection: TextSelection.collapsed(offset: maxLength),
      );
    }
    return newValue;
  }
}
