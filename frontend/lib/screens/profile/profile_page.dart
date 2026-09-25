import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/bottom_navbar.dart';
import '../../widgets/custom_feedback.dart';
import '../area_operasional/area_operasional_page.dart';
import '../history/history_page.dart';
import '../login/login_page.dart';
import '../notification/notification_page.dart';
import 'editable_profile_item.dart';
import '../../services/secure_credential_service.dart';

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

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _editController.dispose();
    _editFocusNode.dispose();
    super.dispose();
  }

  void _startEditingPhone() {
    setState(() {
      _editController.text = _phone == '-'
          ? ''
          : (_phone.length > 13 ? _phone.substring(0, 13) : _phone);
      _activeEditField = ProfileEditField.phone;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _editFocusNode.requestFocus();
    });
  }

  Future<void> _saveActiveField() async {
    final newValue = _editController.text.trim();

    if (newValue.isEmpty) return;

    if (_activeEditField == ProfileEditField.phone) {
      if (newValue.length > 13) {
        CustomFeedback.showError(context, 'Nomor telepon maksimal 13 karakter');
        return;
      }

      final success = await AuthService().updatePhone(newValue);

      if (!mounted) return;

      if (success) {
        _editFocusNode.unfocus();
        setState(() {
          _phone = newValue;
          _activeEditField = ProfileEditField.none;
        });

        CustomFeedback.showSuccess(context, 'Nomor HP berhasil diperbarui');
      } else {
        CustomFeedback.showError(context, 'Nomor HP gagal diperbarui');
      }
    }
  }

  void _cancelEditing() {
    _editFocusNode.unfocus();
    setState(() {
      _activeEditField = ProfileEditField.none;
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
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFEF4444),
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
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Color(0xFF475569),
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
                        backgroundColor: const Color(0xFFEF4444),
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
    final double keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardOpen = keyboardInset > 0;

    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double headerTopPadding = (screenHeight >= 800) ? 12.0 : 8.0;

    return Scaffold(
      backgroundColor: const Color(0xFF265C8C),
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0072CE), Color(0xFF265C8C)],
          ),
        ),
        child: SafeArea(
          bottom: !isKeyboardOpen,
          child: Column(
            children: [
              // Header Title & Subtitle with Notification Icon
              Padding(
                padding: EdgeInsets.fromLTRB(16, headerTopPadding, 16, 0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(
                            height: 40,
                            child: Center(
                              child: Text(
                                'Profil Saya',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Kelola informasi akun Anda',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        onPressed: _handleNotification,
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Automatic Proportional Scrollable Content for ALL Devices
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double availableHeight = constraints.maxHeight;
                    // Linear continuous interpolation factor based on available middle height (480px - 720px)
                    final double factor = ((availableHeight - 480) / 240).clamp(
                      0.0,
                      1.0,
                    );

                    double lerp(double minVal, double maxVal) =>
                        minVal + (maxVal - minVal) * factor;

                    final double topbarGap = lerp(4.0, 16.0);
                    final double cardTopPadding = lerp(44.0, 62.0);
                    final double cardBottomPadding = lerp(12.0, 30.0);
                    final double cardBottomMargin = lerp(10.0, 22.0);
                    final double nameRoleGap = lerp(4.0, 8.0);
                    final double itemHeaderGap = lerp(14.0, 34.0);
                    final double itemSpacing = lerp(5.0, 13.0);
                    final double itemVerticalPadding = lerp(4.5, 13.5);
                    final double logoutGap = lerp(10.0, 34.0);

                    final EdgeInsets itemPadding = EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: itemVerticalPadding,
                    );

                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: topbarGap),
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: [
                              // White Container Card with fully rounded corners
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(
                                  top: 45,
                                  bottom: cardBottomMargin,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                padding: EdgeInsets.fromLTRB(
                                  20,
                                  cardTopPadding,
                                  20,
                                  cardBottomPadding,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // User Name & Role
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            _formattedName,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.verified_rounded,
                                          color: Color(0xFF0072CE),
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: nameRoleGap),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEBF3FC),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFBFDBFE),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.engineering_rounded,
                                            size: 15,
                                            color: Color(0xFF0C5DA5),
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              _role.toUpperCase(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Color(0xFF0C5DA5),
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.6,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: itemHeaderGap),

                                    // 1. NAMA LENGKAP (READ-ONLY)
                                    EditableProfileItem(
                                      icon: Icons.person_outline_rounded,
                                      title: 'Nama Lengkap',
                                      value: _formattedName,
                                      isEditable: false,
                                      contentPadding: itemPadding,
                                    ),
                                    SizedBox(height: itemSpacing),

                                    // 2. SUREL (READ-ONLY)
                                    EditableProfileItem(
                                      icon: Icons.email_outlined,
                                      title: 'Surel',
                                      value: _email,
                                      isEditable: false,
                                      contentPadding: itemPadding,
                                    ),
                                    SizedBox(height: itemSpacing),

                                    // 3. NOMOR TELEPON (EDITABLE)
                                    EditableProfileItem(
                                      icon: Icons.phone_outlined,
                                      title: 'Nomor Telepon',
                                      value: _phone,
                                      isEditable: true,
                                      isEditing:
                                          _activeEditField ==
                                          ProfileEditField.phone,
                                      controller: _editController,
                                      focusNode: _editFocusNode,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 13,
                                      onTap: _startEditingPhone,
                                      onSave: _saveActiveField,
                                      onCancel: _cancelEditing,
                                      contentPadding: itemPadding,
                                    ),
                                    SizedBox(height: itemSpacing),

                                    // 4. LOKASI (READ-ONLY)
                                    EditableProfileItem(
                                      icon: Icons.location_on_outlined,
                                      title: 'Lokasi',
                                      value: _location,
                                      isEditable: false,
                                      contentPadding: itemPadding,
                                    ),

                                    SizedBox(height: logoutGap),

                                    // Tombol Keluar
                                    GestureDetector(
                                      onTap: _showLogoutDialog,
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          'Keluar',
                                          style: TextStyle(
                                            color: Color(0xFFEF4444),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Avatar Badge Overlapping Header and White Card
                              Positioned(top: 0, child: _buildAvatarBadge()),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isKeyboardOpen
          ? null
          : BottomNavbar(currentIndex: 2, onTap: _handleNavTap),
    );
  }

  Widget _buildAvatarBadge() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFFE2EBF8),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF0C5DA5),
              size: 46,
            ),
          ),
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFF0C5DA5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x20000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.edit_outlined, color: Colors.white, size: 13),
            ),
          ),
        ),
      ],
    );
  }
}
