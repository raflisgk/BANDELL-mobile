import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'detail_lampu_page.dart';
import 'metode_pendataan_page.dart';

class LampItem {
  final int id;
  final String code;
  final String type;
  final String location;
  final String coordinates;
  final String status;
  final String photoText;
  final String updatedAt;

  const LampItem({
    required this.id,
    required this.code,
    required this.type,
    required this.location,
    required this.coordinates,
    required this.status,
    required this.photoText,
    required this.updatedAt,
  });
}

class LampPage extends StatefulWidget {
  final int? idArea;
  final String? areaName;

  const LampPage({super.key, this.idArea, this.areaName});

  @override
  State<LampPage> createState() => _LampPageState();
}

class _LampPageState extends State<LampPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  final List<LampItem> _dummyLamps = const [
    LampItem(
      id: 1,
      code: 'JKT-001',
      type: 'LED Street Light 100W',
      location: 'Jl. Sudirman No. 10, Jakarta',
      coordinates: '-6.2088, 106.8456',
      status: 'Tersimpan',
      photoText: '3 Foto',
      updatedAt: '20 Mei 2025, 14:30',
    ),
    LampItem(
      id: 2,
      code: 'JKT-002',
      type: 'LED Street Light 150W',
      location: 'Jl. Gatot Subroto, Jakarta',
      coordinates: '-6.2146, 106.8451',
      status: 'Tersimpan',
      photoText: '2 Foto',
      updatedAt: '19 Mei 2025, 16:20',
    ),
    LampItem(
      id: 3,
      code: 'JKT-003',
      type: 'LED Street Light 80W',
      location: 'Jl. Thamrin, Jakarta',
      coordinates: '-6.2012, 106.8270',
      status: 'Belum Lengkap',
      photoText: 'Belum ada foto',
      updatedAt: '18 Mei 2025, 11:45',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<LampItem> get _filteredLamps {
    return _dummyLamps.where((lamp) {
      if (_selectedFilter != 'Semua' && lamp.status != _selectedFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final codeMatch = lamp.code.toLowerCase().contains(query);
        final locMatch = lamp.location.toLowerCase().contains(query);
        if (!codeMatch && !locMatch) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _handleLampTap(LampItem lamp) {
    debugPrint('Lamp selected: ${lamp.code} (ID: ${lamp.id})');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailLampuPage(
          idLamp: lamp.id,
          lampCode: lamp.code,
          lampType: lamp.type,
          status: lamp.status,
        ),
      ),
    );
  }

  void _handleAddData() {
    debugPrint('Tambah Data pressed');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MetodePendataanPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredLamps;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleAddData,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.buttonText,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'Tambah Data',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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

              const SizedBox(height: 12),

              // Count Header Title
              const Center(
                child: Text(
                  '128 Lampu Tercatat',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.searchBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Cari nomor lampu atau lokasi...',
                    hintStyle: TextStyle(
                      color: AppColors.hintColor,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.hintColor,
                      size: 22,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Filter Chips Row
              Row(
                children: [
                  _buildFilterChip('Semua'),
                  const SizedBox(width: 10),
                  _buildFilterChip('Tersimpan'),
                  const SizedBox(width: 10),
                  _buildFilterChip('Belum Lengkap'),
                ],
              ),

              const SizedBox(height: 20),

              // Sort & Subtitle Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Text(
                        'Terbaru',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.swap_vert_rounded,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Daftar Lampu',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '128 Record',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Lamp Cards List Section
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: AppColors.hintColor,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Lampu tidak ditemukan',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final lamp = filtered[index];
                          return _buildLampCard(lamp);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLampCard(LampItem lamp) {
    final isTersimpan = lamp.status == 'Tersimpan';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTersimpan ? AppColors.border : AppColors.warningBorder,
          width: isTersimpan ? 1 : 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleLampTap(lamp),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Code & Badge Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lamp.code,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isTersimpan
                            ? AppColors.successLight
                            : AppColors.warningLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isTersimpan
                                ? Icons.check_circle_outline_rounded
                                : Icons.warning_amber_rounded,
                            color: isTersimpan
                                ? AppColors.success
                                : AppColors.warning,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            lamp.status,
                            style: TextStyle(
                              color: isTersimpan
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  lamp.type,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),

                // Location & Coordinates Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.iconColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lamp.location,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            lamp.coordinates,
                            style: const TextStyle(
                              color: AppColors.hintColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 12),

                // Bottom Row: Photos & Updated At
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: isTersimpan
                              ? AppColors.primary
                              : AppColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          lamp.photoText,
                          style: TextStyle(
                            color: isTersimpan
                                ? AppColors.primary
                                : AppColors.warning,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Diperbarui ${lamp.updatedAt}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
