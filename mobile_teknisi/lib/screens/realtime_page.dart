import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/app_colors.dart';
import 'scan_barcode_page.dart';

class RealtimePage extends StatefulWidget {
  const RealtimePage({super.key});

  @override
  State<RealtimePage> createState() => _RealtimePageState();
}

class _RealtimePageState extends State<RealtimePage> {
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _lampTypeController = TextEditingController();

  final FocusNode _longitudeFocusNode = FocusNode();
  final FocusNode _latitudeFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _lampTypeFocusNode = FocusNode();

  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
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
    _longitudeController.dispose();
    _latitudeController.dispose();
    _addressController.dispose();
    _lampTypeController.dispose();

    _longitudeFocusNode.removeListener(_onFocusChange);
    _latitudeFocusNode.removeListener(_onFocusChange);
    _addressFocusNode.removeListener(_onFocusChange);
    _lampTypeFocusNode.removeListener(_onFocusChange);

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

  void _handleScanBarcode() {
    debugPrint('Scan Barcode Disini clicked');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScanBarcodePage(),
      ),
    );
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

  void _handleSimpanData() {
    debugPrint('Simpan Data clicked');
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
                  'Metode Input Real-time',
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
                  'Ambil data lampu secara langsung di lokasi',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 1. Scan Barcode Card (Blue Card)
              _buildScanBarcodeCard(),

              const SizedBox(height: 24),

              // 2. Section: Lokasi Koordinat
              _buildSectionHeader(
                icon: Icons.language_rounded,
                title: 'Lokasi Koordinat',
                subtitle: 'Masukkan koordinat lampu (Long/Lat)',
                showInfoIcon: true,
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

              const SizedBox(height: 24),

              // 3. Section: Alamat Lokasi
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

              // Get Location Button (Green Button)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoadingLocation ? null : _handleGetLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.realtimeGreen,
                    foregroundColor: AppColors.buttonText,
                    disabledBackgroundColor: AppColors.realtimeGreen.withValues(alpha: 0.7),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoadingLocation
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Mengambil lokasi...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Column(
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

              const SizedBox(height: 24),

              // 4. Section: Tipe Lampu
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

              const SizedBox(height: 24),

              // 5. Section: Dokumentasi (opsional)
              _buildSectionHeader(
                icon: Icons.camera_alt_outlined,
                title: 'Dokumentasi (opsional)',
                subtitle: 'Tambahkan foto kondisi lampu (maks. 5 foto)',
              ),
              const SizedBox(height: 12),

              // Tambah Foto Button (Dashed / Dotted Box)
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

              const SizedBox(height: 28),

              // 6. Simpan Data Button (Blue Button)
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

  Widget _buildScanBarcodeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // QR Code Icon
          const Icon(
            Icons.qr_code_2_rounded,
            color: Colors.white,
            size: 52,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scan Barcode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Pindai barcode / QR code pada lampu',
                  style: TextStyle(
                    color: AppColors.cardTextSubtle,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _handleScanBarcode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    'Scan Barcode Disini',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showInfoIcon = false,
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
        if (showInfoIcon)
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.hintColor,
            size: 18,
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
