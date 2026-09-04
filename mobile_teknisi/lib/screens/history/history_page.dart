import 'package:flutter/material.dart';
import '../../dummy/dummy_data.dart';
import '../../models/project_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/bottom_navbar.dart';
import '../area_operasional/area_operasional_page.dart';
import '../detail_lampu/detail_lampu_page.dart';
import '../profile/profile_page.dart';
import 'history_lamp_card.dart';
import 'pilih_tanggal.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String _selectedFilter = '1 Bulan';
  DateTime? _rangeStartDate;
  DateTime? _rangeEndDate;
  String? _selectedProject;

  @override
  void initState() {
    super.initState();
    _selectedProject = DummyData.selectedProject?.projectName;
  }

  Project? get _currentProject {
    if (_selectedProject != null) {
      return DummyData.getProjectByName(_selectedProject!);
    }
    return DummyData.selectedProject;
  }

  List<HistoryLampItem> get _baseHistoryItems {
    final proj = _currentProject;
    if (proj == null) {
      return const [];
    }
    return DummyData.getHistoryByUserAndProject(
      userId: DummyData.currentUser.idUser,
      projectId: proj.idProject,
    );
  }

  bool _matchesTimeFilter(HistoryLampItem item) {
    final itemDate = item.tanggal;
    if (itemDate == null) return true;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    switch (_selectedFilter) {
      case 'Hari Ini':
        final itemDay = DateTime(itemDate.year, itemDate.month, itemDate.day);
        return itemDay.isAtSameMomentAs(todayStart);

      case '7 Hari':
        // Riwayat dalam 7 hari terakhir (hari ini + 6 hari ke belakang)
        final sevenDaysAgo = todayStart.subtract(const Duration(days: 6));
        return !itemDate.isBefore(sevenDaysAgo) && !itemDate.isAfter(todayEnd);

      case '1 Bulan':
        // Riwayat dalam 1 bulan terakhir (hari ini + 29 hari ke belakang)
        final oneMonthAgo = todayStart.subtract(const Duration(days: 29));
        return !itemDate.isBefore(oneMonthAgo) && !itemDate.isAfter(todayEnd);

      case 'Pilih Tanggal':
        if (_rangeStartDate == null || _rangeEndDate == null) return true;
        final start = DateTime(
          _rangeStartDate!.year,
          _rangeStartDate!.month,
          _rangeStartDate!.day,
          0,
          0,
          0,
        );
        final end = DateTime(
          _rangeEndDate!.year,
          _rangeEndDate!.month,
          _rangeEndDate!.day,
          23,
          59,
          59,
          999,
        );
        return !itemDate.isBefore(start) && !itemDate.isAfter(end);

      default:
        return true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<HistoryLampItem> get _filteredItems {
    final baseItems = _baseHistoryItems;
    final timeFiltered = baseItems.where(_matchesTimeFilter).toList();

    if (_searchQuery.trim().isEmpty) {
      return timeFiltered;
    }
    final query = _searchQuery.toLowerCase().trim();
    return timeFiltered.where((item) {
      return item.kode.toLowerCase().contains(query) ||
          item.lokasi.toLowerCase().contains(query) ||
          item.jenis.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _handleFilterTap(String filter) async {
    if (filter == 'Pilih Tanggal') {
      final result = await PilihTanggal.show(
        context,
        initialStartDate: _rangeStartDate,
        initialEndDate: _rangeEndDate,
      );

      if (result != null &&
          result['startDate'] != null &&
          result['endDate'] != null) {
        setState(() {
          _selectedFilter = 'Pilih Tanggal';
          _rangeStartDate = result['startDate'];
          _rangeEndDate = result['endDate'];
        });
      }
    } else {
      setState(() {
        _selectedFilter = filter;
      });
    }
  }

  void _handleCardTap(HistoryLampItem item) {
    AppNavigator.push(
      context,
      DetailLampuPage(
        lampCode: item.kode,
        lampType: item.jenis,
        status: item.status,
        wattage: '120W',
      ),
    );
  }

  void _handleNavTap(int index) {
    if (index == 0) {
      AppNavigator.pushTabReplacement(context, const AreaOperasionalPage());
    } else if (index == 2) {
      AppNavigator.pushTabReplacement(context, const ProfilePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

              // Header Title & Subtitle
              const Text(
                'Riwayat Pemasangan Lampu',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Daftar seluruh riwayat instalasi dan pemantauan lampu.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 16),

              // Search Input Box
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Cari kode / jenis lampu...',
                    hintStyle: TextStyle(
                      color: AppColors.hintColor,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.hintColor,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Filter Horizontal Pills (Hari Ini, 7 Hari, 1 Bulan, Pilih Tanggal)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterPill('Hari Ini'),
                    const SizedBox(width: 8),
                    _buildFilterPill('7 Hari'),
                    const SizedBox(width: 8),
                    _buildFilterPill('1 Bulan'),
                    const SizedBox(width: 8),
                    _buildFilterPill('Pilih Tanggal'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section Header: Terbaru & Daftar Lampu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text(
                            'Terbaru',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.swap_vert_rounded,
                            size: 14,
                            color: Color(0xFF64748B),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Daftar Lampu',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${filtered.length} Record',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // List of History Cards
              if (_currentProject == null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.touch_app_outlined,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Pilih Project Terlebih Dahulu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Gunakan dropdown di atas untuk melihat riwayat pada proyek tertentu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else if (filtered.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.history_rounded,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Belum Ada Riwayat Pendataan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedFilter == 'Pilih Tanggal' &&
                                _rangeStartDate != null &&
                                _rangeEndDate != null
                            ? 'Tidak ada riwayat dalam rentang ${_rangeStartDate!.day} ${PilihTanggal.monthNames[_rangeStartDate!.month - 1]} ${_rangeStartDate!.year} – ${_rangeEndDate!.day} ${PilihTanggal.monthNames[_rangeEndDate!.month - 1]} ${_rangeEndDate!.year}.'
                            : 'Tidak ada riwayat untuk filter "$_selectedFilter" pada project "${_currentProject?.projectName}".',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return HistoryLampCard(
                      item: item,
                      onTap: () => _handleCardTap(item),
                    );
                  },
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ],
  ),
),
      bottomNavigationBar: BottomNavbar(
        currentIndex: 1,
        onTap: _handleNavTap,
      ),
    );
  }

  Widget _buildFilterPill(String label) {
    final bool isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () => _handleFilterTap(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x29000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

