import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/lamp_type_model.dart';
import '../../services/lamp_type_service.dart';
import '../../services/local_cache_service.dart';
import '../../services/project_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/bottom_navbar.dart';
import '../../widgets/custom_feedback.dart';
import '../history/history_page.dart';
import '../metode_pendataan/metode_pendataan_page.dart';
import '../notification/notification_page.dart';
import '../profile/profile_page.dart';
import 'lamp_type_card.dart';

import 'package:skeletonizer/skeletonizer.dart';

class LampPage extends StatefulWidget {
  static const String routeName = '/lamp_page';

  final int? idProject;
  final int? idArea;
  final String? areaName;

  const LampPage({super.key, this.idProject, this.idArea, this.areaName});

  @override
  State<LampPage> createState() => _LampPageState();
}

class _LampPageState extends State<LampPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentNavIndex = 0;
  List<LampTypeModel> _lampTypes = [];
  bool _isLoading = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _initFromCacheOrFetch();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _loadLampTypesSilently(),
    );
  }

  void _initFromCacheOrFetch() async {
    // 1. Baca dari Storage HP secara instan
    final localJson = await LocalCacheService.getLampTypesJson();
    if (localJson != null && localJson.isNotEmpty && mounted) {
      final types = localJson
          .map((item) => LampTypeModel.fromJson(item as Map<String, dynamic>))
          .toList();
      setState(() {
        _lampTypes = types;
        _isLoading = false;
      });
      _loadLampTypesSilently();
      return;
    }

    _loadLampTypes();
  }

  Future<void> _loadLampTypesSilently() async {
    try {
      final types = await LampTypeService().getLampTypes(forceRefresh: true);
      if (!mounted) return;
      setState(() {
        _lampTypes = types;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Auto refresh error in LampPage: $e');
    }
  }

  Future<void> _loadLampTypes({bool forceRefresh = false}) async {
    if (_lampTypes.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final types = await LampTypeService().getLampTypes(
        forceRefresh: forceRefresh,
      );
      if (mounted) {
        setState(() {
          _lampTypes = types;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading lamp types: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<LampTypeModel> get _filteredLampTypes {
    if (_searchQuery.isEmpty) {
      return _lampTypes;
    }
    return _lampTypes.where((item) {
      return item.name.toLowerCase().contains(_searchQuery) ||
          item.description.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _handleLampTypeTap(LampTypeModel item) {
    final bool isProjectClosed =
        ProjectService.selectedProject?.status == 'closed' ||
        ProjectService.selectedProject?.status == 'selesai';
    if (isProjectClosed) {
      CustomFeedback.showError(
        context,
        'Project "${ProjectService.selectedProject?.projectName}" telah Selesai. Penambahan data lampu baru tidak tersedia.',
      );
      return;
    }
    debugPrint('Lamp type selected: ${item.name}');
    _handleNavigateToInputMethod(item);
  }

  void _handleNavigateToInputMethod(LampTypeModel item) async {
    await AppNavigator.push(
      context,
      MetodePendataanPage(
        idProject:
            widget.idProject ?? ProjectService.selectedProject?.idProject,
        idArea: widget.idArea,
        areaName: widget.areaName,
        lampType: item.name,
        lampTypeId: item.id,
      ),
      settings: const RouteSettings(name: MetodePendataanPage.routeName),
    );
    if (mounted) {
      _loadLampTypes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredLampTypes;
    final bool isProjectClosed =
        ProjectService.selectedProject?.status == 'closed' ||
        ProjectService.selectedProject?.status == 'selesai';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.backgroundWhite,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppTopBar(
                title: 'Pilih Jenis Lampu',
                showDropdown: false,
                onBackPressed: _handleBack,
                onNotificationPressed: () async {
                  await AppNavigator.push(context, const NotificationPage());
                  if (mounted) {
                    _loadLampTypes();
                  }
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      if (isProjectClosed)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderMedium),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Project Selesai (Read-Only): Penambahan data baru tidak tersedia.',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textBody,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // 1. Area Context Badge (jika tersedia)
                      if (widget.areaName != null &&
                          widget.areaName!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.infoBackground,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 15,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Area: ${widget.areaName}',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // 4 & 5. Search Field & Lamp Types
                      if (_isLoading)
                        Skeletonizer(
                          enabled: true,
                          ignoreContainers: true,
                          child: Column(
                            children: [
                              Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.search_rounded,
                                      color: AppColors.hintColor,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Cari Jenis Lampu',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              ...List.generate(
                                5,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14.0),
                                  child: LampTypeCard(
                                    name: 'PJU Solar Cell All in One',
                                    description: 'Lampu Penerangan Jalan Umum',
                                    icon: Icons.lightbulb_outline_rounded,
                                    onTap: () {},
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
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
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Cari Jenis Lampu',
                              hintStyle: const TextStyle(
                                color: AppColors.hintColor,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.hintColor,
                                size: 20,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                      },
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: AppColors.textSecondary,
                                        size: 18,
                                      ),
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (_searchQuery.isNotEmpty && filteredList.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 36.0,
                              horizontal: 20.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.search_off_rounded,
                                  size: 44,
                                  color: AppColors.textSubtle,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Jenis Lampu Tidak Ditemukan',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tidak ada jenis lampu yang cocok dengan "$_searchQuery".',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextButton(
                                  onPressed: () => _searchController.clear(),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                  ),
                                  child: const Text(
                                    'Reset Pencarian',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (filteredList.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 40.0,
                              horizontal: 20.0,
                            ),
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.lightbulb_outline_rounded,
                                  size: 48,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Belum Ada Jenis Lampu',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Data jenis lampu akan muncul setelah terhubung ke API.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...filteredList.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: LampTypeCard(
                                name: item.name,
                                description: item.description,
                                icon: Icons.lightbulb_outline_rounded,
                                onTap: () => _handleLampTypeTap(item),
                              ),
                            ),
                          ),
                      ],

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavbar(
          currentIndex: _currentNavIndex,
          onTap: (index) {
            if (index == 1) {
              AppNavigator.pushTabReplacement(context, const HistoryPage());
            } else if (index == 2) {
              AppNavigator.pushTabReplacement(context, const ProfilePage());
            } else {
              setState(() {
                _currentNavIndex = index;
              });
            }
          },
        ),
      ),
    );
  }
}
