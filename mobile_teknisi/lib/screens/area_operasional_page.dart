import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/page_transitions.dart';
import '../widgets/area_operasional_card.dart';
import '../widgets/bottom_navbar.dart';
import 'history_page.dart';
import 'lamp_page.dart';
import 'profile_page.dart';

class AreaOperasionalPage extends StatefulWidget {
  final int? idProject;

  const AreaOperasionalPage({super.key, this.idProject});

  @override
  State<AreaOperasionalPage> createState() => _AreaOperasionalPageState();
}

class _AreaOperasionalPageState extends State<AreaOperasionalPage> {
  String? _selectedProject;
  int _currentNavIndex = 0;
  final GlobalKey _dropdownKey = GlobalKey();

  final List<String> _projectOptions = const [];

  final List<Map<String, dynamic>> _areas = const [];

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

  void _showProjectMenu() async {
    final RenderBox? buttonBox =
        _dropdownKey.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) return;

    final Offset position = buttonBox.localToGlobal(Offset.zero);
    final Size size = buttonBox.size;
    final RenderBox overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height + 6,
        overlayBox.size.width - (position.dx + size.width),
        0,
      ),
      constraints: BoxConstraints.tightFor(width: size.width),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      elevation: 4,
      items: _projectOptions.map((String project) {
        final bool isSelected = project == _selectedProject;
        return PopupMenuItem<String>(
          value: project,
          height: 48,
          child: SizedBox(
            width: size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  project,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );

    if (selected != null) {
      setState(() {
        _selectedProject = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

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

              // Dropdown Wilayah Proyek
              _buildProjectDropdown(),

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

  Widget _buildProjectDropdown() {
    return GestureDetector(
      key: _dropdownKey,
      onTap: _showProjectMenu,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.border,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedProject ?? 'Pilih Wilayah Proyek',
                style: TextStyle(
                  color: _selectedProject == null
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

// Alias class for backwards compatibility
typedef AreaPage = AreaOperasionalPage;
