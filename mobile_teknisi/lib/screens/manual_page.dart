import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ManualPage extends StatefulWidget {
  const ManualPage({super.key});

  @override
  State<ManualPage> createState() => _ManualPageState();
}

class _ManualPageState extends State<ManualPage> {
  final TextEditingController _kodeLampuController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _lampTypeController = TextEditingController();

  final FocusNode _kodeLampuFocusNode = FocusNode();
  final FocusNode _longitudeFocusNode = FocusNode();
  final FocusNode _latitudeFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _lampTypeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _kodeLampuFocusNode.addListener(_onFocusChange);
    _longitudeFocusNode.addListener(_onFocusChange);
    _latitudeFocusNode.addListener(_onFocusChange);
    _addressFocusNode.addListener(_onFocusChange);
    _lampTypeFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _kodeLampuController.dispose();
    _longitudeController.dispose();
    _latitudeController.dispose();
    _addressController.dispose();
    _lampTypeController.dispose();

    _kodeLampuFocusNode.removeListener(_onFocusChange);
    _longitudeFocusNode.removeListener(_onFocusChange);
    _latitudeFocusNode.removeListener(_onFocusChange);
    _addressFocusNode.removeListener(_onFocusChange);
    _lampTypeFocusNode.removeListener(_onFocusChange);

    _kodeLampuFocusNode.dispose();
    _longitudeFocusNode.dispose();
    _latitudeFocusNode.dispose();
    _addressFocusNode.dispose();
    _lampTypeFocusNode.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _handleGetLocation() {
    debugPrint('Get Location');
    setState(() {
      _longitudeController.text = '106.8456';
      _latitudeController.text = '-6.2088';
      _addressController.text = 'Jl. Sudirman No. 10, Jakarta';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Koordinat & Alamat Otomatis Berhasil Diambil (Simulasi UI)'),
        backgroundColor: AppColors.realtimeGreen,
        duration: Duration(seconds: 1),
      ),
    );
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

  void _handleSimpanData() {
    debugPrint('Simpan Data');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data Berhasil Disimpan (Simulasi UI)'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Header: Back Arrow Icon
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

              // Centered Title & Subtitle
              const Center(
                child: Text(
                  'Metode Input Manual',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
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
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Card Utama Form Container
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1.0,
                  ),
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
                    // SECTION 1 — KODE LAMPU
                    _buildSectionHeader(
                      icon: Icons.lightbulb_outline_rounded,
                      title: 'Kode Lampu',
                      subtitle: 'Masukkan kode lampu',
                    ),
                    const SizedBox(height: 12),
                    _buildCustomTextField(
                      controller: _kodeLampuController,
                      focusNode: _kodeLampuFocusNode,
                      hint: '',
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 20),

                    // SECTION 2 — LOKASI KOORDINAT
                    _buildSectionHeader(
                      icon: Icons.language_rounded,
                      title: 'Lokasi Koordinat',
                      subtitle: 'Masukkan koordinat lampu (Long/Lat)',
                    ),
                    const SizedBox(height: 12),
                    _buildCustomTextField(
                      controller: _longitudeController,
                      focusNode: _longitudeFocusNode,
                      hint: 'Longitude (X)',
                    ),
                    const SizedBox(height: 12),
                    _buildCustomTextField(
                      controller: _latitudeController,
                      focusNode: _latitudeFocusNode,
                      hint: 'Latitude (Y)',
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 20),

                    // SECTION 3 — ALAMAT LOKASI
                    _buildSectionHeader(
                      icon: Icons.map_outlined,
                      title: 'Alamat Lokasi',
                      subtitle: 'Masukkan alamat sesuai lokasi lampu',
                    ),
                    const SizedBox(height: 12),
                    _buildCustomTextField(
                      controller: _addressController,
                      focusNode: _addressFocusNode,
                      hint: 'Contoh: Jl. Sudirman No. 10, Jakarta',
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 14),

                    // GET LOCATION BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleGetLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.realtimeGreen,
                          foregroundColor: AppColors.buttonText,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.my_location_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Get Location',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Ambil koordinat dan alamat otomatis dari GPS',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.cardTextSubtle,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 20),

                    // SECTION 4 — TIPE LAMPU
                    _buildSectionHeader(
                      icon: Icons.lightbulb_outline_rounded,
                      title: 'Tipe Lampu',
                      subtitle: 'Pilih tipe / jenis lampu',
                    ),
                    const SizedBox(height: 12),
                    _buildCustomTextField(
                      controller: _lampTypeController,
                      focusNode: _lampTypeFocusNode,
                      hint: '',
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 20),

                    // SECTION 5 — DOKUMENTASI (OPSIONAL)
                    _buildSectionHeader(
                      icon: Icons.camera_alt_outlined,
                      title: 'Dokumentasi (opsional)',
                      subtitle: 'Tambahkan foto kondisi lampu (maks. 5 foto)',
                    ),
                    const SizedBox(height: 12),

                    // Tambah Foto Button (Dashed/Bordered Box)
                    GestureDetector(
                      onTap: _handleTambahFoto,
                      child: Container(
                        width: 110,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.searchBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.add_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tambah Foto',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // BUTTON SIMPAN DATA (Outside Card)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSimpanData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.buttonText,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.file_upload_outlined,
                            size: 18,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Simpan Data',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Data akan disimpan ke daftar lampu',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.cardTextSubtle,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),
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
