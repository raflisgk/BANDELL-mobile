import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/installation_model.dart';
import '../../services/auth_service.dart';
import '../../services/installation_service.dart';
import '../../services/project_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/page_transitions.dart';
import '../../utils/validators.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/catatan.dart';
import '../../widgets/custom_feedback.dart';
import '../../widgets/dokumentasi.dart';
import '../../widgets/kode_panel.dart';
import '../../widgets/lokasi_koordinat.dart';
import '../../widgets/pop_up_sukses.dart';
import '../../widgets/tombol_simpan_data.dart';
import 'realtime_barcode.dart';
import 'scan_barcode_page.dart';
import '../metode_pendataan/metode_pendataan_page.dart';

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
  final TextEditingController _notesController = TextEditingController();

  final FocusNode _latitudeFocusNode = FocusNode();
  final FocusNode _longitudeFocusNode = FocusNode();
  final FocusNode _panelCodeFocusNode = FocusNode();
  final FocusNode _notesFocusNode = FocusNode();

  String? _scannedBarcode;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  final List<String> _photos = [];
  String? _coordinateError;

  @override
  void initState() {
    super.initState();
    _latitudeFocusNode.addListener(_onFocusChange);
    _longitudeFocusNode.addListener(_onFocusChange);
    _panelCodeFocusNode.addListener(_onFocusChange);
    _notesFocusNode.addListener(_onFocusChange);
    _latitudeController.addListener(_onCoordinateChanged);
    _longitudeController.addListener(_onCoordinateChanged);
  }

  void _onFocusChange() {
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
    _latitudeController.removeListener(_onCoordinateChanged);
    _longitudeController.removeListener(_onCoordinateChanged);
    _latitudeController.dispose();
    _longitudeController.dispose();
    _panelCodeController.dispose();
    _notesController.dispose();

    _latitudeFocusNode.removeListener(_onFocusChange);
    _longitudeFocusNode.removeListener(_onFocusChange);
    _panelCodeFocusNode.removeListener(_onFocusChange);
    _notesFocusNode.removeListener(_onFocusChange);
    _latitudeFocusNode.dispose();
    _longitudeFocusNode.dispose();
    _panelCodeFocusNode.dispose();
    _notesFocusNode.dispose();
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
      final scannedValue = result.trim();

      if (scannedValue.length > 12) {
        if (mounted) {
          CustomFeedbackMessage.showError(
            context,
            'ID Barcode maksimal 12 karakter.',
          );
        }
        return;
      }

      setState(() {
        _scannedBarcode = scannedValue;
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
          _coordinateError = null;
        });
      }
    } catch (e) {
      debugPrint('Error getting GPS location: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        CustomFeedbackMessage.showError(context, 'Gagal mengambil lokasi GPS.');
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
      CustomFeedbackMessage.showError(context, 'Project belum dipilih.');
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

    final lampTypeId = widget.lampTypeId;
    if ((lampTypeId == null || lampTypeId <= 0) &&
        (widget.lampType == null || widget.lampType!.trim().isEmpty)) {
      CustomFeedbackMessage.showError(context, 'Jenis lampu belum dipilih.');
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
        'ID Barcode maksimal 12 karakter.',
      );
      return;
    }

    final latitude = _latitudeController.text.trim();
    final longitude = _longitudeController.text.trim();

    if (!Validators.isValidCoordinate(latitude, longitude)) {
      setState(() {
        _coordinateError = '⚠️ Koordinat tidak valid';
      });
      return;
    } else {
      if (_coordinateError != null) {
        setState(() {
          _coordinateError = null;
        });
      }
    }

    if (_panelCodeController.text.trim().length > 11) {
      CustomFeedbackMessage.showError(
        context,
        'Kode panel maksimal 11 karakter.',
      );
      _panelCodeFocusNode.requestFocus();
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
        districtName: widget.areaName ??
            ProjectService.getAreaName(projectId, areaId),
        lampTypeId: lampTypeId,
        lampCode: _scannedBarcode!.trim(),
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
        inputMethod: 'Realtime',
        status: 'Tersimpan',
        createdAt: DateTime.now(),
      );

      await InstallationService().createInstallation(installationData);

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        CustomFeedbackMessage.showSuccess(context, 'Data berhasil disimpan');

        PopUpSukses.show(
          context,
          lampCode: _scannedBarcode!,
          onAddData: () {
            Navigator.popUntil(
              context,
              ModalRoute.withName(MetodePendataanPage.routeName),
            );
          },
        );
      }
    } catch (e) {
      debugPrint('Error creating installation: $e');
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
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
                      color: AppColors.borderLight,
                      height: 1,
                      thickness: 1,
                    ),
                    const SizedBox(height: 20),

                    // 2. LOKASI KOORDINAT SECTION (GPS)
                    LokasiKoordinat(
                      latitudeController: _latitudeController,
                      longitudeController: _longitudeController,
                      latitudeFocusNode: _latitudeFocusNode,
                      longitudeFocusNode: _longitudeFocusNode,
                      isGpsMode: true,
                      isLoadingGps: _isLoadingLocation,
                      onGetGpsLocation: _handleGetLocation,
                      errorMessage: _coordinateError,
                      readOnly: true,
                    ),

                    const SizedBox(height: 20),
                    const Divider(
                      color: AppColors.borderLight,
                      height: 1,
                      thickness: 1,
                    ),
                    const SizedBox(height: 20),

                    // 3. KODE PANEL SECTION
                    KodePanel(
                      controller: _panelCodeController,
                      focusNode: _panelCodeFocusNode,
                    ),

                    const SizedBox(height: 20),
                    const Divider(
                      color: AppColors.borderLight,
                      height: 1,
                      thickness: 1,
                    ),
                    const SizedBox(height: 20),

                    // CATATAN SECTION
                    Catatan(
                      controller: _notesController,
                      focusNode: _notesFocusNode,
                    ),

                    const SizedBox(height: 20),
                    const Divider(
                      color: AppColors.borderLight,
                      height: 1,
                      thickness: 1,
                    ),
                    const SizedBox(height: 20),

                    // 4. DOKUMENTASI SECTION
                    Dokumentasi(
                      photos: _photos,
                      onPhotoAdded: (path) {
                        setState(() {
                          _photos.add(path);
                        });
                      },
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
            ],
          ),
        ),
      ),
    ),
  );
}
}
