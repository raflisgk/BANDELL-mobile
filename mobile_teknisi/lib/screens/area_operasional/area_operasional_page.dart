import 'package:flutter/material.dart';

import '../../models/project_model.dart';
import '../../services/project_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/bottom_navbar.dart';
import '../history/history_page.dart';
import '../lamp/lamp_page.dart';
import '../profile/profile_page.dart';
import 'area_operasional_card.dart';

class AreaOperasionalPage extends StatefulWidget {
  final int? idProject;

  const AreaOperasionalPage({
    super.key,
    this.idProject,
  });

  @override
  State<AreaOperasionalPage> createState() => _AreaOperasionalPageState();
}

class _AreaOperasionalPageState extends State<AreaOperasionalPage> {
  final ProjectService _projectService = ProjectService();

  List<ProjectModel> _projects = [];
  ProjectModel? _selectedProject;

  List<Map<String, dynamic>> _areas = [];

  bool _isLoadingProjects = true;
  bool _isLoadingAreas = false;

  String? _errorMessage;

  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoadingProjects = true;
      _errorMessage = null;
    });

    try {
      final projects = await _projectService.getProjects();

      // Project aktif di atas, project selesai di bawah.
      projects.sort((a, b) {
        if (a.isActive && b.isCompleted) {
          return -1;
        }

        if (a.isCompleted && b.isActive) {
          return 1;
        }

        return a.id.compareTo(b.id);
      });

      if (!mounted) return;

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
          _selectProject(matchingProject.first);
        }
      } else if (ProjectService.selectedProject != null) {
        final matchingProject = projects.where(
          (project) => project.id == ProjectService.selectedProject!.id,
        );
        if (matchingProject.isNotEmpty) {
          _selectProject(matchingProject.first);
        } else if (projects.isNotEmpty) {
          _selectProject(projects.first);
        }
      } else if (projects.isNotEmpty) {
        _selectProject(projects.first);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingProjects = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _selectProject(ProjectModel project) async {
    ProjectService.selectedProject = project;
    setState(() {
      _selectedProject = project;
      _areas = [];
      _isLoadingAreas = true;
    });

    try {
      final areas = await _projectService.getAreas(project.id);

      if (!mounted) return;

      setState(() {
        _areas = areas.map<Map<String, dynamic>>((area) {
          return {
            'id': area['id'],
            'name': area['name']?.toString() ?? '',
          };
        }).toList();

        _isLoadingAreas = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _areas = [];
        _isLoadingAreas = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengambil area: $e',
          ),
        ),
      );
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

  void _handleCardTap(Map<String, dynamic> area) {
    final int areaId = int.tryParse(
          area['id'].toString(),
        ) ??
        0;

    final String areaName = area['name']?.toString() ?? '';

    debugPrint(
      'Area selected: $areaName (ID: $areaId)',
    );

    AppNavigator.push(
      context,
      LampPage(
        idProject: _selectedProject?.id ?? 0,
        idArea: areaId,
        areaName: areaName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectNames = _projects
        .map((project) => project.name)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              selectedValue: _selectedProject?.name,
              dropdownItems: projectNames,
              onDropdownChanged: _onProjectSelected,
              showBackButton: false,
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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

                    const SizedBox(height: 20),

                    // Loading project
                    if (_isLoadingProjects)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 40,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )

                    // Error project
                    else if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.border,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Gagal Mengambil Data Project',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadProjects,
                              child: const Text('Coba Lagi'),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.border,
                          ),
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
                                color: Color(0xFFEFF6FF),
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

                    // Loading area
                    else if (_isLoadingAreas)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 40,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )

                    // Tidak ada area
                    else if (_areas.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 44,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.border,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.map_outlined,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Belum Ada Area Operasional',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Project "${_selectedProject!.name}" belum memiliki area operasional.',
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
                      ..._areas.map(
                        (area) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: 14.0,
                          ),
                          child: AreaOperasionalCard(
                            title: area['name']?.toString() ?? '',
                            location: _selectedProject?.name ?? '-',
                            dateRange: '-',
                            onTap: () => _handleCardTap(area),
                          ),
                        ),
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
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 1) {
            AppNavigator.pushTabReplacement(
              context,
              const HistoryPage(),
            );
          } else if (index == 2) {
            AppNavigator.pushTabReplacement(
              context,
              const ProfilePage(),
            );
          } else {
            setState(() {
              _currentNavIndex = index;
            });
          }
        },
      ),
    );
  }
}

// Alias class untuk kompatibilitas
typedef AreaPage = AreaOperasionalPage;