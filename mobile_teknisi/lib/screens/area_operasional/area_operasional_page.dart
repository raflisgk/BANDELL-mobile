import 'package:flutter/material.dart';
import '../../dummy/dummy_data.dart';
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
  String? _selectedProject;
  int _currentNavIndex = 0;

  final List<String> _projectOptions = const [];

  List<Map<String, dynamic>> get _areas => DummyDataConfig.useDummyData
      ? DummyData.operationalAreasMap
      : const [];

  void _handleCardTap(Map<String, dynamic> area) {
    debugPrint('Area selected: ${area['title']} (ID: ${area['id']})');
    AppNavigator.push(
      context,
      LampPage(
        idArea: area['id'] as int,
        areaName: area['title'] as String,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              selectedValue: _selectedProject,
              dropdownItems: _projectOptions,
              onDropdownChanged: (val) {
                setState(() {
                  _selectedProject = val;
                });
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

                    // Cards List
                    if (_areas.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.map_outlined,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Belum Ada Area Operasional',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Data area operasional akan muncul setelah terhubung ke API.',
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
                ..._areas.map((area) => Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: AreaOperasionalCard(
                        title: area['title'] as String,
                        location: area['location'] as String,
                        dateRange: area['dateRange'] as String,
                        onTap: () => _handleCardTap(area),
                      ),
                    )),

              const SizedBox(height: 12),
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
