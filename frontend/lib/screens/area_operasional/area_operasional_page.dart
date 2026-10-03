import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/area_model.dart';
import '../../models/project_model.dart';
import '../../services/local_cache_service.dart';
import '../../services/project_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/bottom_navbar.dart';
import '../history/history_page.dart';
import '../lamp/lamp_page.dart';
import '../notification/notification_page.dart';
import '../profile/profile_page.dart';
import 'area_operasional_card.dart';

import 'package:skeletonizer/skeletonizer.dart';

class AreaOperasionalPage extends StatefulWidget {
  final int? idProject;

  const AreaOperasionalPage({super.key, this.idProject});

  @override
  State<AreaOperasionalPage> createState() => _AreaOperasionalPageState();
}

class _AreaOperasionalPageState extends State<AreaOperasionalPage> {
  final ProjectService _projectService = ProjectService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<ProjectModel> _projects = [];
  ProjectModel? _selectedProject;

  List<AreaModel> _areas = [];

  bool _isLoadingProjects = true;
  bool _isLoadingAreas = false;

  String? _errorMessage;

  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _initFromCacheOrFetch();
  }

  void _initFromCacheOrFetch() async {
    try {
      final projects = await _projectService.getProjects();
      if (!mounted) return;

      if (projects.isNotEmpty) {
        final sortedProjects = List<ProjectModel>.from(projects)
          ..sort((a, b) => a.id.compareTo(b.id));

        ProjectModel? selected;
        if (widget.idProject != null) {
          final matches = sortedProjects.where((p) => p.id == widget.idProject);
          if (matches.isNotEmpty) selected = matches.first;
        }
        if (selected == null) {
          final savedId = await LocalCacheService.getSelectedProjectId();
          if (savedId != null) {
            final matches = sortedProjects.where((p) => p.id == savedId);
            if (matches.isNotEmpty) selected = matches.first;
          }
        }
        selected ??=
            ProjectService.selectedProject ??
            (sortedProjects.isNotEmpty ? sortedProjects.first : null);

        if (selected != null) {
          ProjectService.selectedProject = selected;
          await LocalCacheService.saveSelectedProjectId(selected.id);
        }

        List<AreaModel> initialAreas = [];
        if (selected != null) {
          final localAreas =
              await LocalCacheService.getProjectAreasJson(selected.id);
          if (localAreas != null && localAreas.isNotEmpty) {
            initialAreas = localAreas
                .whereType<Map<String, dynamic>>()
                .map((area) => AreaModel.fromJson(area))
                .toList();
          }
        }

        if (!mounted) return;

        setState(() {
          _projects = sortedProjects;
          _selectedProject = selected;
          _areas = initialAreas;
          _isLoadingProjects = false;
          _isLoadingAreas = initialAreas.isEmpty && selected != null;
          _errorMessage = null;
        });

        // Silently revalidate projects & areas in background
        _refreshSilently();
        return;
      }
    } catch (_) {}

    _loadProjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshSilently() async {
    try {
      final projects = await _projectService.getProjects(null, true);
      projects.sort((a, b) => a.id.compareTo(b.id));

      if (!mounted) return;

      if (projects.isEmpty) {
        ProjectService.selectedProject = null;
        setState(() {
          _projects = [];
          _selectedProject = null;
          _areas = [];
        });
        return;
      }

      ProjectModel? currentSelected = _selectedProject;
      if (currentSelected != null) {
        final matches = projects.where((p) => p.id == currentSelected!.id);
        if (matches.isNotEmpty) {
          currentSelected = matches.first;
          ProjectService.selectedProject = currentSelected;
          LocalCacheService.saveSelectedProjectId(currentSelected.id);
        } else {
          currentSelected = projects.first;
          ProjectService.selectedProject = currentSelected;
          LocalCacheService.saveSelectedProjectId(currentSelected.id);
        }
      } else {
        currentSelected = projects.first;
        ProjectService.selectedProject = currentSelected;
        LocalCacheService.saveSelectedProjectId(currentSelected.id);
      }

      final areas = await _projectService.getAreas(
        currentSelected.id,
        forceRefresh: true,
      );
      final updatedAreas = areas
          .whereType<Map<String, dynamic>>()
          .map((area) => AreaModel.fromJson(area))
          .toList();

      if (!mounted) return;

      setState(() {
        _projects = projects;
        _selectedProject = currentSelected;
        _areas = updatedAreas;
        _isLoadingProjects = false;
        _isLoadingAreas = false;
      });
    } catch (e) {
      debugPrint('Auto refresh error in AreaOperasionalPage: $e');
    }
  }

  Future<void> _loadProjects({bool forceRefresh = false}) async {
    if (!forceRefresh && ProjectService.hasCachedProjects) {
      _initFromCacheOrFetch();
      return;
    }

    setState(() {
      _isLoadingProjects = true;
      _errorMessage = null;
    });

    try {
      final projects = await _projectService.getProjects(null, forceRefresh);

      projects.sort((a, b) => a.id.compareTo(b.id));

      if (!mounted) return;

      if (projects.isEmpty) {
        ProjectService.selectedProject = null;
        setState(() {
          _projects = [];
          _selectedProject = null;
          _areas = [];
          _isLoadingProjects = false;
        });
        return;
      }

      setState(() {
        _projects = projects;
        _isLoadingProjects = false;
      });

      // Jika halaman dibuka dengan idProject tertentu
      if (widget.idProject != null) {
        final matchingProject = projects.where(
          (project) => project.id == widget.idProject,
        );

        if (matchingProject.isNotEmpty) {
          _selectProject(matchingProject.first, forceRefresh: forceRefresh);
        } else {
          _selectProject(projects.first, forceRefresh: forceRefresh);
        }
      } else if (ProjectService.selectedProject != null) {
        final matchingProject = projects.where(
          (project) => project.id == ProjectService.selectedProject!.id,
        );
        if (matchingProject.isNotEmpty) {
          _selectProject(matchingProject.first, forceRefresh: forceRefresh);
        } else if (projects.isNotEmpty) {
          _selectProject(projects.first, forceRefresh: forceRefresh);
        }
      } else if (projects.isNotEmpty) {
        _selectProject(projects.first, forceRefresh: forceRefresh);
      }
    } catch (e) {
      debugPrint('Error loadProjects in AreaOperasionalPage: $e');
      if (!mounted) return;

      setState(() {
        _isLoadingProjects = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _selectProject(
    ProjectModel project, {
    bool forceRefresh = false,
  }) async {
    ProjectService.selectedProject = project;
    await LocalCacheService.saveSelectedProjectId(project.id);

    if (!forceRefresh) {
      final localAreas =
          await LocalCacheService.getProjectAreasJson(project.id);
      if (localAreas != null) {
        final cached = localAreas
            .whereType<Map<String, dynamic>>()
            .map((area) => AreaModel.fromJson(area))
            .toList();
        setState(() {
          _selectedProject = project;
          _areas = cached;
          _isLoadingAreas = false;
          _errorMessage = null;
        });

        // Silently revalidate
        try {
          final freshAreas = await _projectService.getAreas(
            project.id,
            forceRefresh: true,
          );
          if (!mounted) return;
          setState(() {
            _areas = freshAreas
                .whereType<Map<String, dynamic>>()
                .map((area) => AreaModel.fromJson(area))
                .toList();
          });
        } catch (_) {}
        return;
      }
    }

    setState(() {
      _selectedProject = project;
      _areas = [];
      _isLoadingAreas = true;
      _errorMessage = null;
    });

    try {
      final areas = await _projectService.getAreas(
        project.id,
        forceRefresh: forceRefresh,
      );

      if (!mounted) return;

      setState(() {
        _areas = areas
            .whereType<Map<String, dynamic>>()
            .map((area) => AreaModel.fromJson(area))
            .toList();

        _isLoadingAreas = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      final fallbackAreas =
          await LocalCacheService.getProjectAreasJson(project.id);
      final fallbackList = (fallbackAreas ?? [])
          .whereType<Map<String, dynamic>>()
          .map((area) => AreaModel.fromJson(area))
          .toList();

      setState(() {
        _areas = fallbackList;
        _isLoadingAreas = false;
        _errorMessage = null;
      });
    }
  }

  void _onProjectSelected(String? projectName) {
    if (projectName == null) return;

    final matchingProjects = _projects.where(
      (project) => project.name == projectName,
    );

    if (matchingProjects.isEmpty) return;

    _selectProject(matchingProjects.first);
  }

  Future<void> _refreshData({bool forceRefresh = false}) async {
    if (!forceRefresh && ProjectService.hasCachedProjects) {
      _initFromCacheOrFetch();
      return;
    }
    await _loadProjects(forceRefresh: forceRefresh);
  }

  void _handleCardTap(AreaModel area) async {
    final int areaId = area.idArea;
    final String areaName = area.areaName;

    debugPrint('Area selected: $areaName (ID: $areaId)');

    await AppNavigator.push(
      context,
      LampPage(
        idProject: _selectedProject?.id ?? 0,
        idArea: areaId,
        areaName: areaName,
      ),
      settings: const RouteSettings(name: LampPage.routeName),
    );

    if (mounted) {
      _refreshData();
    }
  }

  List<AreaModel> get _filteredAreas {
    if (_searchQuery.trim().isEmpty) {
      return _areas;
    }
    final query = _searchQuery.toLowerCase().trim();
    return _areas.where((area) {
      return area.areaName.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildSearchBar({bool isSkeleton = false}) {
    if (isSkeleton) {
      return Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderMedium, width: 1),
        ),
        child: Row(
          children: const [
            Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22),
            SizedBox(width: 10),
            Text(
              'Cari area operasional',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderMedium, width: 1),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Cari area operasional',
          hintStyle: const TextStyle(
            color: AppColors.textSubtle,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textMuted,
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectNames = _projects.map((project) => project.name).toList();

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
              selectedValue: _selectedProject?.name,
              title: (!_isLoadingProjects && _projects.isEmpty)
                  ? 'Belum Ada Proyek'
                  : null,
              isLoading: _isLoadingProjects,
              dropdownItems: projectNames,
              onDropdownChanged: _onProjectSelected,
              showBackButton: false,
              onNotificationPressed: () async {
                await AppNavigator.push(context, const NotificationPage());
                if (mounted) {
                  _refreshData();
                }
              },
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _refreshData(forceRefresh: true),
                color: AppColors.primary,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  children: [
                    const SizedBox(height: 16),

                    const Text(
                      'Pilih Area Operasional',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Berikut area operasional tersedia untuk Anda.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Loading project skeleton
                    if (_isLoadingProjects)
                      Skeletonizer(
                        enabled: true,
                        ignoreContainers: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSearchBar(isSkeleton: true),
                            const SizedBox(height: 20),
                            for (
                              int i = 0;
                              i < (_areas.isNotEmpty ? _areas.length : 1);
                              i++
                            )
                              const Padding(
                                padding: EdgeInsets.only(bottom: 16.0),
                                child: AreaOperasionalCard(
                                  title: 'Nama Area Operasional Kecamatan',
                                ),
                              ),
                          ],
                        ),
                      )
                    // Error project (Koneksi Bermasalah)
                    else if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 36,
                          horizontal: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/connection_error.png',
                              height: 160,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  decoration: const BoxDecoration(
                                    color: AppColors.infoBackground,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.wifi_off_rounded,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Koneksi Bermasalah',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tidak dapat terhubung ke server. Periksa koneksi internet Anda dan coba lagi.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => _loadProjects(forceRefresh: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.pureWhite,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 36,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Coba Lagi',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    // Empty State: Assignment project kosong
                    else if (_projects.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 36,
                          horizontal: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/empty_project.png',
                              height: 180,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  decoration: const BoxDecoration(
                                    color: AppColors.infoBackground,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.engineering_outlined,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Belum ada proyek',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Saat ini belum ada proyek yang ditugaskan kepada Anda.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      )
                    // Belum memilih project
                    else if (_selectedProject == null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 48,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadowColor,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                color: AppColors.infoBackground,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_upward_rounded,
                                size: 30,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Silakan Pilih Project Terlebih Dahulu',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Gunakan menu dropdown di bagian atas layar untuk menentukan project.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      )
                    // Konten Area ketika project terpilih
                    else ...[
                      _buildSearchBar(),
                      const SizedBox(height: 20),

                      // Loading area skeleton
                      if (_isLoadingAreas)
                        Skeletonizer(
                          enabled: true,
                          ignoreContainers: true,
                          child: Column(
                            children: List.generate(
                              _areas.isNotEmpty ? _areas.length : 1,
                              (index) => const Padding(
                                padding: EdgeInsets.only(bottom: 16.0),
                                child: AreaOperasionalCard(
                                  title: 'Nama Area Operasional Kecamatan',
                                ),
                              ),
                            ),
                          ),
                        )
                      // Tidak ada area
                      else if (_areas.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 36,
                            horizontal: 20,
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/empty_project.png',
                                height: 160,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 70,
                                    height: 70,
                                    decoration: const BoxDecoration(
                                      color: AppColors.infoBackground,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.map_outlined,
                                      size: 36,
                                      color: AppColors.primary,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Belum Ada Area Operasional',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Project "${_selectedProject!.name}" belum memiliki area operasional.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        )
                      // Hasil search kosong
                      else if (_filteredAreas.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 36,
                            horizontal: 20,
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
                                'Area Tidak Ditemukan',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tidak ada area yang cocok dengan "$_searchQuery".',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      // Area dari database
                      else
                        for (final area in _filteredAreas)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: AreaOperasionalCard(
                              title: area.areaName,
                              onTap: () => _handleCardTap(area),
                            ),
                          ),
                    ],

                    const SizedBox(height: 24),
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

// Alias class untuk kompatibilitas
typedef AreaPage = AreaOperasionalPage;
