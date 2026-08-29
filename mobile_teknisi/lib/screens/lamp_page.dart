import 'package:flutter/material.dart';

import '../models/installation_model.dart';
import '../utils/app_colors.dart';

class LampPage extends StatefulWidget {
  final int idOperationalArea;

  const LampPage({
    super.key,
    required this.idOperationalArea,
  });

  @override
  State<LampPage> createState() => _LampPageState();
}

class _LampPageState extends State<LampPage> {
  final TextEditingController searchController =
      TextEditingController();

  int selectedFilter = 0;

  final List<Installation> installations = [
    Installation(
      idInstallations: 1,
      idProject: 1,
      idUser: 1,
      controllerCode: 'JKT-001',
      inputMethod: 'Manual',
      idLampType: 1,
      latitude: -6.2088,
      longitude: 106.8456,
      address: 'Jl. Sudirman No. 10, Jakarta',
    ),
    Installation(
      idInstallations: 2,
      idProject: 1,
      idUser: 1,
      controllerCode: 'JKT-002',
      inputMethod: 'Manual',
      idLampType: 2,
      latitude: -6.2146,
      longitude: 106.8451,
      address: 'Jl. Gatot Subroto, Jakarta',
    ),
    Installation(
      idInstallations: 3,
      idProject: 1,
      idUser: 1,
      controllerCode: 'JKT-003',
      inputMethod: 'Manual',
      idLampType: 1,
      latitude: -6.2012,
      longitude: 106.8270,
      address: 'Jl. Thamrin, Jakarta',
    ),
  ];

  List<Installation> get filteredInstallations {
    final keyword =
        searchController.text.trim().toLowerCase();

    List<Installation> result =
        installations.where((installation) {
      final matchesSearch =
          installation.controllerCode
                  .toLowerCase()
                  .contains(keyword) ||
              installation.address
                  .toLowerCase()
                  .contains(keyword);

      if (!matchesSearch) {
        return false;
      }

      if (selectedFilter == 1) {
        return installation.idInstallations != 3;
      }

      if (selectedFilter == 2) {
        return installation.idInstallations == 3;
      }

      return true;
    }).toList();

    return result;
  }

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
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
            // =====================================
            // HEADER
            // =====================================
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                18,
                20,
                0,
              ),

              child: Align(
                alignment: Alignment.centerLeft,

                child: IconButton(
                  padding: EdgeInsets.zero,

                  onPressed: () {
                    Navigator.pop(context);
                  },

                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ),
            ),

            // =====================================
            // CONTENT
            // =====================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  25,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // =================================
                    // JUMLAH LAMPU
                    // =================================
                    Center(
                      child: Text(
                        '${installations.length} Lampu Tercatat',
                        style: const TextStyle(
                          color:
                              AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 17),

                    // =================================
                    // SEARCH
                    // =================================
                    _buildSearch(),

                    const SizedBox(height: 10),

                    // =================================
                    // FILTER
                    // =================================
                    _buildFilters(),

                    const SizedBox(height: 17),

                    // =================================
                    // TERBARU
                    // =================================
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [
                        const Text(
                          'Terbaru ↕',
                          style: TextStyle(
                            fontSize: 9,
                            color:
                                AppColors
                                    .textSecondary,
                          ),
                        ),

                        Text(
                          '${filteredInstallations.length} Record',
                          style: const TextStyle(
                            fontSize: 9,
                            color:
                                AppColors
                                    .textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Daftar Lampu',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // =================================
                    // LIST LAMPU
                    // =================================
                    ...filteredInstallations.map(
                      (installation) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 10,
                          ),

                          child:
                              _buildLampCard(
                            installation,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // =================================
                    // TAMBAH DATA
                    // =================================
                    Align(
                      alignment:
                          Alignment.centerRight,

                      child: SizedBox(
                        height: 34,

                        child:
                            ElevatedButton.icon(
                          onPressed: () {
                            // TODO:
                            // Buka form pendataan
                          },

                          icon: const Icon(
                            Icons.add,
                            size: 16,
                          ),

                          label: const Text(
                            'Tambah Data',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.primary,

                            foregroundColor:
                                AppColors.white,

                            elevation: 3,

                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 13,
                            ),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(7),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================
  // SEARCH
  // ===============================================

  Widget _buildSearch() {
    return SizedBox(
      height: 39,

      child: TextField(
        controller: searchController,

        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textPrimary,
        ),

        decoration: InputDecoration(
          hintText:
              'Cari nomor lampu atau lokasi...',

          hintStyle: const TextStyle(
            fontSize: 10,
            color: AppColors.textHint,
          ),

          prefixIcon: const Icon(
            Icons.search,
            size: 18,
            color: AppColors.icon,
          ),

          filled: true,

          fillColor:
              const Color(0xFFF5F4FC),

          contentPadding:
              EdgeInsets.zero,

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

            borderSide:
                const BorderSide(
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================
  // FILTER
  // ===============================================

  Widget _buildFilters() {
    return Row(
      children: [
        _buildFilterButton(
          title: 'Semua',
          index: 0,
        ),

        const SizedBox(width: 5),

        _buildFilterButton(
          title: 'Tersimpan',
          index: 1,
        ),

        const SizedBox(width: 5),

        _buildFilterButton(
          title: 'Belum Lengkap',
          index: 2,
        ),
      ],
    );
  }

  Widget _buildFilterButton({
    required String title,
    required int index,
  }) {
    final selected =
        selectedFilter == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = index;
        });
      },

      child: Container(
        height: 25,

        padding:
            const EdgeInsets.symmetric(
          horizontal: 11,
        ),

        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : const Color(0xFFF8F8FC),

          borderRadius:
              BorderRadius.circular(15),

          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.border,
          ),
        ),

        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 9,

              fontWeight:
                  FontWeight.w600,

              color: selected
                  ? AppColors.white
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================
  // LAMP CARD
  // ===============================================

  Widget _buildLampCard(
    Installation installation,
  ) {
    final isIncomplete =
        installation.idInstallations == 3;

    return GestureDetector(
      onTap: () {
        debugPrint(
          'Lamp dipilih: '
          '${installation.idInstallations}',
        );

        // TODO:
        // Navigator ke detail_lampu_page.dart
      },

      child: Container(
        width: double.infinity,

        padding:
            const EdgeInsets.fromLTRB(
          10,
          10,
          10,
          8,
        ),

        decoration: BoxDecoration(
          color: AppColors.background,

          borderRadius:
              BorderRadius.circular(7),

          border: Border.all(
            color: isIncomplete
                ? const Color(0xFFFFC9B8)
                : AppColors.border,
          ),
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // =====================================
            // NAMA + STATUS
            // =====================================
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        installation
                            .controllerCode,

                        style:
                            const TextStyle(
                          fontSize: 11,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              AppColors
                                  .textPrimary,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        installation
                                    .idLampType ==
                                1
                            ? 'LED Street Light 100W'
                            : 'LED Street Light 150W',

                        style:
                            const TextStyle(
                          fontSize: 8,
                          color:
                              AppColors
                                  .textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                _buildStatus(
                  isIncomplete,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // =====================================
            // LOKASI
            // =====================================
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 12,
                  color: AppColors.icon,
                ),

                const SizedBox(width: 3),

                Expanded(
                  child: Text(
                    '${installation.address}\n'
                    '${installation.latitude ?? '-'}, '
                    '${installation.longitude ?? '-'}',

                    style:
                        const TextStyle(
                      fontSize: 8,
                      color:
                          AppColors
                              .textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            // =====================================
            // GARIS
            // =====================================
            Container(
              height: 1,
              color:
                  const Color(0xFFE8E8EE),
            ),

            const SizedBox(height: 6),

            // =====================================
            // FOOTER
            // =====================================
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [
                Row(
                  children: [
                    Icon(
                      isIncomplete
                          ? Icons
                              .image_not_supported_outlined
                          : Icons
                              .photo_library_outlined,

                      size: 10,

                      color: isIncomplete
                          ? const Color(
                              0xFFFF8B52)
                          : AppColors.link,
                    ),

                    const SizedBox(width: 3),

                    Text(
                      isIncomplete
                          ? 'Belum ada foto'
                          : '${installation.idInstallations == 1 ? 3 : 2} Foto',

                      style: TextStyle(
                        fontSize: 8,
                        color: isIncomplete
                            ? const Color(
                                0xFFFF8B52)
                            : AppColors.link,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                Text(
                  isIncomplete
                      ? 'Diperbarui 18 Mei 2025, 11:45'
                      : installation.idInstallations ==
                              1
                          ? 'Diperbarui 20 Mei 2025, 14:30'
                          : 'Diperbarui 19 Mei 2025, 16:20',

                  style: const TextStyle(
                    fontSize: 7,
                    color:
                        AppColors
                            .textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================
  // STATUS
  // ===============================================

  Widget _buildStatus(
    bool incomplete,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),

      decoration: BoxDecoration(
        color: incomplete
            ? const Color(0xFFFFF1E9)
            : const Color(0xFFE8FFF3),

        borderRadius:
            BorderRadius.circular(10),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            incomplete
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,

            size: 9,

            color: incomplete
                ? const Color(0xFFFF8B52)
                : const Color(0xFF28B878),
          ),

          const SizedBox(width: 2),

          Text(
            incomplete
                ? 'Belum Lengkap'
                : 'Tersimpan',

            style: TextStyle(
              fontSize: 7,

              fontWeight:
                  FontWeight.w600,

              color: incomplete
                  ? const Color(0xFFFF8B52)
                  : const Color(0xFF28B878),
            ),
          ),
        ],
      ),
    );
  }
}