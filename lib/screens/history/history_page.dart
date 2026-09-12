import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/project_model.dart';
import '../../services/auth_service.dart';
import '../../services/installation_service.dart';
import '../../services/project_service.dart';
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
  List<HistoryLampItem> _historyItems = [];
  bool _isLoading = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _selectedProject = ProjectService.selectedProject?.projectName;
    _loadHistory();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _loadHistorySilently(),
    );
  }

  Future<void> _loadHistorySilently() async {
    final proj = _currentProject;
    if (proj == null) return;

    final (startDate, endDate) = _getDateRangeForFilter(_selectedFilter);

    try {
      final history = await InstallationService().getHistory(
        userId: AuthService.currentUser?.idUser ?? 0,
        projectId: proj.idProject,
        startDate: startDate,
        endDate: endDate,
      );
      if (!mounted) return;
      final newItems = history
          .map((item) => HistoryLampItem(
                idHistory: item.idHistory,
                userId: item.userId,
                projectId: item.projectId,
                areaId: item.areaId,
                districtName: item.districtName,
                kode: item.kode.isNotEmpty
                    ? item.kode
                    : (item.idLcu ?? '-'),
                jenis: item.jenis,
                status: item.status,
                isVerified: item.isVerified,
                lokasi: item.lokasi,
                koordinat: item.koordinat,
                latitude: item.latitude,
                longitude: item.longitude,
                fotoCount: item.fotoCount,
                waktu: item.waktu,
                tanggal: item.tanggal,
                installedAt: item.installedAt,
                createdAt: item.createdAt,
                updatedAt: item.updatedAt,
                inputMethod: item.inputMethod,
                panelCode: item.panelCode,
                idLcu: item.idLcu ?? (item.kode.isNotEmpty ? item.kode : null),
                installation: item.installation,
              ))
          .toList();
      setState(() {
        _historyItems = newItems;
      });
    } catch (e) {
      debugPrint('Auto refresh error in HistoryPage: $e');
    }
  }

  DateTime _subtractOneMonth(DateTime date) {
    var year = date.year;
    var month = date.month - 1;
    var day = date.day;
    if (month < 1) {
      month = 12;
      year -= 1;
    }
    final daysInMonth = DateTime(year, month + 1, 0).day;
    if (day > daysInMonth) {
      day = daysInMonth;
    }
    return DateTime(year, month, day);
  }

  (DateTime?, DateTime?) _getDateRangeForFilter(String filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case 'Hari Ini':
        return (today, today);

      case '7 Hari':
        // Termasuk hari ini + 6 hari sebelumnya = 7 hari
        final start = today.subtract(const Duration(days: 6));
        return (start, today);

      case '1 Bulan':
        final start = _subtractOneMonth(today);
        return (start, today);

      case 'Pilih Tanggal':
        if (_rangeStartDate != null && _rangeEndDate != null) {
          final start = DateTime(
            _rangeStartDate!.year,
            _rangeStartDate!.month,
            _rangeStartDate!.day,
          );
          final end = DateTime(
            _rangeEndDate!.year,
            _rangeEndDate!.month,
            _rangeEndDate!.day,
          );
          return (start, end);
        } else if (_rangeStartDate != null) {
          final d = DateTime(
            _rangeStartDate!.year,
            _rangeStartDate!.month,
            _rangeStartDate!.day,
          );
          return (d, d);
        }
        return (null, null);

      default:
        return (null, null);
    }
  }

  Future<void> _loadHistory() async {
    final proj = _currentProject;
    if (proj == null) {
      setState(() {
        _historyItems = [];
        _isLoading = false;
      });
      return;
    }

    final (startDate, endDate) = _getDateRangeForFilter(_selectedFilter);

    debugPrint('HISTORY FILTER: $_selectedFilter');
    debugPrint('START DATE: $startDate');
    debugPrint('END DATE: $endDate');

    setState(() => _isLoading = true);
    try {
      final history = await InstallationService().getHistory(
        userId: AuthService.currentUser?.idUser ?? 0,
        projectId: proj.idProject,
        startDate: startDate,
        endDate: endDate,
      );
      if (mounted) {
        setState(() {
          _historyItems = history
              .map((item) => HistoryLampItem(
                    idHistory: item.idHistory,
                    userId: item.userId,
                    projectId: item.projectId,
                    areaId: item.areaId,
                    districtName: item.districtName,
                    kode: item.kode.isNotEmpty
                        ? item.kode
                        : (item.idLcu ?? '-'),
                    jenis: item.jenis,
                    status: item.status,
                    isVerified: item.isVerified,
                    lokasi: item.lokasi,
                    koordinat: item.koordinat,
                    latitude: item.latitude,
                    longitude: item.longitude,
                    fotoCount: item.fotoCount,
                    waktu: item.waktu,
                    tanggal: item.tanggal,
                    installedAt: item.installedAt,
                    createdAt: item.createdAt,
                    updatedAt: item.updatedAt,
                    inputMethod: item.inputMethod,
                    panelCode: item.panelCode,
                    idLcu: item.idLcu ?? (item.kode.isNotEmpty ? item.kode : null),
                    installation: item.installation,
                  ))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  ProjectModel? get _currentProject {
    if (_selectedProject != null) {
      return ProjectService.getProjectByName(_selectedProject!);
    }
    return ProjectService.selectedProject;
  }

 
  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  DateTime? _extractDateOnly(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) {
      final local = raw.isUtc ? raw.toLocal() : raw;
      return DateTime(local.year, local.month, local.day);
    }
    final str = raw.toString().trim();
    if (str.isEmpty || str == '-' || str.toLowerCase() == 'null') return null;

    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(str);
    if (match != null) {
      final y = int.parse(match.group(1)!);
      final m = int.parse(match.group(2)!);
      final d = int.parse(match.group(3)!);
      return DateTime(y, m, d);
    }

    final dt = DateTime.tryParse(str);
    if (dt != null) {
      final local = dt.toLocal();
      return DateTime(local.year, local.month, local.day);
    }
    return null;
  }

  bool _matchesDateFilter(HistoryLampItem item, String filter) {
    final (startDate, endDate) = _getDateRangeForFilter(filter);
    if (startDate == null && endDate == null) return true;

    // HANYA gunakan created_at (tanggal record dibuat).
    final itemDate = _extractDateOnly(item.createdAt) ??
        _extractDateOnly(item.installation?.createdAt);

    if (itemDate == null) return false;

    if (startDate != null && itemDate.isBefore(startDate)) {
      return false;
    }
    if (endDate != null && itemDate.isAfter(endDate)) {
      return false;
    }
    return true;
  }

  List<HistoryLampItem> get _filteredItems {
    var items = _historyItems
        .where((item) => _matchesDateFilter(item, _selectedFilter))
        .toList();

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      items = items.where((item) {
        return item.kode.toLowerCase().contains(query) ||
            (item.idLcu != null && item.idLcu!.toLowerCase().contains(query)) ||
            (item.districtName != null &&
                item.districtName!.toLowerCase().contains(query)) ||
            (item.installation?.districtName != null &&
                item.installation!.districtName!.toLowerCase().contains(query)) ||
            item.lokasi.toLowerCase().contains(query) ||
            item.koordinat.toLowerCase().contains(query) ||
            item.jenis.toLowerCase().contains(query);
      }).toList();
    }

    // Sorting "Terbaru" berdasarkan created_at (record paling baru di atas).
    items.sort((a, b) {
      final dateA = a.createdAt ?? a.installation?.createdAt;
      final dateB = b.createdAt ?? b.installation?.createdAt;

      if (dateA != null && dateB != null) {
        final cmp = dateB.compareTo(dateA);
        if (cmp != 0) return cmp;
      } else if (dateA != null) {
        return -1;
      } else if (dateB != null) {
        return 1;
      }

      final idA = a.idHistory ?? 0;
      final idB = b.idHistory ?? 0;
      return idB.compareTo(idA);
    });

    return items;
  }

  Future<void> _handleFilterTap(String filter) async {
    if (filter == 'Pilih Tanggal') {
      final result = await PilihTanggal.show(
        context,
        initialStartDate: _rangeStartDate,
        initialEndDate: _rangeEndDate,
      );

      if (result != null && result['startDate'] != null) {
        setState(() {
          _selectedFilter = 'Pilih Tanggal';
          _rangeStartDate = result['startDate'];
          _rangeEndDate = result['endDate'] ?? result['startDate'];
        });
        await _loadHistory();
      }
    } else {
      setState(() {
        _selectedFilter = filter;
      });
      await _loadHistory();
    }
  }

  void _handleCardTap(HistoryLampItem item) async {
    final effectiveCode = (item.idLcu != null && item.idLcu!.trim().isNotEmpty)
        ? item.idLcu!
        : (item.kode.trim().isNotEmpty ? item.kode : '-');

    await AppNavigator.push(
      context,
      DetailLampuPage(
        idInstallation: item.idHistory,
        lampCode: effectiveCode,
        lampType: item.jenis,
        status: item.status,
        latitude: item.koordinat.contains(',')
            ? item.koordinat.split(',')[0].trim()
            : null,
        longitude: item.koordinat.contains(',')
            ? item.koordinat.split(',')[1].trim()
            : null,
        address: item.lokasi,
        createdAt: item.createdAt?.toIso8601String() ?? item.installation?.createdAt?.toIso8601String(),
        updatedAt: item.updatedAt?.toIso8601String() ?? item.installation?.updatedAt?.toIso8601String(),
        wattage: '120W',
        installation: item.installation,
        inputMethod: item.inputMethod,
        panelCode: item.panelCode,
      ),
    );

    if (mounted) {
      _loadHistory();
    }
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
                physics: const ClampingScrollPhysics(),
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
                physics: const ClampingScrollPhysics(),
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
                    '${filtered.length} Instalasi',
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
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                )
              else if (_currentProject == null)
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
                for (final item in filtered)
                  HistoryLampCard(
                    item: item,
                    onTap: () => _handleCardTap(item),
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

