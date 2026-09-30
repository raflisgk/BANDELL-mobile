import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import '../../services/project_service.dart';
import '../../services/secure_credential_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/bottom_navbar.dart';
import '../../widgets/custom_feedback.dart';
import '../area_operasional/area_operasional_page.dart';
import '../history/history_page.dart';
import '../login/login_page.dart';
import '../notification/notification_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

enum ProfileEditField { none, phone }

class _ProfilePageState extends State<ProfilePage> {
  String _name = '-';
  String _role = 'Teknisi Lapangan';
  String _email = '-';
  String _phone = '-';
  String _location = '-';

  ProfileEditField _activeEditField = ProfileEditField.none;

  late TextEditingController _editController;
  final FocusNode _editFocusNode = FocusNode();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController();

    final user = AuthService.currentUser;

    if (user != null) {
      _name = user.name.isNotEmpty ? user.name : user.username;
      _role = user.role.isNotEmpty ? user.role : 'Teknisi Lapangan';
      _email = user.email ?? '-';
      _phone = user.phone ?? '-';
      _location = user.placementArea ?? '-';
    }

    _loadProfile();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _loadProfile(),
    );
  }

  Future<void> _loadProfile() async {
    final user = await AuthService().getProfile();
    if (user != null && mounted) {
      setState(() {
        _name = user.name.isNotEmpty ? user.name : user.username;
        _role = user.role.isNotEmpty ? user.role : 'Teknisi Lapangan';
        _email = user.email ?? '-';
        if (_activeEditField != ProfileEditField.phone) {
          _phone = user.phone ?? '-';
        }
        _location = user.placementArea ?? '-';
      });
    }
  }

  String get _formattedName {
    if (_name == '-' || _name.trim().isEmpty) return '-';
    return _name
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) return '';
          if (word.length == 1) return word.toUpperCase();
          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  String get _avatarInitials {
    if (_name == '-' || _name.trim().isEmpty) return 'T';
    final parts = _name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _editController.dispose();
    _editFocusNode.dispose();
    super.dispose();
  }

  void _startEditingPhone() {
    _showEditPhoneBottomSheet();
  }

  void _showEditPhoneBottomSheet() {
    setState(() {
      _activeEditField = ProfileEditField.phone;
    });

    _editController.text = _phone == '-'
        ? ''
        : (_phone.length > 13 ? _phone.substring(0, 13) : _phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            final keyboardPadding = MediaQuery.of(sheetContext)
                .viewInsets
                .bottom;

            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, keyboardPadding + 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.borderMedium,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.notifUnreadAvatarBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.phone_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Ubah Nomor Telepon',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nomor telepon ini digunakan untuk koordinasi tugas lapangan (maksimal 13 digit).',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _editController,
                    keyboardType: TextInputType.phone,
                    autofocus: true,
                    maxLength: 13,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(13),
                    ],
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Contoh: 081234567890',
                      counterText: '${_editController.text.length}/13',
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(modalContext);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(
                              color: AppColors.borderMedium,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              color: AppColors.textBody,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final newValue = _editController.text.trim();
                            if (newValue.isEmpty) return;
                            if (newValue.length > 13) {
                              CustomFeedback.showError(
                                sheetContext,
                                'Nomor telepon maksimal 13 karakter',
                              );
                              return;
                            }
                            Navigator.pop(modalContext);
                            final success = await AuthService().updatePhone(
                              newValue,
                            );
                            if (!mounted) return;
                            if (success) {
                              setState(() {
                                _phone = newValue;
                                _activeEditField = ProfileEditField.none;
                              });
                              CustomFeedback.showSuccess(
                                context,
                                'Nomor HP berhasil diperbarui',
                              );
                            } else {
                              CustomFeedback.showError(
                                context,
                                'Nomor HP gagal diperbarui',
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() {
          _activeEditField = ProfileEditField.none;
        });
      }
    });
  }

  void _handleNotification() async {
    await AppNavigator.push(context, const NotificationPage());
    if (mounted) {
      _loadProfile();
    }
  }

  void _handleNavTap(int index) {
    if (index == 0) {
      AppNavigator.pushTabReplacement(context, const AreaOperasionalPage());
    } else if (index == 1) {
      AppNavigator.pushTabReplacement(context, const HistoryPage());
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.logoutRedBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.logoutRed,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Keluar dari Akun?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Apakah Anda yakin ingin keluar dari akun?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.borderMedium),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: AppColors.textBody,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        AuthService.currentUser = null;
                        await SecureCredentialService.setSession(
                          isLoggedIn: false,
                        );
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                        if (!mounted) return;
                        AppNavigator.pushAndRemoveUntil(
                          context,
                          const LoginPage(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.logoutRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String projectCount = ProjectService.hasCachedProjects
        ? ProjectService.cachedProjects.length.toString()
        : '4';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double availableHeight = constraints.maxHeight;
            final double factor = ((availableHeight - 480) / 240).clamp(
              0.0,
              1.0,
            );
            double lerp(double minVal, double maxVal) =>
                minVal + (maxVal - minVal) * factor;

            final double avatarSize = lerp(72.0, 88.0);
            final double avatarFont = lerp(29.0, 36.0);
            final double topPadding = lerp(12.0, 28.0);
            final double sectionGap = lerp(8.0, 10.0);
            final double cardGap = lerp(5.0, 6.5);
            final double dataDiriVerticalPadding = lerp(6.5, 8.5);
            final double appRowVerticalPadding = lerp(5.5, 7.5);

            return Stack(
              children: [
                // 1. Ambient Soft Sky-Blue Glow di bagian atas (pudar dan halus)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 220,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFDCEFFE),
                          Color(0xFFF1F8FE),
                          Color(0x00F8FAFC),
                        ],
                        stops: [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),

                // 2. Konten Profil Scrollable
                SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16, topPadding, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Avatar di tengah
                      Center(
                        child: Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x180284C7),
                                blurRadius: 14,
                                offset: Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Color(0x18B45309),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _avatarInitials,
                              style: TextStyle(
                                fontSize: avatarFont,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFB45309),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Nama Teknisi
                      Text(
                        _formattedName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textHeading,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Subtitle: Email
                      Text(
                        _email,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Role Badge Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFBAE6FD),
                            width: 1.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A0284C7),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 5),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                _role,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '•',
                              style: TextStyle(
                                color: Color(0xFF93C5FD),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Aktif',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: sectionGap),

                      // ==========================================
                      // 2 KARTU METRIK HORIZONTAL
                      // ==========================================
                      Row(
                        children: [
                          _buildMetricCard(
                            icon: Icons.assignment_outlined,
                            title: 'Proyek',
                            value: projectCount,
                            color: AppColors.primary,
                            iconBg: const Color(0xFFEFF6FF),
                          ),
                          const SizedBox(width: 10),
                          _buildMetricCard(
                            icon: Icons.lightbulb_outline_rounded,
                            title: 'Lampu',
                            value: '128',
                            color: AppColors.primary,
                            iconBg: const Color(0xFFEFF6FF),
                          ),
                        ],
                      ),

                      SizedBox(height: cardGap),

                      // ==========================================
                      // GRUP KARTU 1: INFORMASI DATA DIRI & PENUGASAN
                      // ==========================================
                      _buildSectionLabel('DATA DIRI & PENUGASAN'),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 0.8,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildGroupRow(
                              icon: Icons.person_outline_rounded,
                              iconBg: const Color(0xFFEFF6FF),
                              iconColor: AppColors.primary,
                              title: 'Nama',
                              value: _formattedName,
                              verticalPadding: dataDiriVerticalPadding,
                            ),
                            const Divider(
                              height: 1,
                              indent: 58,
                              endIndent: 14,
                              color: AppColors.divider,
                            ),
                            _buildGroupRow(
                              icon: Icons.mail_outline_rounded,
                              iconBg: const Color(0xFFEFF6FF),
                              iconColor: AppColors.primary,
                              title: 'Email',
                              value: _email,
                              verticalPadding: dataDiriVerticalPadding,
                            ),
                            const Divider(
                              height: 1,
                              indent: 58,
                              endIndent: 14,
                              color: AppColors.divider,
                            ),
                            _buildGroupRow(
                              icon: Icons.phone_outlined,
                              iconBg: const Color(0xFFEFF6FF),
                              iconColor: AppColors.primary,
                              title: 'Nomor Telepon',
                              value: _phone,
                              showChevron: true,
                              actionBadge: 'Ubah',
                              onTap: _startEditingPhone,
                              verticalPadding: dataDiriVerticalPadding,
                            ),
                            const Divider(
                              height: 1,
                              indent: 58,
                              endIndent: 14,
                              color: AppColors.divider,
                            ),
                            _buildLocationRow(
                              verticalPadding: dataDiriVerticalPadding,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: cardGap * 1.5),

                      // ==========================================
                      // KARTU MENU NOTIFIKASI
                      // ==========================================
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 0.8,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: _handleNotification,
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: appRowVerticalPadding + 1.5,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEFF6FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.notifications_outlined,
                                        color: AppColors.primary,
                                        size: 19,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Notifikasi',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.textSubtle,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: cardGap * 1.2),

                      // ==========================================
                      // TOMBOL KELUAR
                      // ==========================================
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 0.8,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: _showLogoutDialog,
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: appRowVerticalPadding + 1.5,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: const BoxDecoration(
                                      color: AppColors.logoutRedBg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.logout_rounded,
                                        color: AppColors.logoutRed,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Keluar',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.logoutRed,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.logoutRed,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Versi Aplikasi Simple (Tanpa Kotak)
                      const Text(
                        'Versi Aplikasi v1.0.0',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavbar(currentIndex: 2, onTap: _handleNavTap),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color iconBg,
    bool isStatus = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Center(child: Icon(icon, color: color, size: 20)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isStatus ? color : AppColors.textHeading,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    bool showChevron = false,
    String? actionBadge,
    VoidCallback? onTap,
    double verticalPadding = 7.5,
  }) {
    final Widget content = Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: verticalPadding),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Center(child: Icon(icon, color: iconColor, size: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (actionBadge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                actionBadge,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (showChevron)
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSubtle,
              size: 20,
            ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: content),
      );
    }

    return content;
  }

  Widget _buildLocationRow({double verticalPadding = 7.5}) {
    final List<String> locationList =
        _location == '-' || _location.trim().isEmpty
        ? []
        : _location
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

    final bool hasMoreThan3 = locationList.length > 3;
    final List<String> displayedList = hasMoreThan3
        ? locationList.take(3).toList()
        : locationList;
    final int remainingCount = locationList.length - 3;
    final List<String> remainingList = hasMoreThan3
        ? locationList.skip(3).toList()
        : [];
    final String tooltipMessage = remainingList.join(', ');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: verticalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lokasi',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3.5),
                if (locationList.isEmpty)
                  Text(
                    _location,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  )
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...displayedList.map((loc) {
                        return Container(
                          constraints: const BoxConstraints(maxWidth: 175),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.5,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.roleBadgeBackground,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.roleBadgeBorder,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.place_rounded,
                                size: 11,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 3.5),
                              Flexible(
                                child: Text(
                                  loc,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (hasMoreThan3)
                        Tooltip(
                          triggerMode: TooltipTriggerMode.tap,
                          showDuration: const Duration(seconds: 4),
                          constraints: BoxConstraints(
                            maxWidth: math.max(
                              160.0,
                              MediaQuery.of(context).size.width - 78.0 - 24.0,
                            ),
                          ),
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          positionDelegate: (context) {
                            final fitsBelow =
                                context.target.dy +
                                    context.verticalOffset +
                                    context.tooltipSize.height <=
                                context.overlaySize.height - 10.0;
                            final fitsAbove =
                                context.target.dy -
                                    context.verticalOffset -
                                    context.tooltipSize.height >=
                                10.0;
                            final tooltipBelow = fitsAbove == fitsBelow
                                ? context.preferBelow
                                : fitsBelow;
                            final double y = tooltipBelow
                                ? math.min(
                                    context.target.dy + context.verticalOffset,
                                    context.overlaySize.height - 10.0,
                                  )
                                : math.max(
                                    context.target.dy -
                                        context.verticalOffset -
                                        context.tooltipSize.height,
                                    10.0,
                                  );

                            // Batas kiri: persis sejajar awal tulisan 'Lokasi' (78px dari kiri layar)
                            const double minX = 78.0;
                            final double maxX = math.max(
                              minX,
                              context.overlaySize.width -
                                  24.0 -
                                  context.tooltipSize.width,
                            );

                            final double targetCenterX =
                                context.target.dx +
                                (context.targetSize.width / 2);
                            final double idealX =
                                targetCenterX - (context.tooltipSize.width / 2);
                            final double x = idealX.clamp(minX, maxX);

                            return Offset(x, y);
                          },
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                          message: tooltipMessage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              '+$remainingCount',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
