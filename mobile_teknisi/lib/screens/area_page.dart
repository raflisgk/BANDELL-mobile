import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'lamp_page.dart';

class AreaItem {
  final int id;
  final String name;
  final String location;

  const AreaItem({
    required this.id,
    required this.name,
    required this.location,
  });
}

class AreaPage extends StatefulWidget {
  final int? idProject;

  const AreaPage({super.key, this.idProject});

  @override
  State<AreaPage> createState() => _AreaPageState();
}

class _AreaPageState extends State<AreaPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';

  final List<AreaItem> _dummyAreas = const [
    AreaItem(
      id: 1,
      name: 'Jakarta Selatan',
      location: 'Jakarta, Indonesia',
    ),
    AreaItem(
      id: 2,
      name: 'Jakarta Pusat',
      location: 'Jakarta, Indonesia',
    ),
    AreaItem(
      id: 3,
      name: 'Jakarta Timur',
      location: 'Jakarta, Indonesia',
    ),
    AreaItem(
      id: 4,
      name: 'Kuningan District',
      location: 'Jakarta, Indonesia',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<AreaItem> get _filteredAreas {
    if (_searchQuery.isEmpty) {
      return _dummyAreas;
    }
    return _dummyAreas.where((area) {
      return area.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _handleAreaTap(AreaItem area) {
    debugPrint('Area selected: ${area.name} (ID: ${area.id})');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LampPage(
          idArea: area.id,
          areaName: area.name,
        ),
      ),
    );
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAreas;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header: Back Arrow Icon
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

              // Title & Subtitle Section
              const Text(
                'Pilih Area Operasional',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.searchBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
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
                      size: 22,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Area Cards List Section
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: AppColors.hintColor,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Area tidak ditemukan',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final area = filtered[index];
                          return _buildAreaCard(area);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAreaCard(AreaItem area) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleAreaTap(area),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Area Name
                Text(
                  area.name,
                  style: const TextStyle(
                    color: AppColors.cardTextWhite,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Location Row
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.cardTextSubtle,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      area.location,
                      style: const TextStyle(
                        color: AppColors.cardTextSubtle,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Bottom Left Arrow Circle Button
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.cardButtonWhite,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
