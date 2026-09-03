import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/app_colors.dart';
import '../widgets/edit_data_lampu/edit_lampu_action_buttons.dart';
import '../widgets/edit_data_lampu/edit_lampu_documentation.dart';
import '../widgets/edit_data_lampu/edit_lampu_location.dart';
import '../widgets/edit_data_lampu/edit_lampu_type.dart';

class EditDataLampuPage extends StatefulWidget {
  final bool isEdit;
  final String? scannedCode;
  final String? initialKodeLampu;
  final String? initialLongitude;
  final String? initialLatitude;
  final String? initialAlamat;
  final String? initialTipeLampu;

  const EditDataLampuPage({
    super.key,
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

  bool _isLoadingLocation = false;

  final List<String> _lampTypeOptions = const [
    'LED Street Light 100W',
    'LED Street Light 150W',
    'LED Street Light 80W',
    'LED Cobra Head 120W',
    'Solar Smart LED 150W',
  ];

  @override
  void initState() {
    super.initState();

    final defaultKode = widget.isEdit
        ? (widget.initialKodeLampu ?? '')
        : (widget.scannedCode ?? '');
    final defaultLong = widget.isEdit
        ? (widget.initialLongitude ?? '')
        : '';
    final defaultLat = widget.isEdit
        ? (widget.initialLatitude ?? '')
        : '';
    final defaultAlamat = widget.isEdit
        ? (widget.initialAlamat ?? '')
        : '';
    final defaultTipe = widget.isEdit
        ? (widget.initialTipeLampu ?? '')
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

  Future<void> _handleGetLocation() async {
    if (_isLoadingLocation) return;
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Layanan lokasi (GPS) nonaktif. Harap aktifkan GPS Anda di Pengaturan.'),
            backgroundColor: AppColors.realtimeGreen,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin lokasi diperlukan untuk mengambil koordinat lampu.'),
              backgroundColor: AppColors.realtimeGreen,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin lokasi ditolak permanen. Buka pengaturan aplikasi untuk mengaktifkannya.'),
            backgroundColor: AppColors.realtimeGreen,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      if (!mounted) return;
      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(6);
        _longitudeController.text = position.longitude.toStringAsFixed(6);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lokasi GPS berhasil diambil: Lat ${position.latitude.toStringAsFixed(4)}, Long ${position.longitude.toStringAsFixed(4)}'),
          backgroundColor: AppColors.realtimeGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil lokasi GPS: $e'),
          backgroundColor: AppColors.realtimeGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _handleTambahFoto() {
    debugPrint('Tambah Foto clicked');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tambah Foto (Simulasi UI)'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleSubmit() {
    if (widget.isEdit) {
      debugPrint('Simpan Perubahan');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perubahan Berhasil Disimpan (Simulasi UI)'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 1),
        ),
      );
      Navigator.pop(context);
    } else {
      debugPrint('Simpan Data Pendataan');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendataan Lampu Berhasil Disimpan (Simulasi UI)'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 1),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Header Row: Back Arrow
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: _handleBack,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),

                const SizedBox(height: 20),

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

                const SizedBox(height: 24),

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
                        hint: 'Contoh: JKT-2025-004',
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 20),

                      // 2 & 3. LOKASI KOORDINAT & ALAMAT
                      EditLampuLocation(
                        longitudeController: _longitudeController,
                        latitudeController: _latitudeController,
                        alamatController: _alamatController,
                        longitudeFocusNode: _longitudeFocusNode,
                        latitudeFocusNode: _latitudeFocusNode,
                        alamatFocusNode: _alamatFocusNode,
                        isLoadingLocation: _isLoadingLocation,
                        onGetLocation: _handleGetLocation,
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
                      EditLampuDocumentation(
                        onTambahFoto: _handleTambahFoto,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Bottom Buttons Row: [ Batal ] & [ Simpan Perubahan ]
                EditLampuActionButtons(
                  isEdit: widget.isEdit,
                  onCancel: _handleBack,
                  onSave: _handleSubmit,
                ),

                const SizedBox(height: 28),
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


