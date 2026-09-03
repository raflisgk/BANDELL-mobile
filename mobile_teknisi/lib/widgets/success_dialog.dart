import 'package:flutter/material.dart';
import '../screens/history_page.dart';
import '../utils/app_colors.dart';
import '../utils/page_transitions.dart';

class SuccessDialog extends StatelessWidget {
  final String lampCode;
  final VoidCallback? onAddData;
  final VoidCallback? onViewHistory;

  const SuccessDialog({
    super.key,
    required this.lampCode,
    this.onAddData,
    this.onViewHistory,
  });

  static Future<void> show(
    BuildContext context, {
    required String lampCode,
    VoidCallback? onAddData,
    VoidCallback? onViewHistory,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: SuccessDialog(
          lampCode: lampCode,
          onAddData: onAddData != null
              ? () {
                  Navigator.pop(dialogContext);
                  onAddData();
                }
              : () => Navigator.pop(dialogContext),
          onViewHistory: onViewHistory != null
              ? () {
                  Navigator.pop(dialogContext);
                  onViewHistory();
                }
              : () {
                  Navigator.pop(dialogContext);
                  AppNavigator.pushTabReplacement(context, const HistoryPage());
                },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Green Checkmark Badge
              const _AnimatedCheckBadge(),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Data Berhasil Disimpan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle / Description with Dynamic Lamp Code
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.5,
                    height: 1.45,
                  ),
                  children: [
                    const TextSpan(text: 'Informasi lampu '),
                    TextSpan(
                      text: lampCode,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text: ' telah\ntersimpan ke dalam database sistem.',
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // Button 1: Tambah Data
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onAddData ?? () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tambah Data',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Button 2: Lihat Riwayat
              TextButton(
                onPressed: onViewHistory ??
                    () {
                      Navigator.pop(context);
                      AppNavigator.pushTabReplacement(
                        context,
                        const HistoryPage(),
                      );
                    },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  'Lihat Riwayat',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
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

class _AnimatedCheckBadge extends StatefulWidget {
  const _AnimatedCheckBadge();

  @override
  State<_AnimatedCheckBadge> createState() => _AnimatedCheckBadgeState();
}

class _AnimatedCheckBadgeState extends State<_AnimatedCheckBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _checkScaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xFF15803D),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF15803D).withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: ScaleTransition(
            scale: _checkScaleAnimation,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF15803D),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
