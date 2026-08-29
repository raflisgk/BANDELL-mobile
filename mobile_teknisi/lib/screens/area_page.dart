import 'package:flutter/material.dart';

import '../models/area_model.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class AreaPage extends StatefulWidget {
  final int idProject;

  const AreaPage({
    super.key,
    required this.idProject,
  });

  @override
  State<AreaPage> createState() => _AreaPageState();
}

class _AreaPageState extends State<AreaPage> {
  final ApiService apiService = ApiService();

  final TextEditingController searchController =
      TextEditingController();

  List<OperationalArea> areas = [];
  List<OperationalArea> filteredAreas = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    loadAreas();

    searchController.addListener(
      filterAreas,
    );
  }

  Future<void> loadAreas() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result =
          await apiService.getOperationalAreas(
        widget.idProject,
      );

      if (!mounted) return;

      setState(() {
        areas = result;
        filteredAreas = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Gagal mengambil data area.';
      });
    }
  }

  void filterAreas() {
    final keyword =
        searchController.text.trim().toLowerCase();

    setState(() {
      if (keyword.isEmpty) {
        filteredAreas = areas;
      } else {
        filteredAreas = areas.where((area) {
          return area.areaName
                  .toLowerCase()
                  .contains(keyword) ||
              area.location
                  .toLowerCase()
                  .contains(keyword);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.removeListener(
      filterAreas,
    );

    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [
            // =========================
            // HEADER
            // =========================
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                16,
                24,
                0,
              ),

              child: Align(
                alignment: Alignment.centerLeft,

                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.primary,
                    size: 27,
                  ),
                ),
              ),
            ),

            // =========================
            // CONTENT
            // =========================
            Expanded(
              child: RefreshIndicator(
                onRefresh: loadAreas,

                child: SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),

                  padding:
                      const EdgeInsets.fromLTRB(
                    30,
                    15,
                    30,
                    25,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // =========================
                      // TITLE
                      // =========================
                      const Text(
                        'Pilih Area Operasional',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'Berikut area operasional tersedia untuk Anda.',
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // =========================
                      // SEARCH
                      // =========================
                      _buildSearch(),

                      const SizedBox(height: 20),

                      // =========================
                      // AREA LIST
                      // =========================
                      _buildAreaContent(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return SizedBox(
      height: 40,

      child: TextField(
        controller: searchController,

        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textPrimary,
        ),

        decoration: InputDecoration(
          hintText: 'Cari area...',

          hintStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.textHint,
          ),

          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.icon,
            size: 21,
          ),

          filled: true,

          fillColor:
              const Color(0xFFF3F4FB),

          contentPadding: EdgeInsets.zero,

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(7),

            borderSide: const BorderSide(
              color: AppColors.border,
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(7),

            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAreaContent() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),

        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),

        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                color: AppColors.icon,
                size: 40,
              ),

              const SizedBox(height: 10),

              Text(
                errorMessage!,
                style: const TextStyle(
                  color:
                      AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: loadAreas,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary,
                ),

                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredAreas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),

        child: Center(
          child: Text(
            'Belum ada area operasional.',
            style: TextStyle(
              color:
                  AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,

      physics:
          const NeverScrollableScrollPhysics(),

      itemCount: filteredAreas.length,

      separatorBuilder:
          (_, __) => const SizedBox(
        height: 14,
      ),

      itemBuilder: (context, index) {
        return _buildAreaCard(
          filteredAreas[index],
        );
      },
    );
  }

  Widget _buildAreaCard(
    OperationalArea area,
  ) {
    return Material(
      color: AppColors.primary,

      borderRadius:
          BorderRadius.circular(9),

      child: InkWell(
        borderRadius:
            BorderRadius.circular(9),

        onTap: () {
          debugPrint(
            'Area dipilih: '
            '${area.idOperationalArea}',
          );

          // Nanti lanjut ke lamp_page.dart
        },

        child: Container(
          width: double.infinity,
          height: 102,

          padding:
              const EdgeInsets.fromLTRB(
            14,
            13,
            12,
            12,
          ),

          decoration: BoxDecoration(
            color: AppColors.primary,

            borderRadius:
                BorderRadius.circular(9),

            boxShadow: const [
              BoxShadow(
                offset: Offset(0, 3),
                blurRadius: 5,
                color: Color(0x22000000),
              ),
            ],
          ),

          child: Stack(
            children: [
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // NAMA AREA
                  Text(
                    area.areaName,

                    maxLines: 1,

                    overflow:
                        TextOverflow.ellipsis,

                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // LOKASI
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color:
                            AppColors.white,
                        size: 14,
                      ),

                      const SizedBox(width: 3),

                      Expanded(
                        child: Text(
                          area.location,

                          maxLines: 1,

                          overflow:
                              TextOverflow.ellipsis,

                          style:
                              const TextStyle(
                            color:
                                AppColors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // STATUS
                  Text(
                    area.status,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),

              // =========================
              // PANAH
              // =========================
              Positioned(
                right: 0,
                bottom: 0,

                child: Container(
                  width: 27,
                  height: 27,

                  decoration:
                      const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.chevron_right,
                    color:
                        AppColors.primary,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}