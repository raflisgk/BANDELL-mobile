import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/installation_model.dart';
import '../../services/installation_service.dart';
import '../../services/lamp_type_service.dart';
import '../../services/project_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/catatan.dart';
import '../../widgets/custom_feedback.dart';
import '../../widgets/dokumentasi.dart';
import '../../widgets/kode_panel.dart';
import 'edit_lampu_action_buttons.dart';
import 'edit_lampu_location.dart';
import 'edit_lampu_type.dart';

class EditDataLampuPage extends StatefulWidget {
  final int? idInstallation;
  final int? idProject;
  final int? idArea;
  final bool isEdit;
  final String? scannedCode;
  final String? initialKodeLampu;
  final String? initialKodePanel;
  final String? initialLongitude;
  final String? initialLatitude;
  final String? initialAlamat;
  final String? initialCatatan;
  final String? initialTipeLampu;
  final List<String>? initialPhotos;

  const EditDataLampuPage({
    super.key,
    this.idInstallation,
    this.idProject,
    this.idArea,
    this.isEdit = false,
    this.scannedCode,
    this.initialKodeLampu,
    this.initialKodePanel,
    this.initialLongitude,
    this.initialLatitude,
    this.initialAlamat,
    this.initialCatatan,
    this.initialTipeLampu,
    this.initialPhotos,
  });

  @override
  State<EditDataLampuPage> createState() => _EditDataLampuPageState();
}

class _EditDataLampuPageState extends State<EditDataLampuPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  int? _existingAreaId;
  int? _existingProjectId;

  late TextEditingController _kodeLampuController;
  late TextEditingController _panelCodeController;
  late TextEditingController _longitudeController;
  late TextEditingController _latitudeController;
  late TextEditingController _catatanController;
  late TextEditingController _tipeLampuController;

  final FocusNode _kodeLampuFocusNode = FocusNode();
  final FocusNode _panelCodeFocusNode = FocusNode();
  final FocusNode _longitudeFocusNode = FocusNode();
  final FocusNode _latitudeFocusNode = FocusNode();
  final FocusNode _catatanFocusNode = FocusNode();
  final FocusNode _tipeLampuFocusNode = FocusNode();

  List<String> _lampTypeOptions = [];

  final List<String> _photos = [];
  String? _coordinateError;

  @override
  void initState() {
    super.initState();

    final defaultKode = widget.isEdit
        ? ((widget.initialKodeLampu != null &&
                  widget.initialKodeLampu!.isNotEmpty &&
                  widget.initialKodeLampu != '-')
              ? widget.initialKodeLampu!
              : '')
        : (widget.scannedCode ?? '');
    final defaultPanel = widget.isEdit
        ? ((widget.initialKodePanel != null &&
                  widget.initialKodePanel!.isNotEmpty &&
                  widget.initialKodePanel != '-')
              ? widget.initialKodePanel!
              : '')
        : '';
    final defaultLong = widget.isEdit
        ? ((widget.initialLongitude != null &&
                  widget.initialLongitude!.isNotEmpty &&
                  widget.initialLongitude != '-')
              ? widget.initialLongitude!
              : '')
        : '';
    final defaultLat = widget.isEdit
        ? ((widget.initialLatitude != null &&
                  widget.initialLatitude!.isNotEmpty &&
                  widget.initialLatitude != '-')
              ? widget.initialLatitude!
              : '')
        : '';
    final defaultCatatan = widget.isEdit
        ? ((widget.initialCatatan != null &&
                  widget.initialCatatan!.isNotEmpty &&
                  widget.initialCatatan != '-')
              ? widget.initialCatatan!
              : ((widget.initialAlamat != null && widget.initialAlamat != '-')
                    ? widget.initialAlamat!
                    : ''))
        : (widget.initialCatatan ?? widget.initialAlamat ?? '');
    final defaultTipe = widget.isEdit
        ? ((widget.initialTipeLampu != null &&
                  widget.initialTipeLampu!.isNotEmpty &&
                  widget.initialTipeLampu != '-')
              ? widget.initialTipeLampu!
              : '')
        : '';

    _kodeLampuController = TextEditingController(text: defaultKode);
    _panelCodeController = TextEditingController(text: defaultPanel);
    _longitudeController = TextEditingController(text: defaultLong);
    _latitudeController = TextEditingController(text: defaultLat);
    _catatanController = TextEditingController(text: defaultCatatan);
    _tipeLampuController = TextEditingController(text: defaultTipe);

    _kodeLampuFocusNode.addListener(_onFocusChange);
    _panelCodeFocusNode.addListener(_onFocusChange);
    _longitudeFocusNode.addListener(_onFocusChange);
    _latitudeFocusNode.addListener(_onFocusChange);
    _catatanFocusNode.addListener(_onFocusChange);
    _tipeLampuFocusNode.addListener(_onFocusChange);
    _latitudeController.addListener(_onCoordinateChanged);
    _longitudeController.addListener(_onCoordinateChanged);

    if (widget.initialPhotos != null && widget.initialPhotos!.isNotEmpty) {
      _photos.addAll(widget.initialPhotos!.where((p) => p.trim().isNotEmpty));
    } else if (widget.isEdit &&
        widget.idInstallation != null &&
        widget.idInstallation! > 0) {
      _loadExistingInstallation();
    }

    _loadLampTypes();
  }

  void _loadExistingInstallation() async {
    try {
      final detail = await InstallationService().getInstallationDetail(
        widget.idInstallation!,
      );
      if (detail != null && mounted) {
        setState(() {
          _existingAreaId = detail.idArea;
          _existingProjectId = detail.idProject;
          if (_photos.isEmpty && detail.photos.isNotEmpty) {
            _photos.addAll(detail.photos.where((p) => p.trim().isNotEmpty));
          }
          if (_panelCodeController.text.isEmpty &&
              detail.panelCode != null &&
              detail.panelCode!.isNotEmpty &&
              detail.panelCode != '-') {
            _panelCodeController.text = detail.panelCode!;
          }
          if (_catatanController.text.isEmpty &&
              detail.notes != null &&
              detail.notes!.isNotEmpty &&
              detail.notes != '-') {
            _catatanController.text = detail.notes!;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading existing installation detail: $e');
    }
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

  void _loadLampTypes() async {
    try {
      final types = await LampTypeService().getLampTypes();
      if (mounted) {
        setState(() {
          _lampTypeOptions = types.map((t) => t.name).toList();
          if (_lampTypeOptions.isNotEmpty &&
              _tipeLampuController.text.isEmpty) {
            _tipeLampuController.text = _lampTypeOptions.first;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading lamp types: $e');
    }
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _kodeLampuController.dispose();
    _panelCodeController.dispose();
    _longitudeController.dispose();
    _latitudeController.dispose();
    _catatanController.dispose();
    _tipeLampuController.dispose();

    _kodeLampuFocusNode.removeListener(_onFocusChange);
    _panelCodeFocusNode.removeListener(_onFocusChange);
    _longitudeFocusNode.removeListener(_onFocusChange);
    _latitudeFocusNode.removeListener(_onFocusChange);
    _catatanFocusNode.removeListener(_onFocusChange);
    _tipeLampuFocusNode.removeListener(_onFocusChange);
    _latitudeController.removeListener(_onCoordinateChanged);
    _longitudeController.removeListener(_onCoordinateChanged);

    _kodeLampuFocusNode.dispose();
    _panelCodeFocusNode.dispose();
    _longitudeFocusNode.dispose();
    _latitudeFocusNode.dispose();
    _catatanFocusNode.dispose();
    _tipeLampuFocusNode.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _removePhoto(int index) {
    if (index >= 0 && index < _photos.length) {
      setState(() {
        _photos.removeAt(index);
      });
      CustomFeedback.showSuccess(context, 'Foto berhasil dihapus');
    }
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    if (widget.isEdit &&
        (widget.idInstallation == null || widget.idInstallation! <= 0)) {
      CustomFeedback.showError(context, 'ID data lampu tidak valid.');
      return;
    }

    final latitude = _latitudeController.text.trim();
    final longitude = _longitudeController.text.trim();

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
      CustomFeedback.showError(
        context,
        'Kode panel maksimal 12 karakter.',
      );
      _panelCodeFocusNode.requestFocus();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final resolvedProjectId = widget.idProject ??
          _existingProjectId ??
          ProjectService.selectedProject?.idProject;
      final resolvedAreaId = widget.idArea ?? _existingAreaId ?? 0;

      final updatedData = InstallationModel(
        idInstallation: widget.idInstallation ?? 0,
        idProject: resolvedProjectId,
        idArea: resolvedAreaId,
        lampCode: _kodeLampuController.text.trim(),
        panelCode: _panelCodeController.text.trim().isNotEmpty
            ? _panelCodeController.text.trim()
            : null,
        lampType: _tipeLampuController.text.trim(),
        latitude: latitude.replaceAll(',', '.'),
        longitude: longitude.replaceAll(',', '.'),
        notes: _catatanController.text.trim(),
        photos: List.from(_photos),
        status: 'Tersimpan',
        updatedAt: DateTime.now(),
      );

      if (widget.isEdit) {
        debugPrint('Simpan Perubahan (ID: ${widget.idInstallation})');
        final result = await InstallationService().updateInstallation(
          widget.idInstallation ?? 0,
          updatedData,
        );

        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          CustomFeedback.showSuccess(
            context,
            'Perubahan data lampu berhasil disimpan',
          );
          Navigator.pop(context, result);
        }
      } else {
        debugPrint('Simpan Data Pendataan Baru');
        final created =
            await InstallationService().createInstallation(updatedData);

        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          if (created.status == 'Menunggu Jaringan') {
            CustomFeedback.showSuccess(
              context,
              'Data tersimpan di HP (Offline). Otomatis diunggah saat ada sinyal.',
            );
          } else {
            CustomFeedback.showSuccess(
              context,
              'Pendataan lampu berhasil disimpan',
            );
          }
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint('Error saving lamp data: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        final rawMsg = e.toString().replaceFirst('Exception: ', '').trim();
        CustomFeedback.showError(
          context,
          rawMsg.isNotEmpty
              ? rawMsg
              : 'Gagal menyimpan perubahan. Silakan coba lagi.',
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
          child: Column(
            children: [
              AppTopBar(
                title: widget.isEdit ? 'Edit Data' : 'Tambah Data',
                showBackButton: true,
                showNotification: false,
                showDropdown: false,
                onBackPressed: _handleBack,
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),

                        // Large White Card Form Container
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadowColor,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. KODE LAMPU
                              _buildSectionHeader(
                                icon: Icons.lightbulb_outline_rounded,
                                title: 'Kode Lampu',
                                subtitle: 'Masukkan kode lampu',
                              ),
                              const SizedBox(height: 12),
                              _buildCustomTextField(
                                controller: _kodeLampuController,
                                focusNode: _kodeLampuFocusNode,
                                hint: 'Masukkan kode lampu',
                              ),

                              const SizedBox(height: 20),
                              const Divider(color: AppColors.border, height: 1),
                              const SizedBox(height: 20),

                              // 2. KODE PANEL
                              KodePanel(
                                controller: _panelCodeController,
                                focusNode: _panelCodeFocusNode,
                              ),

                              const SizedBox(height: 20),
                              const Divider(color: AppColors.border, height: 1),
                              const SizedBox(height: 20),

                              // 3. LOKASI KOORDINAT
                              EditLampuLocation(
                                longitudeController: _longitudeController,
                                latitudeController: _latitudeController,
                                longitudeFocusNode: _longitudeFocusNode,
                                latitudeFocusNode: _latitudeFocusNode,
                                errorMessage: _coordinateError,
                              ),

                              const SizedBox(height: 20),
                              const Divider(color: AppColors.border, height: 1),
                              const SizedBox(height: 20),

                              // 3. TIPE LAMPU
                              EditLampuType(
                                tipeLampuController: _tipeLampuController,
                                tipeLampuFocusNode: _tipeLampuFocusNode,
                                lampTypeOptions: _lampTypeOptions,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _tipeLampuController.text = newValue;
                                    });
                                  }
                                },
                              ),

                              const SizedBox(height: 20),
                              const Divider(color: AppColors.border, height: 1),
                              const SizedBox(height: 20),

                              // 4. CATATAN
                              Catatan(
                                controller: _catatanController,
                                focusNode: _catatanFocusNode,
                              ),

                              const SizedBox(height: 20),
                              const Divider(color: AppColors.border, height: 1),
                              const SizedBox(height: 20),

                              // 5. DOKUMENTASI
                              Dokumentasi(
                                photos: _photos,
                                onPhotoAdded: (path) {
                                  setState(() {
                                    _photos.add(path);
                                  });
                                  if (mounted) {
                                    CustomFeedback.showSuccess(
                                      context,
                                      'Foto ${_photos.length} berhasil ditambahkan',
                                    );
                                  }
                                },
                                onRemovePhoto: _removePhoto,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Bottom Buttons Row: [ Batal ] & [ Simpan Perubahan ]
                        EditLampuActionButtons(
                          isEdit: widget.isEdit,
                          isLoading: _isSubmitting,
                          onCancel: _handleBack,
                          onSave: _handleSubmit,
                        ),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    IconData? prefixIcon,
  }) {
    final isFocused = focusNode.hasFocus;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? AppColors.borderFocused : AppColors.border,
          width: isFocused ? 1.5 : 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.hintColor, fontSize: 14),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: AppColors.iconColor, size: 20)
              : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
