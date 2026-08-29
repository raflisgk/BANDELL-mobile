import 'package:flutter/material.dart';

import '../models/project_model.dart';
import '../utils/app_colors.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final TextEditingController searchController =
      TextEditingController();

  // Sementara untuk tampilan.
  // Nanti data ini diganti dengan data dari api_service.dart.
  final List<Project> projects = [];

  List<Project> filteredProjects = [];

  @override
  void initState() {
    super.initState();

    filteredProjects = projects;

    searchController.addListener(
      _filterProjects,
    );
  }

  void _filterProjects() {
    final keyword =
        searchController.text.trim().toLowerCase();

    setState(() {
      if (keyword.isEmpty) {
        filteredProjects = projects;
      } else {
        filteredProjects = projects
            .where(
              (project) => project.projectName
                  .toLowerCase()
                  .contains(keyword),
            )
            .toList();
      }
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
            // =========================
            // HEADER
            // =========================
            Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                18,
                24,
                0,
              ),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [
                  const Icon(
                    Icons.notifications_none_outlined,
                    color: AppColors.primary,
                    size: 27,
                  ),

                  GestureDetector(
                    onTap: () {
                      // TODO: Logout
                    },

                    child: Row(
                      children: const [
                        Icon(
                          Icons.logout,
                          color: AppColors.primary,
                          size: 21,
                        ),

                        SizedBox(width: 4),

                        Text(
                          'Logout',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // =========================
            // CONTENT
            // =========================
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(
                  30,
                  28,
                  30,
                  25,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Pilih Proyek',
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
                      'Berikut proyek yang tersedia untuk Anda.',
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
                    // PROJECT
                    // =========================
                    _buildProjectList(),
                  ],
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

        decoration: InputDecoration(
          hintText: 'Cari project...',

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
          fillColor: const Color(0xFFF3F4FB),

          contentPadding: EdgeInsets.zero,

          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(7),

            borderSide: const BorderSide(
              color: AppColors.border,
            ),
          ),

          focusedBorder: OutlineInputBorder(
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

  Widget _buildProjectList() {
    if (filteredProjects.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),

        child: Center(
          child: Text(
            'Belum ada proyek yang ditugaskan.',
            style: TextStyle(
              color: AppColors.textSecondary,
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

      itemCount: filteredProjects.length,

      separatorBuilder:
          (_, __) => const SizedBox(
        height: 14,
      ),

      itemBuilder: (context, index) {
        return _buildProjectCard(
          filteredProjects[index],
        );
      },
    );
  }

  Widget _buildProjectCard(
    Project project,
  ) {
    return Material(
      color: AppColors.primary,

      borderRadius:
          BorderRadius.circular(9),

      child: InkWell(
        borderRadius:
            BorderRadius.circular(9),

        onTap: () {
          // Project yang dipilih
          debugPrint(
            'Project ID: ${project.idProject}',
          );

          // Nanti:
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => AreaPage(
          //       idProject: project.idProject,
          //     ),
          //   ),
          // );
        },

        child: Container(
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
                  Text(
                    project.projectName,

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

                  const SizedBox(height: 4),

                  Row(
                    children: const [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColors.white,
                        size: 13,
                      ),

                      SizedBox(width: 3),

                      Text(
                        'Lokasi proyek',
                        style: TextStyle(
                          color:
                              AppColors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Row(
                    children: [
                      const Icon(
                        Icons
                            .calendar_month_outlined,
                        color:
                            AppColors.white,
                        size: 13,
                      ),

                      const SizedBox(width: 3),

                      Text(
                        _formatDateRange(
                          project.startDate,
                          project.endDate,
                        ),

                        style:
                            const TextStyle(
                          color:
                              AppColors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
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

  static String _formatDateRange(
    DateTime? start,
    DateTime? end,
  ) {
    if (start == null && end == null) {
      return 'Tanggal belum tersedia';
    }

    if (start == null) {
      return _formatDate(end!);
    }

    if (end == null) {
      return _formatDate(start);
    }

    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }
}