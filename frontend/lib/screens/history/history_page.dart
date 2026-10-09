import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/history_lamp_model.dart';
import '../../models/project_model.dart';
import '../../services/auth_service.dart';
import '../../services/installation_service.dart';
import '../../services/local_cache_service.dart';
import '../../services/main_navigation_service.dart';
import '../../services/offline_sync_service.dart';
import '../../services/project_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/bottom_navbar.dart';
import '../../widgets/custom_feedback.dart';
import '../area_operasional/area_operasional_page.dart';
import '../detail_lampu/detail_lampu_page.dart';
import '../profile/profile_page.dart';
import 'history_lamp_card.dart';

import 'package:skeletonizer/skeletonizer.dart';

import '../../widgets/pilih_tanggal.dart';

class HistoryPage extends StatefulWidget {
  final bool isEmbedded;
  const HistoryPage({super.key, this.isEmbedded = false});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String _selectedFilter = '1 Bulan';
  DateTime? _rangeStartDate;
  DateTime? _rangeEndDate;

  List<HistoryLampModel> _historyItems = [];
  bool _isLoading = true;
  bool _isSortDescending = true;

  List<HistoryLampModel> _loadCachedItemsSync(ProjectModel? project, String filter) {
    final userId = AuthService.currentUser?.idUser ?? 0;
    if (project == null) {
      final offlineItems = OfflineSyncService.getQueueSync(
        userId: userId,
      ).map((e) => e.toHistoryLampModel()).toList();
      return offlineItems;
    }
    final (startDate, endDate) = _getDateRangeForFilter(filter);
    final sDate = startDate?.toIso8601String().split('T').first ?? '';
    final eDate = endDate?.toIso8601String().split('T').first ?? '';

    final syncJson = LocalCacheService.getHistoryJsonSync(
      userId: userId,
      projectId: project.idProject,
      filter: filter,
      start: sDate,
      end: eDate,
    );
    final offlineItems = OfflineSyncService.getQueueSync(
      userId: userId,
      projectId: project.idProject,
    ).map((e) => e.toHistoryLampModel()).toList();

    final cached = (syncJson ?? [])
        .map((item) =>
            HistoryLampModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return [...offlineItems, ...cached];
  }

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 [NAVIGASI LAZY] Tab 1: HistoryPage baru pertama kali diinisialisasi!');
    final proj = _currentProject;
    final cached = _loadCachedItemsSync(proj, _selectedFilter);
    if (cached.isNotEmpty) {
      _historyItems = cached;
      _isLoading = false;
    } else {
      _isLoading = proj == null;
    }

    _initProjectAndHistory();
    OfflineSyncService().pendingCountNotifier.addListener(_onPendingCountChanged);
    MainNavigationService.currentTabNotifier.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (MainNavigationService.currentIndex == 1 && mounted) {
      _loadHistorySilently();
    }
  }

  void _onPendingCountChanged() {
    if (mounted) {
      _loadHistorySilently();
    }
  }

  Future<void> _initProjectAndHistory() async {
    final userId = AuthService.currentUser?.idUser ?? 0;
    ProjectModel? activeProject = ProjectService.selectedProject;

    if (activeProject == null) {
      List<ProjectModel> loadedProjects = [];
      if (ProjectService.hasCachedProjects) {
        loadedProjects = List<ProjectModel>.from(ProjectService.cachedProjects);
      } else {
        final cachedJson = await LocalCacheService.getProjectsJson(userId);
        if (cachedJson != null && cachedJson.isNotEmpty) {
          final projects = await ProjectService().getProjects(userId);
          loadedProjects = List<ProjectModel>.from(projects);
        }
      }

      loadedProjects.sort((a, b) => a.id.compareTo(b.id));

      final savedId = await LocalCacheService.getSelectedProjectId();
      if (savedId != null && loadedProjects.isNotEmpty) {
        final matches = loadedProjects.where((p) => p.id == savedId);
        if (matches.isNotEmpty) activeProject = matches.first;
      }

      if (activeProject == null && loadedProjects.isNotEmpty) {
        activeProject = loadedProjects.first;
      }

      if (activeProject != null) {
        ProjectService.selectedProject = activeProject;
        await LocalCacheService.saveSelectedProjectId(activeProject.id);
      }
    }

    if (activeProject != null) {
      final cached = _loadCachedItemsSync(activeProject, _selectedFilter);
      if (cached.isNotEmpty && mounted) {
        setState(() {
          _historyItems = cached;
          _isLoading = false;
        });
      }
    }

    _loadHistorySilently();
  }

  Future<void> _loadHistorySilently() async {
    final proj = _currentProject;
    if (proj == null) return;

    final (startDate, endDate) = _getDateRangeForFilter(_selectedFilter);
    final userId = AuthService.currentUser?.idUser ?? 0;

    try {
      final history = await InstallationService().getHistory(
        userId: userId,
        projectId: proj.idProject,
        startDate: startDate,
        endDate: endDate,
        forceRefresh: true,
      );

      final offlineQueue = await OfflineSyncService().getQueue(
        userId: userId,
        projectId: proj.idProject,
      );
      final offlineModels =
          offlineQueue.map((e) => e.toHistoryLampModel()).toList();
      final combined = [...offlineModels, ...history];

      if (!mounted) return;
      setState(() {
        _historyItems = combined;
      });
    } catch (e) {
      debugPrint('Auto refresh error in HistoryPage: $e');
      final offlineQueue = await OfflineSyncService().getQueue(
        userId: userId,
        projectId: proj.idProject,
      );
      final offlineModels =
          offlineQueue.map((e) => e.toHistoryLampModel()).toList();

      final sDate = startDate?.toIso8601String().split('T').first ?? '';
      final eDate = endDate?.toIso8601String().split('T').first ?? '';
      final cachedJson = await LocalCacheService.getHistoryJson(
        userId: userId,
        projectId: proj.idProject,
        start: sDate,
        end: eDate,
      );
      final cachedModels = (cachedJson ?? [])
          .map((item) =>
              HistoryLampModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final combined = [...offlineModels, ...cachedModels];
      if (mounted && combined.isNotEmpty) {
        setState(() {
          _historyItems = combined;
        });
      }
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

  Future<void> _loadHistory({bool forceRefresh = false}) async {
    final proj = _currentProject;
    if (proj == null) {
      setState(() {
        _historyItems = [];
        _isLoading = false;
      });
      return;
    }

    final (startDate, endDate) = _getDateRangeForFilter(_selectedFilter);
    final userId = AuthService.currentUser?.idUser ?? 0;

    debugPrint('HISTORY FILTER: $_selectedFilter');
    debugPrint('START DATE: $startDate');
    debugPrint('END DATE: $endDate');

    // 1. Muat data lokal sinkron segera agar tidak perlu loading sama sekali
    final cached = _loadCachedItemsSync(proj, _selectedFilter);
    if (cached.isNotEmpty) {
      if (mounted) {
        setState(() {
          _historyItems = cached;
          _isLoading = false;
        });
      }
    } else if (_historyItems.isEmpty) {
      setState(() => _isLoading = true);
    }

    // Jika bukan force refresh dan cache lokal sudah ada, cukup sinkronisasi di background
    if (!forceRefresh && cached.isNotEmpty) {
      _loadHistorySilently();
      return;
    }
    try {
      final history = await InstallationService().getHistory(
        userId: userId,
        projectId: proj.idProject,
        startDate: startDate,
        endDate: endDate,
        forceRefresh: forceRefresh,
      );

      final offlineQueue = await OfflineSyncService().getQueue(
        userId: userId,
        projectId: proj.idProject,
      );
      final offlineModels =
          offlineQueue.map((e) => e.toHistoryLampModel()).toList();
      final combined = [...offlineModels, ...history];

      if (mounted) {
        setState(() {
          _historyItems = combined;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
      final offlineQueue = await OfflineSyncService().getQueue(
        userId: userId,
        projectId: proj.idProject,
      );
      final offlineModels =
          offlineQueue.map((e) => e.toHistoryLampModel()).toList();

      final sDate = startDate?.toIso8601String().split('T').first ?? '';
      final eDate = endDate?.toIso8601String().split('T').first ?? '';
      final cachedJson = await LocalCacheService.getHistoryJson(
        userId: userId,
        projectId: proj.idProject,
        start: sDate,
        end: eDate,
      );
      final cachedModels = (cachedJson ?? [])
          .map((item) =>
              HistoryLampModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final combined = [...offlineModels, ...cachedModels];
      if (mounted) {
        setState(() {
          if (combined.isNotEmpty) {
            _historyItems = combined;
          }
          _isLoading = false;
        });
      }
    }
  }

  ProjectModel? get _currentProject {
    return ProjectService.selectedProject;
  }

  @override
  void dispose() {
    OfflineSyncService().pendingCountNotifier.removeListener(_onPendingCountChanged);
    MainNavigationService.currentTabNotifier.removeListener(_onTabChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
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

    final dt = DateTime.tryParse(str);
    if (dt != null) {
      final local = dt.isUtc ? dt.toLocal() : dt;
      return DateTime(local.year, local.month, local.day);
    }

    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(str);
    if (match != null) {
      final y = int.parse(match.group(1)!);
      final m = int.parse(match.group(2)!);
      final d = int.parse(match.group(3)!);
      return DateTime(y, m, d);
    }
    return null;
  }

  bool _matchesDateFilter(HistoryLampModel item, String filter) {
    // Item offline ("Menunggu Jaringan") selalu ditampilkan agar teknisi tidak mengira datanya hilang
    if (item.isMenungguJaringan) {
      return true;
    }

    final (startDate, endDate) = _getDateRangeForFilter(filter);
    if (startDate == null && endDate == null) return true;

    final itemDate =
        _extractDateOnly(item.createdAt) ??
        _extractDateOnly(item.installation?.createdAt) ??
        _extractDateOnly(item.installedAt) ??
        _extractDateOnly(item.tanggal);

    if (itemDate == null) return true;

    if (startDate != null && itemDate.isBefore(startDate)) {
      return false;
    }
    if (endDate != null && itemDate.isAfter(endDate)) {
      return false;
    }
    return true;
  }

  List<HistoryLampModel> get _filteredItems {
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
                item.installation!.districtName!.toLowerCase().contains(
                  query,
                )) ||
            item.lokasi.toLowerCase().contains(query) ||
            item.koordinat.toLowerCase().contains(query) ||
            item.status.toLowerCase().contains(query) ||
            item.jenis.toLowerCase().contains(query);
      }).toList();
    }

    // Sorting: Kartu berstatus "Ditolak" diletakkan di paling atas (prioritas teratas),
    // selanjutnya diurutkan berdasarkan created_at (Terbaru / Terlama sesuai toggle).
    items.sort((a, b) {
      if (a.isDitolak && !b.isDitolak) return -1;
      if (!a.isDitolak && b.isDitolak) return 1;

      final dateA = a.createdAt ?? a.installation?.createdAt;
      final dateB = b.createdAt ?? b.installation?.createdAt;

      if (dateA != null && dateB != null) {
        final cmp = _isSortDescending
            ? dateB.compareTo(dateA)
            : dateA.compareTo(dateB);
        if (cmp != 0) return cmp;
      } else if (dateA != null) {
        return _isSortDescending ? -1 : 1;
      } else if (dateB != null) {
        return _isSortDescending ? 1 : -1;
      }

      final idA = a.idHistory ?? 0;
      final idB = b.idHistory ?? 0;
      return _isSortDescending ? idB.compareTo(idA) : idA.compareTo(idB);
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

  void _handleCardTap(HistoryLampModel item) async {
    final effectiveCode = (item.idLcu != null && item.idLcu!.trim().isNotEmpty)
        ? item.idLcu!
        : (item.kode.trim().isNotEmpty ? item.kode : '-');

    final double currentOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    final result = await AppNavigator.push(
      context,
      DetailLampuPage(
        idInstallation: item.idHistory,
        idArea: item.areaId ?? item.installation?.idArea,
        idProject: item.projectId,
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
        createdAt:
            item.createdAt?.toIso8601String() ??
            item.installation?.createdAt?.toIso8601String(),
        updatedAt:
            item.updatedAt?.toIso8601String() ??
            item.installation?.updatedAt?.toIso8601String(),
        wattage: '120W',
        installation: item.installation,
        photos: item.installation?.photos,
        inputMethod: item.inputMethod,
        panelCode: item.panelCode,
        noteByAdmin: item.installation?.noteByAdmin ?? item.noteByAdmin,
      ),
    );

    if (result is Map && result['deleted'] == true) {
      final int? deletedId = result['id'];
      if (mounted) {
        setState(() {
          _historyItems.removeWhere(
            (h) =>
                (deletedId != null &&
                (h.idHistory == deletedId ||
                    h.installation?.idInstallation == deletedId)),
          );
        });
        CustomFeedbackMessage.showSuccess(context, 'Data berhasil dihapus');
        if (_scrollController.hasClients && currentOffset > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _scrollController.hasClients) {
              _scrollController.jumpTo(
                currentOffset.clamp(
                  0.0,
                  _scrollController.position.maxScrollExtent,
                ),
              );
            }
          });
        }
      }
      return;
    }

    if (mounted) {
      if (_scrollController.hasClients && currentOffset > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.hasClients) {
            _scrollController.jumpTo(
              currentOffset.clamp(
                0.0,
                _scrollController.position.maxScrollExtent,
              ),
            );
          }
        });
      }
      _loadHistorySilently();
    }
  }

  void _handleNavTap(int index) {
    if (MainNavigationService.hasMainLayout) {
      MainNavigationService.setIndex(index);
    } else {
      if (index == 0) {
        AppNavigator.pushTabReplacement(context, const AreaOperasionalPage());
      } else if (index == 2) {
        AppNavigator.pushTabReplacement(context, const ProfilePage());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.backgroundWhite,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () => _loadHistory(forceRefresh: true),
              color: AppColors.primary,
              child: CustomScrollView(
                controller: _scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                key: const PageStorageKey<String>('history_custom_scroll_view'),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverToBoxAdapter(
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
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
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
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isSortDescending = !_isSortDescending;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  splashColor: AppColors.primary.withValues(alpha: 0.1),
                                  highlightColor: AppColors.primary.withValues(alpha: 0.05),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                      horizontal: 4,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 250),
                                          transitionBuilder: (child, anim) =>
                                              FadeTransition(opacity: anim, child: child),
                                          child: Text(
                                            _isSortDescending ? 'Terbaru' : 'Terlama',
                                            key: ValueKey<bool>(_isSortDescending),
                                            style: TextStyle(
                                              color: _isSortDescending
                                                  ? AppColors.textMuted
                                                  : AppColors.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        AnimatedRotation(
                                          turns: _isSortDescending ? 0.0 : 0.5,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOutCubic,
                                          child: Icon(
                                            Icons.swap_vert_rounded,
                                            size: 15,
                                            color: _isSortDescending
                                                ? AppColors.textMuted
                                                : AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                color: AppColors.textSubtle,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),

                // List of History Cards
                if (_isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: Skeletonizer.sliver(
                      enabled: true,
                      child: SliverList.builder(
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return const HistoryLampCard(
                            item: HistoryLampModel(
                              userId: 0,
                              projectId: 0,
                              kode: 'LCU-12345678',
                              jenis: 'PJU Solar Cell 100W',
                              status: 'Menunggu Verifikasi',
                              isVerified: false,
                              lokasi: 'Jl. Jenderal Sudirman No. 123, Jakarta',
                              koordinat: '-6.2088, 106.8456',
                              fotoCount: '3 Foto Lampu',
                              waktu: '2026-09-29 10:00:00',
                              panelCode: 'PNL-01',
                              districtName: 'Kecamatan Gambir',
                            ),
                          );
                        },
                      ),
                    ),
                  )
                else if (_currentProject == null)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 20,
                        ),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.touch_app_outlined,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Pilih Proyek Terlebih Dahulu',
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
                      ),
                    ),
                  )
                else if (filtered.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 20,
                        ),
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
                                  : 'Tidak ada riwayat untuk filter "$_selectedFilter" pada proyek "${_currentProject?.projectName}".',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverList.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return HistoryLampCard(
                          item: item,
                          onTap: () => _handleCardTap(item),
                        );
                      },
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ),
      ),
        bottomNavigationBar: widget.isEmbedded
            ? null
            : BottomNavbar(
                currentIndex: 1,
                onTap: _handleNavTap,
              ),
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
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppColors.shadowStrong,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textBody,
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
