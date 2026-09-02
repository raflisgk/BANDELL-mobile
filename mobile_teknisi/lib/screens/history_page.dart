import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/page_transitions.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/history_lamp_card.dart';
import 'area_operasional_page.dart';
import 'detail_lampu_page.dart';
import 'profile_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String _selectedFilter = 'Hari Ini';
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  final List<HistoryLampItem> _allHistoryItems = const [
    HistoryLampItem(
      kode: 'JKT-001',
      jenis: 'LED Street Light 100W',
      status: 'Terverifikasi',
      isVerified: true,
      lokasi: 'Jl. Sudirman No. 10, Jakarta',
      koordinat: '-6.2088, 106.8456',
      fotoCount: '3 Foto',
      waktu: 'Diperbarui 20 Mei 2025, 14:30',
    ),
    HistoryLampItem(
      kode: 'JKT-002',
      jenis: 'LED Street Light 150W',
      status: 'Terverifikasi',
      isVerified: true,
      lokasi: 'Jl. Gatot Subroto, Jakarta',
      koordinat: '-6.2146, 106.8451',
      fotoCount: '2 Foto',
      waktu: 'Diperbarui 19 Mei 2025, 16:20',
    ),
    HistoryLampItem(
      kode: 'JKT-003',
      jenis: 'LED Street Light 80W',
      status: 'Menunggu Verifikasi',
      isVerified: false,
      lokasi: 'Jl. Thamrin, Jakarta',
      koordinat: '-6.2012, 106.8270',
      fotoCount: 'Belum ada foto',
      waktu: 'Diperbarui 18 Mei 2025, 11:45',
    ),
    HistoryLampItem(
      kode: 'JKT-004',
      jenis: 'LED Street Light 80W',
      status: 'Menunggu Verifikasi',
      isVerified: false,
      lokasi: 'Jl. Senapati, Jakarta',
      koordinat: '-6.2012, 106.8270',
      fotoCount: 'Belum ada foto',
      waktu: 'Diperbarui 18 Mei 2025, 11:45',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  List<HistoryLampItem> get _filteredItems {
    if (_searchQuery.trim().isEmpty) {
      return _allHistoryItems;
    }
    final query = _searchQuery.toLowerCase().trim();
    return _allHistoryItems.where((item) {
      return item.kode.toLowerCase().contains(query) ||
          item.lokasi.toLowerCase().contains(query) ||
          item.jenis.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _handleFilterTap(String filter) async {
    if (filter == 'Pilih Tanggal') {
      final Map<String, dynamic>? result =
          await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _CustomDatePickerBottomSheet(
          initialStartDate: _selectedStartDate,
          initialEndDate: _selectedEndDate,
        ),
      );

      if (result != null) {
        setState(() {
          _selectedFilter = 'Pilih Tanggal';
          _selectedStartDate = result['startDate'] as DateTime?;
          _selectedEndDate = result['endDate'] as DateTime?;
        });
      }
    } else {
      setState(() {
        _selectedFilter = filter;
      });
    }
  }

  void _handleCardTap(HistoryLampItem item) {
    AppNavigator.push(
      context,
      DetailLampuPage(
        lampCode: item.kode,
      ),
    );
  }

  void _handleNavTap(int index) {
    if (index == 0) {
      AppNavigator.pushTabReplacement(context, const AreaOperasionalPage());
    } else if (index == 2) {
      AppNavigator.pushTabReplacement(context, const ProfilePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Top Content Header & Filters
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Back Arrow Header
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: _handleBack,
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Main Title
                    const Center(
                      child: Text(
                        '128 Lampu Tercatat',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Search Field
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Cari nomor lampu atau lokasi...',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 11,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Time Filter Pills Horizontal Scroll
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildFilterPill('Hari Ini'),
                          const SizedBox(width: 8),
                          _buildFilterPill('7 Hari'),
                          const SizedBox(width: 8),
                          _buildFilterPill('1 Bulan'),
                          const SizedBox(width: 8),
                          _buildFilterPill('Pilih Tanggal'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section Header: Terbaru & Daftar Lampu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Text(
                                  'Terbaru',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.swap_vert_rounded,
                                  size: 14,
                                  color: Color(0xFF64748B),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Daftar Lampu',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          '128 Record',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // List of History Cards
                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'Tidak ada data lampu ditemukan',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return HistoryLampCard(
                            item: item,
                            onTap: () => _handleCardTap(item),
                          );
                        },
                      ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Navigation Bar (Tab Riwayat Aktif)
            BottomNavbar(
              currentIndex: 1,
              onTap: _handleNavTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label) {
    final bool isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () => _handleFilterTap(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x29000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CustomDatePickerBottomSheet extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const _CustomDatePickerBottomSheet({
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<_CustomDatePickerBottomSheet> createState() =>
      _CustomDatePickerBottomSheetState();
}

class _CustomDatePickerBottomSheetState
    extends State<_CustomDatePickerBottomSheet> {
  late DateTime _focusedMonth;
  DateTime? _startDate;
  DateTime? _endDate;
  final DateTime _today = DateTime(2025, 5, 19);

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    if (_startDate != null) {
      _focusedMonth = DateTime(_startDate!.year, _startDate!.month, 1);
    } else {
      _focusedMonth = DateTime(2025, 5, 1);
    }
  }

  final List<String> _monthNames = const [
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
        _startDate = day;
        _endDate = null;
      } else if (_startDate != null && _endDate == null) {
        if (day.isBefore(_startDate!)) {
          _startDate = day;
          _endDate = null;
        } else if (day.isAfter(_startDate!)) {
          _endDate = day;
        } else {
          _startDate = day;
          _endDate = null;
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
                  '${_monthNames[month - 1]} $year',
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
                  onPressed: () {
                    Navigator.pop(context, {
                      'startDate': _startDate,
                      'endDate': _endDate,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
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
    if (inRange) {
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
