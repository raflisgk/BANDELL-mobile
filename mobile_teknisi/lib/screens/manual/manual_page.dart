import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../dummy/dummy_data.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/dokumentasi.dart';
import '../../widgets/kode_panel.dart';
import '../../widgets/pop_up_sukses.dart';
import '../../widgets/tombol_simpan_data.dart';

class ManualPage extends StatefulWidget {
  const ManualPage({super.key});

  @override
  State<ManualPage> createState() => _ManualPageState();
}

class _ManualPageState extends State<ManualPage> {
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _panelCodeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  final FocusNode _barcodeFocusNode = FocusNode();
  final FocusNode _panelCodeFocusNode = FocusNode();
  final FocusNode _latitudeFocusNode = FocusNode();
  final FocusNode _longitudeFocusNode = FocusNode();

  final List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    _barcodeFocusNode.addListener(_onFocusChange);
    _panelCodeFocusNode.addListener(_onFocusChange);
    _latitudeFocusNode.addListener(_onFocusChange);
    _longitudeFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _panelCodeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();

    _barcodeFocusNode.removeListener(_onFocusChange);
    _panelCodeFocusNode.removeListener(_onFocusChange);
    _latitudeFocusNode.removeListener(_onFocusChange);
    _longitudeFocusNode.removeListener(_onFocusChange);

    _barcodeFocusNode.dispose();
    _panelCodeFocusNode.dispose();
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
    if (_photos.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimal 5 foto sudah tercapai'),
          backgroundColor: Color(0xFFEF4444),
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
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: $e'),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _handleSimpanData() {
    final isProjectClosed = DummyData.selectedProject?.status == 'closed' ||
        DummyData.selectedProject?.status == 'selesai';
    if (isProjectClosed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat menyimpan data. Project telah Selesai.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final barcode = _barcodeController.text.trim();
    final latitude = _latitudeController.text.trim();
    final longitude = _longitudeController.text.trim();

    if (barcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID Barcode wajib diisi'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      _barcodeFocusNode.requestFocus();
      return;
    }

    if (latitude.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Latitude wajib diisi'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      _latitudeFocusNode.requestFocus();
      return;
    }

    if (longitude.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Longitude wajib diisi'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      _longitudeFocusNode.requestFocus();
      return;
    }

    _showSuccessDialog(barcode);
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
        _barcodeController.clear();
        _panelCodeController.clear();
        _latitudeController.clear();
        _longitudeController.clear();
        setState(() {
          _photos.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Form direset. Siap memasukkan data lampu berikutnya.'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
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

                          // 4. DOKUMENTASI (SHARED WIDGET)
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

  // 1. ID Barcode Section
  Widget _buildBarcodeInput() {
    final bool isFocused = _barcodeFocusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.wb_incandescent_outlined,
                color: AppColors.primary,
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
              color: isFocused ? AppColors.primary : AppColors.border,
              width: isFocused ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: _barcodeController,
            focusNode: _barcodeFocusNode,
            style: const TextStyle(
              color: AppColors.textPrimary,
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
      ],
    );
  }

  // 3. Lokasi Koordinat Section (Manual Lat/Long Inputs, No Get Location Button)
  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Lokasi Koordinat',
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
        ),
        const SizedBox(height: 10),
        _buildLocationInputField(
          controller: _longitudeController,
          focusNode: _longitudeFocusNode,
          hint: 'Longitude',
        ),
      ],
    );
  }

  Widget _buildLocationInputField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String hint,
  }) {
    final bool isFocused = focusNode?.hasFocus ?? false;

    return Container(
      decoration: BoxDecoration(
        color: isFocused ? Colors.white : AppColors.inputBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFocused ? AppColors.primary : AppColors.border,
          width: isFocused ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        style: const TextStyle(
          color: AppColors.textPrimary,
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
    );
  }
}
