import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/app_colors.dart';
import '../utils/page_transitions.dart';
import 'history_page.dart';
import 'scan_barcode_page.dart';

class RealtimePage extends StatefulWidget {
  const RealtimePage({super.key});

  @override
  State<RealtimePage> createState() => _RealtimePageState();
}

class _RealtimePageState extends State<RealtimePage> {
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _panelCodeController = TextEditingController();

  final FocusNode _latitudeFocusNode = FocusNode();
  final FocusNode _longitudeFocusNode = FocusNode();
  final FocusNode _panelCodeFocusNode = FocusNode();

  String? _scannedBarcode;
  bool _isLoadingLocation = false;
  final List<String> _photos = [];

  // Dummy sample photos to demonstrate photo addition if user taps "Tambah Foto"
  final List<String> _samplePhotoUrls = const [
    'https://images.unsplash.com/photo-1517646287270-a5a9ca602e5c?auto=format&fit=crop&w=300&q=80',
    'https://images.unsplash.com/photo-1509114397022-ed747cca3f65?auto=format&fit=crop&w=300&q=80',
    'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=300&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _latitudeFocusNode.addListener(_onFocusChange);
    _longitudeFocusNode.addListener(_onFocusChange);
    _panelCodeFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _panelCodeController.dispose();

    _latitudeFocusNode.removeListener(_onFocusChange);
    _longitudeFocusNode.removeListener(_onFocusChange);
    _panelCodeFocusNode.removeListener(_onFocusChange);

    _latitudeFocusNode.dispose();
    _longitudeFocusNode.dispose();
    _panelCodeFocusNode.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleScanBarcode() async {
    debugPrint('Scan Barcode clicked');
    final String? result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const ScanBarcodePage(),
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        _scannedBarcode = result.trim();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Barcode berhasil discan: $_scannedBarcode'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
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
            content: Text('Layanan lokasi (GPS) nonaktif. Harap aktifkan GPS Anda.'),
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
              content: Text('Izin lokasi diperlukan untuk mengambil koordinat.'),
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
            content: Text('Izin lokasi ditolak permanen. Buka pengaturan untuk mengaktifkan.'),
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
        _latitudeController.text = position.latitude.toStringAsFixed(4);
        _longitudeController.text = position.longitude.toStringAsFixed(4);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lokasi GPS berhasil diambil: Lat ${_latitudeController.text}, Long ${_longitudeController.text}'),
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
    if (_photos.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimal 5 foto telah tercapai'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final String nextPhoto = _samplePhotoUrls[_photos.length % _samplePhotoUrls.length];
    setState(() {
      _photos.add(nextPhoto);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Foto ${_photos.length} ditambahkan'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleSimpanData() {
    debugPrint('Simpan Data clicked. Barcode: $_scannedBarcode, Lat: ${_latitudeController.text}, Long: ${_longitudeController.text}, Panel: ${_panelCodeController.text}');
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    final String lampCode = (_scannedBarcode != null && _scannedBarcode!.isNotEmpty)
        ? _scannedBarcode!
        : (_panelCodeController.text.isNotEmpty
            ? _panelCodeController.text
            : 'JKT-2025-004');

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Green Checkmark Badge
              const _AnimatedCheckBadge(),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Data Berhasil Disimpan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle / Description with Dynamic Lamp Code
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.5,
                    height: 1.45,
                  ),
                  children: [
                    const TextSpan(text: 'Informasi lampu '),
                    TextSpan(
                      text: lampCode,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text: ' telah\ntersimpan ke dalam database sistem.',
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // Button 1: Tambah Data
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    setState(() {
                      _scannedBarcode = null;
                      _latitudeController.clear();
                      _longitudeController.clear();
                      _panelCodeController.clear();
                      _photos.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Form direset. Siap memasukkan data lampu berikutnya.'),
                        backgroundColor: AppColors.primary,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tambah Data',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Button 2: Lihat Riwayat
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  AppNavigator.pushTabReplacement(
                    context,
                    const HistoryPage(),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  'Lihat Riwayat',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
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

  @override
  Widget build(BuildContext context) {
    final bool hasScanned = _scannedBarcode != null && _scannedBarcode!.isNotEmpty;
    final bool hasLocation = _latitudeController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Back Button
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

              const SizedBox(height: 16),

              // Title & Subtitle
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

              // 1. BARCODE CARD (Kondisi Awal / Teridentifikasi)
              hasScanned ? _buildIdentifiedCard() : _buildInitialScanCard(),

              const SizedBox(height: 20),
              const Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
              const SizedBox(height: 20),

              // 2. LOKASI KOORDINAT SECTION
              _buildSectionHeader(
                icon: Icons.language_rounded,
                title: 'Lokasi Koordinat',
                showRedAsterisk: true,
                subtitle: 'Masukkan koordinat lampu (Lat/Long)',
              ),
              const SizedBox(height: 14),

              if (hasLocation) ...[
                // Field 1: Latitude
                _buildCustomTextField(
                  controller: _latitudeController,
                  focusNode: _latitudeFocusNode,
                  hint: '',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                ),
                const SizedBox(height: 12),
                // Field 2: Longitude
                _buildCustomTextField(
                  controller: _longitudeController,
                  focusNode: _longitudeFocusNode,
                  hint: '',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                ),
              ] else ...[
                // Get Location Button
                _buildGetLocationButton(),
              ],

              const SizedBox(height: 20),
              const Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
              const SizedBox(height: 20),

              // 3. KODE PANEL SECTION
              _buildSectionHeader(
                icon: Icons.language_rounded,
                title: 'Kode Panel',
                optionalText: '(Opsional)',
                subtitle: 'Masukkan kode lampu',
              ),
              const SizedBox(height: 14),
              _buildCustomTextField(
                controller: _panelCodeController,
                focusNode: _panelCodeFocusNode,
                hint: '',
              ),

              const SizedBox(height: 20),
              const Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
              const SizedBox(height: 20),

              // 4. DOKUMENTASI SECTION
              _buildSectionHeader(
                icon: Icons.camera_alt_outlined,
                title: 'Dokumentasi',
                optionalText: '(Opsional)',
                subtitle: 'Tambahkan foto kondisi lampu (maks. 5 foto)',
              ),
              const SizedBox(height: 14),
              _buildDocumentationSection(),

              const SizedBox(height: 28),

              // 5. SIMPAN DATA BUTTON
              _buildSimpanDataButton(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Barcode Card Kondisi Awal (Blue)
  Widget _buildInitialScanCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0C5DA5),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
            size: 56,
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
                    color: Colors.white70,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 12),
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(
                    Icons.qr_code_scanner,
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

  // Barcode Card Kondisi Teridentifikasi (Light Blue)
  Widget _buildIdentifiedCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFC7DBEC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFA3C7E8),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'TERIDENTIFIKASI',
                  style: TextStyle(
                    color: Color(0xFF16A34A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _scannedBarcode ?? '',
                  style: const TextStyle(
                    color: Color(0xFF1E2B45),
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _handleScanBarcode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 2,
              shadowColor: Colors.black.withValues(alpha: 0.15),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(
              Icons.qr_code_scanner_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            label: const Text(
              'Scan Ulang',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get Location Button
  Widget _buildGetLocationButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoadingLocation ? null : _handleGetLocation,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF15803D),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF15803D).withValues(alpha: 0.7),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6),
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
                    'Ambil koordinat otomatis dari GPS',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Dokumentasi Section (Photo Thumbnails + Add Photo Box)
  Widget _buildDocumentationSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          ..._photos.map((photoUrl) => Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(
                            Icons.broken_image_rounded,
                            color: AppColors.hintColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )),
          if (_photos.length < 5)
            GestureDetector(
              onTap: _handleTambahFoto,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1.2,
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
    );
  }

  // Simpan Data Button
  Widget _buildSimpanDataButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleSimpanData,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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
                color: Colors.white70,
                fontWeight: FontWeight.w400,
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
    bool showRedAsterisk = false,
    String? optionalText,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (showRedAsterisk)
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (optionalText != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      optionalText,
                      style: const TextStyle(
                        color: AppColors.hintColor,
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.hintColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isFocused = focusNode.hasFocus;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFocused ? AppColors.borderFocused : AppColors.border,
          width: isFocused ? 1.5 : 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
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
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _AnimatedCheckBadge extends StatefulWidget {
  const _AnimatedCheckBadge();

  @override
  State<_AnimatedCheckBadge> createState() => _AnimatedCheckBadgeState();
}

class _AnimatedCheckBadgeState extends State<_AnimatedCheckBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _checkScaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xFF15803D),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF15803D).withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: ScaleTransition(
            scale: _checkScaleAnimation,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF15803D),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
