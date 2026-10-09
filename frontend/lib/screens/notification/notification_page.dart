import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../services/project_service.dart';
import '../../utils/app_colors.dart';
import 'notification_card.dart';

import 'package:lottie/lottie.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> _notifications = [];
  int? _expandedNotificationId;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // 1. Muat cache lokal HP segera secara sinkron (0ms, langsung tampil tanpa skeleton shimmer)
    final cached = NotificationService.getCachedNotificationsSync();
    if (cached.isNotEmpty) {
      _notifications = cached;
      _isLoading = false;
    } else {
      _isLoading = true;
    }

    // 2. Cek pembaruan notifikasi terbaru dari server di latar belakang secara hening
    _loadNotificationsSilently();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadNotificationsSilently() async {
    try {
      final list = await NotificationService().getNotifications(
        forceRefresh: true,
      );
      if (mounted) {
        setState(() {
          _notifications = list;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('Silent load notifications error: $e');
      if (mounted) {
        // Hanya tampilkan layar error jika benar-benar belum ada data cache sama sekali di HP
        if (_notifications.isEmpty) {
          setState(() {
            _hasError = true;
            _errorMessage =
                'Gagal memuat notifikasi. Periksa koneksi internet Anda.';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _loadNotifications() async {
    // Dipanggil saat pull-to-refresh
    await _loadNotificationsSilently();
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _handleNotificationTap(NotificationModel item) {
    debugPrint('Notification selected: ${item.title}');
    setState(() {
      if (_expandedNotificationId == item.id) {
        // Jika ditekan ulang, tutup (collapse)
        _expandedNotificationId = null;
      } else {
        // Buka kartu ini (accordion)
        _expandedNotificationId = item.id;
        item.isUnread = false;
        NotificationService().markAsRead(item.id);

        // Jika notifikasi penugasan baru, sinkronkan project jika tersedia
        if (item.type == NotificationType.assignment) {
          if (item.projectId != null && item.projectId! > 0) {
            ProjectService.selectedProject = ProjectService.getProjectById(
              item.projectId!,
            );
          } else if (item.projectName.isNotEmpty && item.projectName != '-') {
            ProjectService.selectedProject = ProjectService.getProjectByName(
              item.projectName,
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final sorted = List<NotificationModel>.from(_notifications)
      ..sort((a, b) {
        final aDate = a.createdAt ?? a.assignedAt ?? DateTime(1970);
        final bDate = b.createdAt ?? b.assignedAt ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });

    final terbaruList = <NotificationModel>[];
    final sebelumnyaList = <NotificationModel>[];

    for (final item in sorted) {
      final dt = item.createdAt?.toLocal() ?? item.assignedAt?.toLocal();

      if (dt == null) {
        sebelumnyaList.add(item);
        continue;
      }

      final itemDay = DateTime(dt.year, dt.month, dt.day);

      if (itemDay == today || itemDay.isAfter(today)) {
        terbaruList.add(item);
      } else {
        sebelumnyaList.add(item);
      }
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.inputBackground,
        body: Column(
        children: [
          // 1. Header Sesuai Warna Layar
          Container(
            color: AppColors.inputBackground,
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      onPressed: _handleBack,
                    ),
                    const Expanded(
                      child: Text(
                        'Notifikasi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 48,
                    ), // Menyeimbangkan tombol back agar teks tepat di tengah
                  ],
                ),
              ),
            ),
          ),

          // 2. Konten Notifikasi
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadNotifications,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Loading State
                    if (_isLoading)
                      Skeletonizer(
                        enabled: true,
                        child: Column(
                          children: List.generate(
                            4,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: NotificationCard(
                                notification: NotificationModel(
                                  id: index,
                                  title: 'Penugasan Baru Diterima',
                                  projectName: 'Pemasangan Lampu Jalan Utama',
                                  message:
                                      'Anda telah ditugaskan untuk proyek ini',
                                  time: '10 menit yang lalu',
                                  isUnread: true,
                                  notes: 'Harap selesaikan sebelum jam 5 sore',
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    // Error State
                    else if (_hasError)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 20,
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/connection_error.png',
                              height: 160,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.wifi_off_rounded,
                                  size: 54,
                                  color: AppColors.error,
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Koneksi Bermasalah',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 18),
                            ElevatedButton.icon(
                              onPressed: _loadNotifications,
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Coba Lagi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    // Empty State
                    else if (_notifications.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 60,
                          horizontal: 24,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: Lottie.asset(
                                'assets/animations/empty_notification.json',
                                fit: BoxFit.contain,
                                repeat: true,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum Ada Notifikasi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Notifikasi penugasan dari admin akan muncul di sini.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    // Notification List
                    else ...[
                      // =========================
                      // SECTION TERBARU
                      // =========================
                      if (terbaruList.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 12),
                          child: Text(
                            'TERBARU',
                            style: TextStyle(
                              color: AppColors.textBody,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        // Card TERBARU
                        ...terbaruList.map(
                          (item) => NotificationCard(
                            notification: item,
                            isExpanded: _expandedNotificationId == item.id,
                            onTap: () => _handleNotificationTap(item),
                          ),
                        ),

                        if (sebelumnyaList.isNotEmpty)
                          const SizedBox(height: 16),
                      ],

                      // =========================
                      // SECTION SEBELUMNYA
                      // =========================
                      if (sebelumnyaList.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 12, top: 4),
                          child: Text(
                            'SEBELUMNYA',
                            style: TextStyle(
                              color: AppColors.textBody,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        // Card SEBELUMNYA
                        ...sebelumnyaList.map(
                          (item) => NotificationCard(
                            notification: item,
                            isExpanded: _expandedNotificationId == item.id,
                            onTap: () => _handleNotificationTap(item),
                          ),
                        ),
                      ],
                    ],
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
}
