import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/installation_model.dart';
import '../../services/auth_service.dart';
import '../../services/installation_service.dart';
import '../../services/project_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/catatan.dart';
import '../../widgets/custom_feedback.dart';
import '../../widgets/dokumentasi.dart';
import '../../widgets/kode_panel.dart';
import '../../widgets/lokasi_koordinat.dart';
import '../../widgets/pop_up_sukses.dart';
import '../../widgets/pilih_tanggal.dart';
import '../../widgets/shake_widget.dart';
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

class _ManualPageState extends State<ManualPage> with TickerProviderStateMixin {
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

    _shakeAnimation ??= ShakeAnimationHelper.createShakeAnimation(
      _shakeController!,
    );

    _locationShakeController ??= AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _locationShakeAnimation ??= ShakeAnimationHelper.createShakeAnimation(
      _locationShakeController!,
    );
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
      if (Validators.isValidCoordinate(lat, lng)) {
        setState(() {
          _coordinateError = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _barcodeErrorTimer?.cancel();
    _latitudeErrorTimer?.cancel();
    _longitudeErrorTimer?.cancel();
    _shakeController?.dispose();
    _locationShakeController?.dispose();

    _barcodeController.removeListener(_onBarcodeChanged);
    _latitudeController.removeListener(_onCoordinateChanged);
    _latitudeController.removeListener(_onLatitudeChanged);
    _longitudeController.removeListener(_onCoordinateChanged);
    _longitudeController.removeListener(_onLongitudeChanged);

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
        'Tidak dapat menyimpan data. Proyek telah Selesai.',
      );
      return;
    }

    final projectId =
        widget.idProject ?? ProjectService.selectedProject?.idProject;
    if (projectId == null || projectId <= 0) {
      CustomFeedbackMessage.showError(context, 'Proyek belum dipilih.');
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

    final barcode = _barcodeController.text.trim();
    final latitude = _latitudeController.text.trim();
    final longitude = _longitudeController.text.trim();

    if (barcode.isEmpty) {
      CustomFeedbackMessage.showError(context, 'ID Barcode wajib diisi.');
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

    if (!Validators.isValidCoordinate(latitude, longitude)) {
      setState(() {
        _coordinateError = '⚠️ Koordinat tidak valid';
      });
      if (!Validators.isLatitudeValid(latitude)) {
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
        _dateError = 'Tanggal pemasangan wajib diisi';
      });
      CustomFeedbackMessage.showError(
        context,
        'Tanggal pemasangan wajib diisi.',
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
        districtName:
            widget.areaName ?? ProjectService.getAreaName(projectId, areaId),
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

        CustomFeedbackMessage.showSuccess(context, 'Data berhasil disimpan');

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTopBar(showDropdown: false, onBackPressed: _handleBack),
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
                            color: AppColors.borderLight,
                            width: 1.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadowSubtle,
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
                              color: AppColors.divider,
                              height: 1,
                              thickness: 1,
                            ),
                            const SizedBox(height: 18),

                            // 2. KODE PANEL (SHARED WIDGET)
                            KodePanel(
                              controller: _panelCodeController,
                              focusNode: _panelCodeFocusNode,
                            ),

                            const SizedBox(height: 18),
                            const Divider(
                              color: AppColors.divider,
                              height: 1,
                              thickness: 1,
                            ),
                            const SizedBox(height: 18),

                            // 3. LOKASI KOORDINAT (SHARED WIDGET)
                            LokasiKoordinat(
                              latitudeController: _latitudeController,
                              longitudeController: _longitudeController,
                              latitudeFocusNode: _latitudeFocusNode,
                              longitudeFocusNode: _longitudeFocusNode,
                              shakeAnimation: _effectiveLocationShakeAnimation,
                              isLatitudeExceeded: _isLatitudeExceeded,
                              isLongitudeExceeded: _isLongitudeExceeded,
                              onLatitudeLimitExceeded: _onLatitudeLimitExceeded,
                              onLongitudeLimitExceeded:
                                  _onLongitudeLimitExceeded,
                              errorMessage: _coordinateError,
                            ),

                            const SizedBox(height: 18),
                            const Divider(
                              color: AppColors.divider,
                              height: 1,
                              thickness: 1,
                            ),
                            const SizedBox(height: 18),

                            // 4. TANGGAL PENUGASAN (SHARED WIDGET)
                            TanggalPemasangan(
                              title: 'Tanggal Pemasangan',
                              subtitle: 'Masukkan tanggal pemasangan',
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
                              color: AppColors.divider,
                              height: 1,
                              thickness: 1,
                            ),
                            const SizedBox(height: 18),

                            // 5. CATATAN (SHARED WIDGET)
                            Catatan(
                              controller: _notesController,
                              focusNode: _notesFocusNode,
                            ),

                            const SizedBox(height: 18),
                            const Divider(
                              color: AppColors.divider,
                              height: 1,
                              thickness: 1,
                            ),
                            const SizedBox(height: 18),

                            // 6. DOKUMENTASI (SHARED WIDGET)
                            Dokumentasi(
                              photos: _photos,
                              onPhotoAdded: (path) {
                                setState(() {
                                  _photos.add(path);
                                });
                              },
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
      ),
    );
  }

  // 1. ID Barcode Section
  Widget _buildBarcodeInput() {
    final bool isFocused = _barcodeFocusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShakeWidget(
          animation: _effectiveShakeAnimation,
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
                  color: AppColors.error,
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
          style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
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
              LimitExceededFormatter(
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
              hintStyle: TextStyle(color: AppColors.hintColor, fontSize: 14),
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
}
