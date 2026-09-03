import 'package:flutter/material.dart';
import '../../dummy/dummy_data.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_top_bar.dart';

class NotificationItem {
  final int id;
  final String title;
  final String time;
  final String content;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  bool isUnread;
  final String section;
  final String? boldText;

  NotificationItem({
    required this.id,
    required this.title,
    required this.time,
    required this.content,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.isUnread = false,
    required this.section,
    this.boldText,
  });
}

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
    final terbaruList =
        _notifications.where((n) => n.section == 'TERBARU').toList();
    final sebelumnyaList =
        _notifications.where((n) => n.section == 'SEBELUMNYA').toList();

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
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // EMPTY STATE
              if (_notifications.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
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

              // SECTION 1: TERBARU
              if (terbaruList.isNotEmpty) ...[
                const Text(
                  'TERBARU',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                ...terbaruList.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildNotificationCard(item),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // SECTION 2: SEBELUMNYA
              if (sebelumnyaList.isNotEmpty) ...[
                const Text(
                  'SEBELUMNYA',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                ...sebelumnyaList.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildNotificationCard(item),
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

  Widget _buildNotificationCard(NotificationItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNotificationTap(item),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Icon Pill
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    color: item.iconColor,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 14),

                // Content Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Title & Time / Unread Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                item.time,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (item.isUnread) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Description Text (with bold target keyword if specified)
                      _buildContentText(item.content, item.boldText),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentText(String content, String? boldText) {
    if (boldText == null || !content.contains(boldText)) {
      return Text(
        content,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          height: 1.4,
        ),
      );
    }

    final parts = content.split(boldText);
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          height: 1.4,
        ),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: boldText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }
}
