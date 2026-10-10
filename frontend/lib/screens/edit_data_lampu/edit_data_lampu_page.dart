import 'dart:async';

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
import '../../widgets/lokasi_koordinat.dart';
import '../../widgets/shake_widget.dart';
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

class _EditDataLampuPageState extends State<EditDataLampuPage>
    with TickerProviderStateMixin {
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

  final GlobalKey _kodeLampuSectionKey = GlobalKey();
  final GlobalKey _coordinateSectionKey = GlobalKey();
  final GlobalKey _panelCodeSectionKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  AnimationController? _lampCodeShakeController;
  Animation<double>? _lampCodeShakeAnimation;
  bool _isLampCodeError = false;

  AnimationController? _locationShakeController;
  Animation<double>? _locationShakeAnimation;
  bool _isLatitudeExceeded = false;
  Timer? _latitudeErrorTimer;
  bool _isLongitudeExceeded = false;
  Timer? _longitudeErrorTimer;

  void _initShakeAnimation() {
    _lampCodeShakeController ??= AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _lampCodeShakeAnimation ??= ShakeAnimationHelper.createShakeAnimation(
      _lampCodeShakeController!,
    );

    _locationShakeController ??= AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _locationShakeAnimation ??= ShakeAnimationHelper.createShakeAnimation(
      _locationShakeController!,
    );
  }

  AnimationController get _effectiveLampCodeShakeController {
    if (_lampCodeShakeController == null) _initShakeAnimation();
    return _lampCodeShakeController!;
  }

  Animation<double> get _effectiveLampCodeShakeAnimation {
    if (_lampCodeShakeAnimation == null) _initShakeAnimation();
    return _lampCodeShakeAnimation!;
  }

  AnimationController get _effectiveLocationShakeController {
    if (_locationShakeController == null) _initShakeAnimation();
    return _locationShakeController!;
  }

  Animation<double> get _effectiveLocationShakeAnimation {
    if (_locationShakeAnimation == null) _initShakeAnimation();
    return _locationShakeAnimation!;
  }

  void _onKodeLampuChanged() {
    if (_isLampCodeError && _kodeLampuController.text.trim().isNotEmpty) {
      setState(() {
        _isLampCodeError = false;
      });
    }
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
    _longitudeErrorTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted && _isLongitudeExceeded) {
        setState(() {
          _isLongitudeExceeded = false;
        });
      }
    });
  }

  static String _cleanValue(String? val) {
    if (val == null) return '';
    final trimmed = val.trim();
    return (trimmed.isNotEmpty && trimmed != '-') ? trimmed : '';
  }

  @override
  void initState() {
    super.initState();

    final defaultKode = widget.isEdit
        ? _cleanValue(widget.initialKodeLampu)
        : (widget.scannedCode ?? '');
    final defaultPanel = widget.isEdit
        ? _cleanValue(widget.initialKodePanel)
        : '';
    final defaultLong = widget.isEdit
        ? _cleanValue(widget.initialLongitude)
        : '';
    final defaultLat = widget.isEdit ? _cleanValue(widget.initialLatitude) : '';
    final defaultCatatan = widget.isEdit
        ? (_cleanValue(widget.initialCatatan).isNotEmpty
              ? _cleanValue(widget.initialCatatan)
              : _cleanValue(widget.initialAlamat))
        : (widget.initialCatatan ?? widget.initialAlamat ?? '');
    final defaultTipe = widget.isEdit
        ? _cleanValue(widget.initialTipeLampu)
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
    _latitudeController.addListener(_onLatitudeChanged);
    _longitudeController.addListener(_onLongitudeChanged);
    _kodeLampuController.addListener(_onKodeLampuChanged);

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
              _cleanValue(detail.panelCode).isNotEmpty) {
            _panelCodeController.text = _cleanValue(detail.panelCode);
          }
          if (_catatanController.text.isEmpty &&
              _cleanValue(detail.notes).isNotEmpty) {
            _catatanController.text = _cleanValue(detail.notes);
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

  @override
  void dispose() {
    _latitudeErrorTimer?.cancel();
    _longitudeErrorTimer?.cancel();
    _lampCodeShakeController?.dispose();
    _locationShakeController?.dispose();

    _latitudeController.removeListener(_onCoordinateChanged);
    _longitudeController.removeListener(_onCoordinateChanged);
    _latitudeController.removeListener(_onLatitudeChanged);
    _longitudeController.removeListener(_onLongitudeChanged);
    _kodeLampuController.removeListener(_onKodeLampuChanged);

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

    _kodeLampuFocusNode.dispose();
    _panelCodeFocusNode.dispose();
    _longitudeFocusNode.dispose();
    _latitudeFocusNode.dispose();
    _catatanFocusNode.dispose();
    _tipeLampuFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToKey(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final keyContext = key.currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(
          keyContext,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      }
    });
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

    final lampCode = _kodeLampuController.text.trim();
    if (lampCode.isEmpty) {
      setState(() {
        _isLampCodeError = true;
      });
      _effectiveLampCodeShakeController.forward(from: 0.0);
      CustomFeedback.showError(context, 'Kode lampu wajib diisi.');
      _kodeLampuFocusNode.requestFocus();
      _scrollToKey(_kodeLampuSectionKey);
      Future.delayed(const Duration(milliseconds: 380), () {
        if (mounted) {
          _effectiveLampCodeShakeController.forward(from: 0.0);
        }
      });
      return;
    } else {
      if (_isLampCodeError) {
        setState(() {
          _isLampCodeError = false;
        });
      }
    }

    final latitude = _latitudeController.text.trim();
    final longitude = _longitudeController.text.trim();

    if (!Validators.isValidCoordinate(latitude, longitude)) {
      setState(() {
        _coordinateError = '⚠️ Koordinat tidak valid';
      });
      _effectiveLocationShakeController.forward(from: 0.0);
      if (!Validators.isLatitudeValid(latitude)) {
        _latitudeFocusNode.requestFocus();
      } else {
        _longitudeFocusNode.requestFocus();
      }
      _scrollToKey(_coordinateSectionKey);
      return;
    } else {
      if (_coordinateError != null) {
        setState(() {
          _coordinateError = null;
        });
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final resolvedProjectId =
          widget.idProject ??
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
        final created = await InstallationService().createInstallation(
          updatedData,
        );

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
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.translucent,
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
                    controller: _scrollController,
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
                                Column(
                                  key: _kodeLampuSectionKey,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionHeader(
                                      icon: Icons.lightbulb_outline_rounded,
                                      title: 'Kode Lampu',
                                      subtitle: 'Masukkan kode lampu',
                                      isRequired: true,
                                    ),
                                    const SizedBox(height: 12),
                                    ShakeWidget(
                                      animation:
                                          _effectiveLampCodeShakeAnimation,
                                      child: _buildCustomTextField(
                                        controller: _kodeLampuController,
                                        focusNode: _kodeLampuFocusNode,
                                        hint: 'Masukkan kode lampu',
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(12),
                                        ],
                                        hasError: _isLampCodeError,
                                      ),
                                    ),
                                    if (_isLampCodeError) ...[
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Kode lampu wajib diisi',
                                        style: TextStyle(
                                          color: AppColors.error,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),

                                const SizedBox(height: 20),
                                const Divider(
                                  color: AppColors.border,
                                  height: 1,
                                ),
                                const SizedBox(height: 20),

                                // 2. KODE PANEL
                                KodePanel(
                                  key: _panelCodeSectionKey,
                                  controller: _panelCodeController,
                                  focusNode: _panelCodeFocusNode,
                                ),

                                const SizedBox(height: 20),
                                const Divider(
                                  color: AppColors.border,
                                  height: 1,
                                ),
                                const SizedBox(height: 20),

                                // 3. LOKASI KOORDINAT
                                LokasiKoordinat(
                                  key: _coordinateSectionKey,
                                  longitudeController: _longitudeController,
                                  latitudeController: _latitudeController,
                                  longitudeFocusNode: _longitudeFocusNode,
                                  latitudeFocusNode: _latitudeFocusNode,
                                  shakeAnimation:
                                      _effectiveLocationShakeAnimation,
                                  isLatitudeExceeded: _isLatitudeExceeded,
                                  isLongitudeExceeded: _isLongitudeExceeded,
                                  onLatitudeLimitExceeded:
                                      _onLatitudeLimitExceeded,
                                  onLongitudeLimitExceeded:
                                      _onLongitudeLimitExceeded,
                                  errorMessage: _coordinateError,
                                  latitudeHint: '-6.2088',
                                  longitudeHint: '106.8456',
                                ),

                                const SizedBox(height: 20),
                                const Divider(
                                  color: AppColors.border,
                                  height: 1,
                                ),
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
                                const Divider(
                                  color: AppColors.border,
                                  height: 1,
                                ),
                                const SizedBox(height: 20),

                                // 4. CATATAN
                                Catatan(
                                  controller: _catatanController,
                                  focusNode: _catatanFocusNode,
                                ),

                                const SizedBox(height: 20),
                                const Divider(
                                  color: AppColors.border,
                                  height: 1,
                                ),
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
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isRequired = false,
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
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isRequired) ...[
                    const SizedBox(width: 4),
                    const Text(
                      '*',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
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
    List<TextInputFormatter>? inputFormatters,
    bool hasError = false,
  }) {
    final isFocused = focusNode.hasFocus;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError
              ? AppColors.error
              : (isFocused ? AppColors.borderFocused : AppColors.border),
          width: (hasError || isFocused) ? 1.5 : 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.hintColor, fontSize: 14),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: hasError ? AppColors.error : AppColors.iconColor,
                  size: 20,
                )
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

class EditLampuActionButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isEdit;
  final bool isLoading;

  const EditLampuActionButtons({
    super.key,
    required this.onCancel,
    required this.onSave,
    this.isEdit = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: isLoading ? null : onCancel,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    )
                  : Text(
                      isEdit ? 'Simpan Perubahan' : 'Simpan Data',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
