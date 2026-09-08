import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/installation_model.dart';
import '../../services/installation_service.dart';
import '../../services/lamp_type_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/dokumentasi.dart';
import 'edit_lampu_action_buttons.dart';
import 'edit_lampu_location.dart';
import 'edit_lampu_type.dart';

class EditDataLampuPage extends StatefulWidget {
  final int? idInstallation;
  final bool isEdit;
  final String? scannedCode;
  final String? initialKodeLampu;
  final String? initialLongitude;
  final String? initialLatitude;
  final String? initialAlamat;
  final String? initialTipeLampu;

  const EditDataLampuPage({
    super.key,
    this.idInstallation,
    this.isEdit = false,
    this.scannedCode,
    this.initialKodeLampu,
    this.initialLongitude,
    this.initialLatitude,
    this.initialAlamat,
    this.initialTipeLampu,
  });

  @override
  State<EditDataLampuPage> createState() => _EditDataLampuPageState();
}

class _EditDataLampuPageState extends State<EditDataLampuPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  late TextEditingController _kodeLampuController;
  late TextEditingController _longitudeController;
  late TextEditingController _latitudeController;
  late TextEditingController _alamatController;
  late TextEditingController _tipeLampuController;

  final FocusNode _kodeLampuFocusNode = FocusNode();
  final FocusNode _longitudeFocusNode = FocusNode();
  final FocusNode _latitudeFocusNode = FocusNode();
  final FocusNode _alamatFocusNode = FocusNode();
  final FocusNode _tipeLampuFocusNode = FocusNode();

  List<String> _lampTypeOptions = [];

  final List<String> _photos = [];

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
    final defaultAlamat = widget.isEdit
        ? ((widget.initialAlamat != null && widget.initialAlamat != '-')
            ? widget.initialAlamat!
            : '')
        : '';
    final defaultTipe = widget.isEdit
        ? ((widget.initialTipeLampu != null &&
                widget.initialTipeLampu!.isNotEmpty &&
                widget.initialTipeLampu != '-')
            ? widget.initialTipeLampu!
            : '')
        : '';

    _kodeLampuController = TextEditingController(text: defaultKode);
    _longitudeController = TextEditingController(text: defaultLong);
    _latitudeController = TextEditingController(text: defaultLat);
    _alamatController = TextEditingController(text: defaultAlamat);
    _tipeLampuController = TextEditingController(text: defaultTipe);

    _kodeLampuFocusNode.addListener(_onFocusChange);
    _longitudeFocusNode.addListener(_onFocusChange);
    _latitudeFocusNode.addListener(_onFocusChange);
    _alamatFocusNode.addListener(_onFocusChange);
    _tipeLampuFocusNode.addListener(_onFocusChange);

    _loadLampTypes();
  }

  void _loadLampTypes() async {
    final types = await LampTypeService().getLampTypes();
    if (mounted) {
      setState(() {
        _lampTypeOptions = types.map((t) => t.name).toList();
        if (_lampTypeOptions.isNotEmpty && _tipeLampuController.text.isEmpty) {
          _tipeLampuController.text = _lampTypeOptions.first;
        }
      });
    }
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _kodeLampuController.dispose();
    _longitudeController.dispose();
    _latitudeController.dispose();
    _alamatController.dispose();
    _tipeLampuController.dispose();

    _kodeLampuFocusNode.removeListener(_onFocusChange);
    _longitudeFocusNode.removeListener(_onFocusChange);
    _latitudeFocusNode.removeListener(_onFocusChange);
    _alamatFocusNode.removeListener(_onFocusChange);
    _tipeLampuFocusNode.removeListener(_onFocusChange);

    _kodeLampuFocusNode.dispose();
    _longitudeFocusNode.dispose();
    _latitudeFocusNode.dispose();
    _alamatFocusNode.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto berhasil dihapus'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _handleTambahFoto() {
    if (_photos.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimal 4 foto dokumentasi.'),
          backgroundColor: Color(0xFFDC2626),
          duration: Duration(seconds: 1),
        ),
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Foto ${_photos.length} berhasil ditambahkan'),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final updatedData = InstallationModel(
        idInstallation: widget.idInstallation ?? 0,
        idArea: 101,
        lampCode: _kodeLampuController.text.trim(),
        lampType: _tipeLampuController.text.trim(),
        latitude: _latitudeController.text.trim(),
        longitude: _longitudeController.text.trim(),
        notes: _alamatController.text.trim(),
        photos: List.from(_photos),
        status: 'Tersimpan',
        updatedAt: DateTime.now(),
      );

      if (widget.isEdit) {
        debugPrint('Simpan Perubahan (ID: ${widget.idInstallation})');
        await InstallationService().updateInstallation(
          widget.idInstallation ?? 0,
          updatedData,
        );

        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perubahan data lampu berhasil disimpan'),
              backgroundColor: AppColors.primary,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        debugPrint('Simpan Data Pendataan Baru');
        await InstallationService().createInstallation(updatedData);

        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pendataan lampu berhasil disimpan'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint('Error saving lamp data: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan perubahan. Silakan coba lagi.'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
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
              showBackButton: true,
              showNotification: false,
              showDropdown: false,
              onBackPressed: _handleBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),

                      // Title & Subtitle Header
                      Center(
                        child: Text(
                          widget.isEdit ? 'Edit Data' : 'Tambah Data',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          widget.isEdit
                              ? 'Edit data lampu secara manual'
                              : 'Masukkan detail data fisik pemasangan lampu.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

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

                            // 2. LOKASI KOORDINAT
                            EditLampuLocation(
                              longitudeController: _longitudeController,
                              latitudeController: _latitudeController,
                              longitudeFocusNode: _longitudeFocusNode,
                              latitudeFocusNode: _latitudeFocusNode,
                            ),

                      const SizedBox(height: 20),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 20),

                      // 4. TIPE LAMPU
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

                      // 5. DOKUMENTASI
                      Dokumentasi(
                        photos: _photos,
                        onAddPhoto: _handleTambahFoto,
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
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
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
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.hintColor,
            fontSize: 14,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: AppColors.iconColor,
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


