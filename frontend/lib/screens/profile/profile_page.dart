import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/main_navigation_service.dart';
import '../../services/project_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/bottom_navbar.dart';
import '../../widgets/custom_feedback.dart';
import '../area_operasional/area_operasional_page.dart';
import '../history/history_page.dart';
import '../login/login_page.dart';
import '../notification/notification_page.dart';

class ProfilePage extends StatefulWidget {
  final bool isEmbedded;
  const ProfilePage({super.key, this.isEmbedded = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = '-';
  String _role = 'Teknisi Lapangan';
  String _email = '-';
  String _phone = '-';
  String _location = '-';
  int _totalLamps = 0;
  int _totalProjects = 0;
  bool _isEditingPhone = false;

  late final TextEditingController _editController;
  @override
  void initState() {
    super.initState();
    debugPrint('🚀 [NAVIGASI LAZY] Tab 2: ProfilePage baru pertama kali diinisialisasi!');
    _editController = TextEditingController();

    final user = AuthService.currentUser;
    if (user != null) {
      _applyUserData(user);
    }

    // Memuat data profil saat inisialisasi awal tanpa polling berulang yang boros daya
    _loadProfile();
    MainNavigationService.currentTabNotifier.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (MainNavigationService.currentIndex == 2 && mounted) {
      _loadProfile();
    }
  }

  void _applyUserData(dynamic user) {
    _name = user.name.isNotEmpty ? user.name : user.username;
    _role = user.role.isNotEmpty ? user.role : 'Teknisi Lapangan';
    _email = user.email ?? '-';
    if (!_isEditingPhone) {
      _phone = user.phone ?? '-';
    }
    _location = user.placementArea ?? '-';
    if (user is UserModel) {
      _totalLamps = user.totalInstallations;
      _totalProjects = user.totalProjects;
    }
  }

  Future<void> _loadProfile() async {
    final user = await AuthService().getProfile();
    if (user != null && mounted) {
      setState(() => _applyUserData(user));
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
    final trimmed = _name.trim();
    // Ambil huruf pertama dari nama depan user yang sedang login
    return trimmed.isNotEmpty ? trimmed[0].toUpperCase() : 'T';
  }

  @override
  void dispose() {
    MainNavigationService.currentTabNotifier.removeListener(_onTabChanged);
    _editController.dispose();
    super.dispose();
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16.r),
    border: Border.all(color: AppColors.borderLight, width: 0.8),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadowMinimal,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  Widget get _rowDivider => Divider(
    height: 1,
    indent: 58.w,
    endIndent: 14.w,
    color: AppColors.divider,
  );

  void _showEditPhoneBottomSheet() {
    setState(() => _isEditingPhone = true);

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
              padding: EdgeInsets.fromLTRB(
                20.w,
                18.h,
                20.w,
                keyboardPadding + 18.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: AppColors.borderMedium,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppColors.notifUnreadAvatarBg,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.phone_rounded,
                          color: AppColors.primary,
                          size: 20.r,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Ubah Nomor Telepon',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Nomor telepon ini digunakan untuk koordinasi tugas lapangan (maksimal 13 digit).',
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 16.h),
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
                    style: TextStyle(fontSize: 14.5.sp),
                    decoration: InputDecoration(
                      hintText: 'Contoh: 081234567890',
                      hintStyle: TextStyle(
                        fontSize: 13.5.sp,
                        color: AppColors.hintColor,
                      ),
                      counterText: '${_editController.text.length}/13',
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(modalContext),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            side: const BorderSide(
                              color: AppColors.borderMedium,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              color: AppColors.textBody,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
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
                                _isEditingPhone = false;
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
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
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
        setState(() => _isEditingPhone = false);
      }
    });
  }

  void _handleNotification() async {
    await AppNavigator.push(context, const NotificationPage());
    if (mounted) _loadProfile();
  }

  void _handleNavTap(int index) {
    if (MainNavigationService.hasMainLayout) {
      MainNavigationService.setIndex(index);
    } else {
      if (index == 0) {
        AppNavigator.pushTabReplacement(context, const AreaOperasionalPage());
      } else if (index == 1) {
        AppNavigator.pushTabReplacement(context, const HistoryPage());
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierColor: AppColors.barrierOverlay,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: AppColors.borderLight, width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowDark,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
              BoxShadow(
                color: AppColors.shadowSubtle,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(22.w, 26.h, 22.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Double Ring Soft Red Badge
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: AppColors.statusDitolakBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.statusDitolakBorder,
                    width: 2.0,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 46.r,
                    height: 46.r,
                    decoration: const BoxDecoration(
                      color: AppColors.statusDitolakCircleBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.logout_rounded,
                        color: AppColors.logoutRed,
                        size: 24.r,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 18.h),

              // Title
              Text(
                'Konfirmasi Keluar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.5.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHeading,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 8.h),

              // Subtitle
              Text(
                'Apakah Anda yakin ingin keluar dari akun? Anda perlu login kembali untuk mengakses data penugasan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textMuted,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 24.h),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.inputBackground,
                        padding: EdgeInsets.symmetric(vertical: 12.5.h),
                        side: const BorderSide(
                          color: AppColors.borderMedium,
                          width: 1.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: AppColors.textBody,
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await AuthService().logout();
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
                        padding: EdgeInsets.symmetric(vertical: 12.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        'Keluar',
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
    final String projectCount = _totalProjects > 0
        ? _totalProjects.toString()
        : (ProjectService.hasCachedProjects
            ? ProjectService.cachedProjects.length.toString()
            : '0');
    final String lampCount = _totalLamps.toString();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.scaffoldBackground,
        body: Stack(
          children: [
            // 1. Ambient Glow Transparan Lembut Mengalir Sampai ke Status Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 280.h,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.profileAmbientGlowStart,
                      AppColors.profileAmbientGlowMiddle,
                      AppColors.profileAmbientGlowEnd,
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),

            // 2. Konten Profil Responsif (Menyesuaikan Tinggi Layar Tanpa Void Kosong)
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 28.h),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: math.max(0.0, constraints.maxHeight - 60.h),
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // --- AREA ATAS: HEADER PROFIL & ROLE ---
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Avatar Inisial
                                Center(
                                  child: Container(
                                    width: 80.r,
                                    height: 80.r,
                                    decoration: BoxDecoration(
                                      color: AppColors.avatarAmberBackground,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3.5.r,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: AppColors.avatarShadowBlue,
                                          blurRadius: 14,
                                          offset: Offset(0, 4),
                                        ),
                                        BoxShadow(
                                          color: AppColors.avatarShadowAmber,
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        _avatarInitials,
                                        style: TextStyle(
                                          fontSize: 32.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.avatarAmberText,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 6.h),

                                // Nama Teknisi
                                Text(
                                  _formattedName,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 19.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textHeading,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: 2.h),

                                // Subtitle: Email
                                Text(
                                  _email,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5.sp,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 5.h),

                                // Role Badge Chip
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: AppColors.roleBadgeBorderLight,
                                      width: 1.0,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: AppColors.roleBadgeShadow,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6.r,
                                        height: 6.r,
                                        margin: EdgeInsets.only(right: 5.w),
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
                                          style: TextStyle(
                                            fontSize: 11.5.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 5.w),
                                      Text(
                                        '•',
                                        style: TextStyle(
                                          color: AppColors.roleBadgeDotDivider,
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 5.w),
                                      Text(
                                        'Aktif',
                                        style: TextStyle(
                                          fontSize: 11.5.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // --- AREA TENGAH: METRIK & DATA DIRI ---
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 2 Kartu Metrik Horizontal
                                Row(
                                  children: [
                                    _buildMetricCard(
                                      icon: Icons.assignment_outlined,
                                      title: 'Proyek',
                                      value: projectCount,
                                    ),
                                    SizedBox(width: 10.w),
                                    _buildMetricCard(
                                      icon: Icons.lightbulb_outline_rounded,
                                      title: 'Lampu',
                                      value: lampCount,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),

                                // Grup Kartu 1: Informasi Data Diri & Penugasan
                                _buildSectionLabel('DATA DIRI & PENUGASAN'),
                                Container(
                                  decoration: _cardDecoration,
                                  child: Column(
                                    children: [
                                      _buildGroupRow(
                                        icon: Icons.person_outline_rounded,
                                        title: 'Nama',
                                        value: _formattedName,
                                      ),
                                      _rowDivider,
                                      _buildGroupRow(
                                        icon: Icons.mail_outline_rounded,
                                        title: 'Email',
                                        value: _email,
                                      ),
                                      _rowDivider,
                                      _buildGroupRow(
                                        icon: Icons.phone_outlined,
                                        title: 'Nomor Telepon',
                                        value: _phone,
                                        showChevron: true,
                                        actionBadge: 'Ubah',
                                        onTap: _showEditPhoneBottomSheet,
                                      ),
                                      _rowDivider,
                                      _buildLocationRow(),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // --- AREA BAWAH: AKSI NOTIFIKASI, KELUAR & VERSI ---
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Kartu Menu Notifikasi
                                _buildActionCard(
                                  icon: Icons.notifications_outlined,
                                  iconBg: AppColors.softBlueBackground,
                                  iconColor: AppColors.primary,
                                  title: 'Notifikasi',
                                  titleColor: AppColors.textPrimary,
                                  chevronColor: AppColors.textSubtle,
                                  onTap: _handleNotification,
                                ),
                                SizedBox(height: 6.h),

                                // Tombol Keluar
                                _buildActionCard(
                                  icon: Icons.logout_rounded,
                                  iconBg: AppColors.logoutRedBg,
                                  iconColor: AppColors.logoutRed,
                                  title: 'Keluar',
                                  titleColor: AppColors.logoutRed,
                                  chevronColor: AppColors.logoutRed,
                                  onTap: _showLogoutDialog,
                                ),
                                SizedBox(height: 8.h),

                                // Versi Aplikasi
                                Text(
                                  'Versi Aplikasi v1.0.0',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSubtle,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: widget.isEmbedded
            ? null
            : BottomNavbar(
                currentIndex: 2,
                onTap: _handleNavTap,
              ),
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textSubtle,
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
    Color color = AppColors.primary,
    Color iconBg = AppColors.softBlueBackground,
    bool isStatus = false,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 12.w),
        decoration: _cardDecoration,
        child: Row(
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Center(
                child: Icon(icon, color: color, size: 20.r),
              ),
            ),
            SizedBox(width: 10.w),
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
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: isStatus ? color : AppColors.textHeading,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5.sp,
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

  Widget _buildActionCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required Color titleColor,
    required Color chevronColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: _cardDecoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            child: Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(icon, color: iconColor, size: 19.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: chevronColor,
                  size: 20.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupRow({
    required IconData icon,
    required String title,
    required String value,
    Color iconBg = AppColors.softBlueBackground,
    Color iconColor = AppColors.primary,
    bool showChevron = false,
    String? actionBadge,
    VoidCallback? onTap,
  }) {
    final Widget content = Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Center(
              child: Icon(icon, color: iconColor, size: 18.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (actionBadge != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.softBlueBackground,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                actionBadge,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(width: 4.w),
          ],
          if (showChevron)
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSubtle,
              size: 20.r,
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

  Widget _buildLocationRow() {
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
    final String tooltipMessage = hasMoreThan3
        ? locationList.skip(3).join(', ')
        : '';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: const BoxDecoration(
              color: AppColors.softBlueBackground,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: 18.r,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lokasi',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 3.5.h),
                if (locationList.isEmpty)
                  Text(
                    _location,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  )
                else
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 5.h,
                    children: [
                      ...displayedList.map((loc) {
                        return Container(
                          constraints: BoxConstraints(maxWidth: 175.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.5.w,
                            vertical: 3.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.roleBadgeBackground,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: AppColors.roleBadgeBorder,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.place_rounded,
                                size: 11.r,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 3.5.w),
                              Flexible(
                                child: Text(
                                  loc,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
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

                            final double minX = 78.w;
                            final double maxX = math.max(
                              minX,
                              context.overlaySize.width -
                                  24.w -
                                  context.tooltipSize.width,
                            );
                            final double targetCenterX =
                                context.target.dx +
                                context.targetSize.width / 2;
                            final double idealX =
                                targetCenterX - (context.tooltipSize.width / 2);
                            final double x = idealX.clamp(minX, maxX);

                            return Offset(x, y);
                          },
                          decoration: BoxDecoration(
                            color: AppColors.tooltipBackgroundDark,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.tooltipShadowDark,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                          message: tooltipMessage,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.softBlueBackground,
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: AppColors.roleBadgeBorder,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              '+$remainingCount',
                              style: TextStyle(
                                fontSize: 11.5.sp,
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
