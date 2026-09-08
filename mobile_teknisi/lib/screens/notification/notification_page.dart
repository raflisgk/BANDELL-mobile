import 'package:flutter/material.dart';
import '../../dummy/dummy_data.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_top_bar.dart';
import 'notification_card.dart';

export 'notification_card.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = DummyDataConfig.useDummyData
        ? List.from(DummyData.notifications)
        : [];
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
  }

  @override
  Widget build(BuildContext context) {
    final terbaruList = _notifications
        .where((n) => n.section.toUpperCase() == 'TERBARU' || n.isUnread)
        .toList();
    final sebelumnyaList =
        _notifications.where((n) => !terbaruList.contains(n)).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: 'Notifikasi',
              showNotification: false,
              onBackPressed: _handleBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. EMPTY STATE
                    if (_notifications.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 60,
                          horizontal: 20,
                        ),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 54,
                              color: AppColors.textSecondary,
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
                              'Notifikasi penugasan dan status laporan Anda akan muncul di sini.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 2. SECTION 1: TERBARU
                    if (terbaruList.isNotEmpty) ...[
                      const Text(
                        'TERBARU',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...terbaruList.map(
                        (item) => NotificationCard(
                          notification: item,
                          onTap: () => _handleNotificationTap(item),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 3. SECTION 2: SEBELUMNYA
                    if (sebelumnyaList.isNotEmpty) ...[
                      const Text(
                        'SEBELUMNYA',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...sebelumnyaList.map(
                        (item) => NotificationCard(
                          notification: item,
                          onTap: () => _handleNotificationTap(item),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
