import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class PilihTanggal extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const PilihTanggal({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
  });

  static const List<String> monthNames = [
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
    'Desember'
  ];

  /// Helper statis untuk menampilkan bottom sheet pemilihan rentang tanggal
  static Future<Map<String, DateTime>?> show(
    BuildContext context, {
    DateTime? initialStartDate,
    DateTime? initialEndDate,
  }) async {
    return showModalBottomSheet<Map<String, DateTime>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PilihTanggal(
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
      ),
    );
  }

  @override
  State<PilihTanggal> createState() => _PilihTanggalState();
}

class _PilihTanggalState extends State<PilihTanggal> {
  late DateTime _focusedMonth;
  DateTime? _startDate;
  DateTime? _endDate;
  late final DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime(2025, 5, 19);
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    if (_startDate != null) {
      _focusedMonth = DateTime(_startDate!.year, _startDate!.month, 1);
    } else {
      _focusedMonth = DateTime(2025, 5, 1);
    }
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        // Pemilihan pertama: set tanggal mulai, kosongkan tanggal akhir
        _startDate = day;
        _endDate = null;
      } else if (_startDate != null && _endDate == null) {
        // Pemilihan kedua: jika tanggal kedua lebih awal dari tanggal pertama, swap agar rentang tetap valid
        if (day.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = day;
        } else {
          _endDate = day;
        }
      }
    });
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isInRange(DateTime day) {
    if (_startDate == null || _endDate == null) return false;
    return day.isAfter(_startDate!) && day.isBefore(_endDate!);
  }

  @override
  Widget build(BuildContext context) {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final leadingDays = firstDayOfMonth.weekday - 1; // Mon = 1
    final prevMonthDays = DateTime(year, month, 0).day;

    final bool isRangeValid = _startDate != null && _endDate != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Drag Handle Bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header Row (Title & Close Button)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pilih Tanggal',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF64748B),
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),

          // Month Navigation Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _prevMonth,
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
                Text(
                  '${PilihTanggal.monthNames[month - 1]} $year',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Weekday Header Row (Sen, Sel, Rab, Kam, Jum, Sab, Min)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildWeekdayHeader('Sen', false),
                _buildWeekdayHeader('Sel', false),
                _buildWeekdayHeader('Rab', false),
                _buildWeekdayHeader('Kam', false),
                _buildWeekdayHeader('Jum', false),
                _buildWeekdayHeader('Sab', true),
                _buildWeekdayHeader('Min', true),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Days Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildDaysGrid(
              year: year,
              month: month,
              daysInMonth: daysInMonth,
              leadingDays: leadingDays,
              prevMonthDays: prevMonthDays,
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons: Batal & Pilih
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isRangeValid
                      ? () {
                          Navigator.pop(context, {
                            'startDate': _startDate!,
                            'endDate': _endDate!,
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0x5900569E),
                    disabledForegroundColor: const Color(0x99FFFFFF),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 42,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Pilih',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader(String label, bool isWeekend) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isWeekend ? const Color(0xFFDC2626) : const Color(0xFF475569),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDaysGrid({
    required int year,
    required int month,
    required int daysInMonth,
    required int leadingDays,
    required int prevMonthDays,
  }) {
    List<Widget> rows = [];
    List<Widget> currentRow = [];

    int totalCells = leadingDays + daysInMonth;
    int trailingDays = (7 - (totalCells % 7)) % 7;
    int totalGridCells = totalCells + trailingDays;

    for (int i = 0; i < totalGridCells; i++) {
      if (i < leadingDays) {
        // Previous Month Day
        final dayNum = prevMonthDays - leadingDays + i + 1;
        final date = DateTime(year, month - 1, dayNum);
        currentRow.add(
          _buildDayCell(
            dayText: dayNum.toString(),
            isCurrentMonth: false,
            isWeekend: false,
            date: date,
          ),
        );
      } else if (i < leadingDays + daysInMonth) {
        // Current Month Day
        final dayNum = i - leadingDays + 1;
        final date = DateTime(year, month, dayNum);
        final isWeekend = date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday;

        currentRow.add(
          _buildDayCell(
            dayText: dayNum.toString(),
            isCurrentMonth: true,
            isWeekend: isWeekend,
            date: date,
          ),
        );
      } else {
        // Next Month Day
        final dayNum = i - (leadingDays + daysInMonth) + 1;
        final date = DateTime(year, month + 1, dayNum);
        currentRow.add(
          _buildDayCell(
            dayText: dayNum.toString(),
            isCurrentMonth: false,
            isWeekend: false,
            date: date,
          ),
        );
      }

      if (currentRow.length == 7) {
        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(children: List.from(currentRow)),
          ),
        );
        currentRow.clear();
      }
    }

    return Column(children: rows);
  }

  Widget _buildDayCell({
    required String dayText,
    required bool isCurrentMonth,
    required bool isWeekend,
    required DateTime date,
  }) {
    final bool isStart = _isSameDay(date, _startDate);
    final bool isEnd = _isSameDay(date, _endDate);
    final bool inRange = _isInRange(date);
    final bool isToday = _isSameDay(date, _today);
    final bool isSingleDate = isStart && _endDate == null;
    final bool isSelected = isStart || isEnd;

    // Range Highlight Styling
    Decoration? containerDecoration;
    if (isStart && isEnd) {
      containerDecoration = null;
    } else if (inRange) {
      containerDecoration = const BoxDecoration(
        color: Color(0xFFB8D5ED),
      );
    } else if (isStart && _endDate != null) {
      containerDecoration = const BoxDecoration(
        color: Color(0xFFB8D5ED),
        borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
      );
    } else if (isEnd && _startDate != null) {
      containerDecoration = const BoxDecoration(
        color: Color(0xFFB8D5ED),
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      );
    }

    // Inner Circle Styling
    BoxDecoration? circleDecoration;
    if (isSelected || isSingleDate) {
      circleDecoration = const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      );
    } else if (isToday && !inRange) {
      circleDecoration = BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 1.5),
      );
    }

    // Text Color
    Color textColor;
    if (!isCurrentMonth) {
      textColor = const Color(0xFFCBD5E1);
    } else if (isSelected || isSingleDate) {
      textColor = Colors.white;
    } else if (isWeekend && !inRange) {
      textColor = const Color(0xFFDC2626);
    } else {
      textColor = const Color(0xFF1E293B);
    }

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onDaySelected(date),
        child: Container(
          height: 44,
          decoration: containerDecoration,
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: circleDecoration,
              child: Center(
                child: Text(
                  dayText,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13.5,
                    fontWeight: isSelected || isToday || isSingleDate
                        ? FontWeight.bold
                        : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
