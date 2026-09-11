import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/lamp_type_service.dart';
import '../../services/project_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/bottom_navbar.dart';
import '../history/history_page.dart';
import '../metode_pendataan/metode_pendataan_page.dart';
import '../notification/notification_page.dart';
import '../profile/profile_page.dart';
import 'lamp_type_card.dart';

class LampTypeItem {
  final int id;
  final String name;
  final String description;
  final IconData icon;

  const LampTypeItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

class LampPage extends StatefulWidget {
  final int? idProject;
  final int? idArea;
  final String? areaName;

  const LampPage({
    super.key,
    this.idProject,
    this.idArea,
    this.areaName,
  });

  @override
  State<LampPage> createState() => _LampPageState();
}

class _LampPageState extends State<LampPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentNavIndex = 0;
  List<LampTypeItem> _lampTypes = [];
  bool _isLoading = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadLampTypes();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _loadLampTypesSilently(),
    );
  }

  Future<void> _loadLampTypesSilently() async {
    try {
      final types = await LampTypeService().getLampTypes();
      if (!mounted) return;
      final newItems = types
          .map((item) => LampTypeItem(
                id: item.id,
                name: item.name,
                description: item.description,
                icon: Icons.lightbulb_outline_rounded,
              ))
          .toList();
      setState(() {
        _lampTypes = newItems;
      });
    } catch (e) {
      debugPrint('Auto refresh error in LampPage: $e');
    }
  }

  Future<void> _loadLampTypes() async {
    setState(() => _isLoading = true);
    final types = await LampTypeService().getLampTypes();
    if (mounted) {
      setState(() {
        _lampTypes = types
            .map((item) => LampTypeItem(
                  id: item.id,
                  name: item.name,
                  description: item.description,
                  icon: Icons.lightbulb_outline_rounded,
                ))
            .toList();
        _isLoading = false;
      });
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

  List<LampTypeItem> get _filteredLampTypes {
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

  void _handleLampTypeTap(LampTypeItem item) {
    final bool isProjectClosed =
        ProjectService.selectedProject?.status == 'closed' ||
            ProjectService.selectedProject?.status == 'selesai';
    if (isProjectClosed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Project "${ProjectService.selectedProject?.projectName}" telah Selesai. Penambahan data lampu baru tidak tersedia.',
          ),
          backgroundColor: const Color(0xFF64748B),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    debugPrint('Lamp type selected: ${item.name}');
    _handleNavigateToInputMethod(item);
  }

  void _handleNavigateToInputMethod(LampTypeItem item) async {
    await AppNavigator.push(
      context,
      MetodePendataanPage(
        idProject: widget.idProject ??
            ProjectService.selectedProject?.idProject,
        idArea: widget.idArea,
        areaName: widget.areaName,
        lampType: item.name,
        lampTypeId: item.id,
      ),
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

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              showDropdown: true,
              selectedValue: ProjectService.selectedProject?.projectName,
              dropdownItems: ProjectService.projectOptions,
              onDropdownChanged: (val) {
                setState(() {
                  ProjectService.selectedProject =
                      val != null ? ProjectService.getProjectByName(val) : null;
                });
              },
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
                physics: const BouncingScrollPhysics(),
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
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.lock_outline_rounded,
                                color: Color(0xFF64748B), size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Project Selesai (Read-Only): Penambahan data baru tidak tersedia.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 2. Title
              const Text(
                'Pilih Jenis Lampu',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),

              // 3. Subtitle
              const Text(
                'Pilih jenis lampu yang akan dipasang.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 20),

              // 4. Search Field
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
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Cari Jenis Lampu',
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

              const SizedBox(height: 18),

              // 5. List of Lamp Types
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                )
              else if (filteredList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
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
                ...filteredList.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: LampTypeCard(
                        name: item.name,
                        description: item.description,
                        icon: item.icon,
                        onTap: () => _handleLampTypeTap(item),
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
