import 'package:flutter/material.dart';
import '../../dummy/dummy_data.dart';
import '../../models/area_model.dart';
import '../../models/project_model.dart';
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

  const AreaOperasionalPage({super.key, this.idProject});

  @override
  State<AreaOperasionalPage> createState() => _AreaOperasionalPageState();
}

class _AreaOperasionalPageState extends State<AreaOperasionalPage> {
  Project? _selectedProject;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.idProject != null) {
      _selectedProject = DummyData.getProjectById(widget.idProject!);
      DummyData.selectedProject = _selectedProject;
    } else {
      _selectedProject = DummyData.selectedProject;
    }
  }

  void _onProjectSelected(String? projectName) {
    if (projectName == null) return;
    setState(() {
      _selectedProject = DummyData.getProjectByName(projectName);
      DummyData.selectedProject = _selectedProject;
    });
  }

  void _handleCardTap(AreaModel area) {
    debugPrint('Area selected: ${area.areaName} (ID: ${area.idArea})');
    AppNavigator.push(
      context,
      LampPage(
        idArea: area.idArea,
        areaName: area.areaName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<AreaModel> currentAreas = _selectedProject != null
        ? DummyData.getAreasByProjectId(_selectedProject!.idProject)
        : [];

    final bool isProjectClosed = _selectedProject?.status == 'closed' ||
        _selectedProject?.status == 'selesai';
    final String dateRangeStr = isProjectClosed
        ? '01 Jan 2025 - 31 Des 2025'
        : '10 Mei 2026 - 20 Des 2026';

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // TopBar dengan dropdown Pilih Project di tengah dan ikon Notifikasi di kanan
            AppTopBar(
              selectedValue: _selectedProject?.projectName,
              dropdownItems: DummyData.projectOptions,
              onDropdownChanged: _onProjectSelected,
              showBackButton: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Header Title
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

                    // Header Subtitle
                    const Text(
                      'Berikut area operasional tersedia untuk Anda.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // KONDISI 1: Belum Memilih Project
                    if (_selectedProject == null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 48, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.0,
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
                              'Gunakan menu dropdown di bagian atas layar untuk menentukan wilayah proyek aktif.',
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

                    // KONDISI 2: Project Dipilih tapi Tidak Memiliki Area (Empty State)
                    else if (currentAreas.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 44, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.0,
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
                              'Project "${_selectedProject!.projectName}" belum memiliki area operasional.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )

                    // KONDISI 3: Project Dipilih & Menampilkan CARD BIRU Area Operasional
                    else
                      ...currentAreas.map((area) => Padding(
                            padding: const EdgeInsets.only(bottom: 14.0),
                            child: AreaOperasionalCard(
                              title: area.areaName,
                              location: _selectedProject?.location ??
                                  'Semarang, Jawa Tengah',
                              dateRange: dateRangeStr,
                              onTap: () => _handleCardTap(area),
                            ),
                          )),

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
    );
  }
}

// Alias class for backwards compatibility
typedef AreaPage = AreaOperasionalPage;
