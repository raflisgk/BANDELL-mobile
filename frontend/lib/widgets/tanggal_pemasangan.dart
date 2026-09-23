import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Reusable Widget Tanggal Pemasangan *
/// Sesuai dengan desain form teknisi (berpasangan dengan KodePanel, Catatan, & Dokumentasi)
class TanggalPemasangan extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? title;
  final String? subtitle;
  final bool isRequired;
  final String? hintText;
  final String? errorMessage;

  const TanggalPemasangan({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.title = 'Tanggal Pemasangan',
    this.subtitle = 'Masukkan tanggal pemasangan',
    this.isRequired = true,
    this.hintText,
    this.errorMessage,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initial = selectedDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle = title ?? 'Tanggal Pemasangan';
    final displaySubtitle = subtitle ?? 'Masukkan tanggal pemasangan';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF), // Soft light blue
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.event_note_outlined,
                color: Color(0xFF2563EB), // Primary blue
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        displayTitle,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isRequired) ...[
                        const SizedBox(width: 4),
                        const Text(
                          '*',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displaySubtitle,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12.5,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Input Field Box
        InkWell(
          onTap: () => _pickDate(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: errorMessage != null
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              selectedDate != null
                  ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                  : (hintText ?? ''),
              style: TextStyle(
                color: selectedDate != null
                    ? const Color(0xFF1E293B)
                    : const Color(0xFF94A3B8),
                fontSize: 14,
                fontWeight: selectedDate != null
                    ? FontWeight.w500
                    : FontWeight.w400,
              ),
            ),
          ),
        ),

        if (errorMessage != null) ...[
          const SizedBox(height: 4),
          Text(
            errorMessage!,
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
