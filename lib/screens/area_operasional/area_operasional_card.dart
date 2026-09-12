import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class AreaOperasionalCard extends StatelessWidget {
  final String title;
  final String location;
  final String dateRange;
  final String status;
  final VoidCallback? onTap;

  const AreaOperasionalCard({
    super.key,
    required this.title,
    required this.location,
    required this.dateRange,
    this.status = 'aktif',
    this.onTap,
  });

  bool get isActive => status.toLowerCase() != 'nonaktif';

  @override
  Widget build(BuildContext context) {
    final active = isActive;

    return Container(
      decoration: BoxDecoration(
        gradient: active
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D4B85),
                  Color(0xFF093766),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEFF2F6),
                  Color(0xFFE2E7ED),
                ],
              ),
        borderRadius: BorderRadius.circular(10),
        border: active
            ? null
            : Border.all(
                color: const Color(0xFFD1D5DB),
                width: 1,
              ),
        boxShadow: active
            ? const [
                BoxShadow(
                  color: Color(0x1A0C5DA5),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: active ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Area Name / Title + Nonaktif Badge
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: active ? Colors.white : const Color(0xFF4B5563),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!active) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCBD5E1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Nonaktif',
                                style: TextStyle(
                                  color: Color(0xFF334155),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Location Row
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: active ? Colors.white70 : const Color(0xFF94A3B8),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: TextStyle(
                                color: active ? Colors.white70 : const Color(0xFF64748B),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Date Range Row
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: active ? Colors.white70 : const Color(0xFF94A3B8),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dateRange,
                            style: TextStyle(
                              color: active ? Colors.white70 : const Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Right Circular Button with Arrow
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: active ? Colors.white : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    border: active
                        ? null
                        : Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 1,
                          ),
                    boxShadow: active
                        ? const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: active ? AppColors.primary : const Color(0xFF94A3B8),
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
