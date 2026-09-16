import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class InformasiLampuCard extends StatelessWidget {
  final String code;
  final String type;
  final String? panelCode;
  final String status;
  final String inputMethod;

  const InformasiLampuCard({
    super.key,
    required this.code,
    required this.type,
    this.panelCode,
    required this.status,
    required this.inputMethod,
  });

  @override
  Widget build(BuildContext context) {
    final String method = inputMethod.trim().toLowerCase();

    final bool isRealtime =
        method == 'realtime' || method == 'real-time';

    final String methodText = isRealtime
        ? 'Realtime'
        : method == 'manual'
            ? 'Manual'
            : '-';

    final IconData methodIcon = isRealtime
        ? Icons.bolt_rounded
        : Icons.edit_note_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  label: 'TIPE LAMPU',
                  value: type.isNotEmpty ? type : '-',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatusItem(
                  status: status,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoItem(
                  label: 'KODE PANEL',
                  value: panelCode != null &&
                          panelCode!.trim().isNotEmpty
                      ? panelCode!.trim()
                      : '-',
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: _MethodItem(
                  label: 'METODE INPUT',
                  icon: methodIcon,
                  value: methodText,
                  isRealtime: isRealtime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.hintColor,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String status;

  const _StatusItem({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool isVerified =
        status.trim().toLowerCase() == 'terverifikasi';

    final String displayStatus =
        status.trim().isNotEmpty ? status : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'STATUS LAMPU',
          style: TextStyle(
            color: AppColors.hintColor,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: isVerified
                    ? AppColors.success
                    : AppColors.warning,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                displayStatus,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MethodItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final bool isRealtime;

  const _MethodItem({
    required this.label,
    required this.icon,
    required this.value,
    required this.isRealtime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.hintColor,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 36,
              height: 30,
              decoration: BoxDecoration(
                color: isRealtime
                    ? AppColors.successLight
                    : AppColors.manualBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isRealtime
                    ? AppColors.success
                    : AppColors.manualOrange,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}