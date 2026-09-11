import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../utils/app_colors.dart';
import 'notification_card.dart';

export 'notification_card.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _loadNotificationsSilently(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final list = await NotificationService().getNotifications();
      if (mounted) {
        setState(() {
          _notifications = list
              .map((n) => NotificationItem.fromModel(n))
              .toList();

          // Pastikan diurutkan dari yang paling baru
          _notifications.sort((a, b) {
            final aDate = a.assignedAt ?? DateTime(1970);
            final bDate = b.assignedAt ?? DateTime(1970);
            return bDate.compareTo(aDate);
          });

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Gagal memuat notifikasi. Periksa koneksi internet Anda.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadNotificationsSilently() async {
    try {
      final list = await NotificationService().getNotifications();
      if (mounted) {
        setState(() {
          _notifications = list
              .map((n) => NotificationItem.fromModel(n))
              .toList();

          // Pastikan diurutkan dari yang paling baru
          _notifications.sort((a, b) {
            final aDate = a.assignedAt ?? DateTime(1970);
            final bDate = b.assignedAt ?? DateTime(1970);
            return bDate.compareTo(aDate);
          });
        });
      }
    } catch (e) {
      debugPrint('Error silently loading notifications: $e');
    }
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _handleNotificationTap(NotificationItem item) {
    debugPrint('Notification selected: ${item.title}');
    setState(() {
      item.isUnread = false;
    });
    NotificationService().markAsRead(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final terbaruList = <NotificationItem>[];
    final sebelumnyaList = <NotificationItem>[];

    for (final item in _notifications) {
      final dt = item.assignedAt?.toLocal();
      if (dt != null && (dt.isAfter(today) || now.difference(dt).inHours < 24)) {
        terbaruList.add(item);
      } else if (item.isUnread) {
        terbaruList.add(item);
      } else {
        sebelumnyaList.add(item);
      }
    }

    // Jika semua notifikasi adalah tanggal sebelumnya, pastikan yang teratas tetap muncul di TERBARU
    if (terbaruList.isEmpty && sebelumnyaList.isNotEmpty) {
      terbaruList.add(sebelumnyaList.removeAt(0));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // 1. Header Biru Sesuai Desain Referensi
          Container(
            color: AppColors.primary,
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
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: _handleBack,
                    ),
                    const Expanded(
                      child: Text(
                        'Notifikasi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Menyeimbangkan tombol back agar teks tepat di tengah
                  ],
                ),
              ),
            ),
          ),

          // 2. Konten Notifikasi
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Loading State
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    // Error State
                    else if (_hasError)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 60,
                          horizontal: 20,
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 54,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Gagal Memuat Notifikasi',
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
                          vertical: 80,
                          horizontal: 20,
                        ),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 54,
                              color: Color(0xFF94A3B8),
                            ),
                            SizedBox(height: 14),
                            Text(
                              'Belum Ada Notifikasi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
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
                      // Section 1: TERBARU
                      if (terbaruList.isNotEmpty) ...[
                        const Text(
                          'TERBARU',
                          style: TextStyle(
                            color: Color(0xFF556987),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...terbaruList.map(
                          (item) => NotificationCard(
                            notification: item,
                            isTerbaru: true,
                            onTap: () => _handleNotificationTap(item),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Section 2: SEBELUMNYA
                      if (sebelumnyaList.isNotEmpty) ...[
                        const Text(
                          'SEBELUMNYA',
                          style: TextStyle(
                            color: Color(0xFF556987),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...sebelumnyaList.map(
                          (item) => NotificationCard(
                            notification: item,
                            isTerbaru: false,
                            onTap: () => _handleNotificationTap(item),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
