import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/lamp_type_card.dart';
import 'input_method_page.dart';

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
  final int? idArea;
  final String? areaName;

  const LampPage({
    super.key,
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

  final List<LampTypeItem> _dummyLampTypes = const [
    LampTypeItem(
      id: 1,
      name: 'LED Street Light 100W',
      description: 'Tipe Standar Jalan Utama',
      icon: Icons.wb_incandescent_outlined,
    ),
    LampTypeItem(
      id: 2,
      name: 'LED Street Light 80W',
      description: 'Tipe Jalan Perumahan',
      icon: Icons.wb_incandescent_outlined,
    ),
    LampTypeItem(
      id: 3,
      name: 'Decorative Park Light 60W',
      description: 'Tipe Taman & Estetika',
      icon: Icons.wb_sunny_outlined,
    ),
    LampTypeItem(
      id: 4,
      name: 'LED Street Light 60W',
      description: 'Tipe Jalan Lingkungan',
      icon: Icons.wb_incandescent_outlined,
    ),
    LampTypeItem(
      id: 5,
      name: 'LED Street Light 120W',
      description: 'Tipe Jalan Kolektor',
      icon: Icons.wb_incandescent_outlined,
    ),
    LampTypeItem(
      id: 6,
      name: 'LED Street Light 200W',
      description: 'Tipe High Mast / Area Luas',
      icon: Icons.wb_incandescent_outlined,
    ),
    LampTypeItem(
      id: 7,
      name: 'Solar LED Street Light',
      description: 'Tipe Tenaga Surya Mandiri',
      icon: Icons.wb_sunny_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<LampTypeItem> get _filteredLampTypes {
    if (_searchQuery.isEmpty) {
      return _dummyLampTypes;
    }
    return _dummyLampTypes.where((item) {
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
    debugPrint('Lamp type selected: ${item.name}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InputMethodPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredLampTypes;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // 1. Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: _handleBack,
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),

                    const SizedBox(height: 20),

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
                      'Pilih jenis lampu yang akan dipasang\natau dipantau di area ini.',
                      maxLines: 2,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 18),

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
                          hintText: 'Cari project...',
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
                    if (filteredList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: Text(
                            'Jenis lampu tidak ditemukan',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
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

            // 7. Fixed Bottom Navigation Bar
            BottomNavbar(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                setState(() {
                  _currentNavIndex = index;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
