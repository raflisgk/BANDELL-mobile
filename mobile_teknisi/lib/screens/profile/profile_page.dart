import 'package:flutter/material.dart';
import '../../dummy/dummy_data.dart';
import '../../utils/app_colors.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/bottom_navbar.dart';
import '../area_operasional/area_operasional_page.dart';
import '../history/history_page.dart';
import '../login/login_page.dart';
import '../notification/notification_page.dart';
import 'editable_profile_item.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

enum ProfileEditField { none, name, email, phone, location }

class _ProfilePageState extends State<ProfilePage> {
  String _name = 'Devanda Mahesa Putra';
  final String _role = 'Teknisi Lapangan';
  String _email = 'devanda@email.com';
  String _phone = '+62 812 3456 7890';
  String _location = 'Jakarta, Indonesia';

  ProfileEditField _activeEditField = ProfileEditField.none;

  late TextEditingController _editController;
  final FocusNode _editFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController();
    if (DummyDataConfig.useDummyData) {
      _name = DummyData.profileData['name'] ?? _name;
      _email = DummyData.profileData['email'] ?? _email;
      _phone = DummyData.profileData['phone'] ?? _phone;
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    _editFocusNode.dispose();
    super.dispose();
  }

  void _startEditing(ProfileEditField field) {
    String initialText = '';
    switch (field) {
      case ProfileEditField.name:
        initialText = _name;
        break;
      case ProfileEditField.email:
        initialText = _email;
        break;
      case ProfileEditField.phone:
        initialText = _phone;
        break;
      case ProfileEditField.location:
        initialText = _location;
        break;
      case ProfileEditField.none:
        break;
    }

    setState(() {
      _editController.text = initialText;
      _activeEditField = field;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _editFocusNode.requestFocus();
    });
  }

  void _saveActiveField() {
    final newValue = _editController.text.trim();
    if (newValue.isEmpty) return;

    String fieldLabel = '';
    setState(() {
      switch (_activeEditField) {
        case ProfileEditField.name:
          _name = newValue;
          fieldLabel = 'Nama';
          break;
        case ProfileEditField.email:
          _email = newValue;
          fieldLabel = 'Email';
          break;
        case ProfileEditField.phone:
          _phone = newValue;
          fieldLabel = 'Nomor Telepon';
          break;
        case ProfileEditField.location:
          _location = newValue;
          fieldLabel = 'Lokasi';
          break;
        case ProfileEditField.none:
          break;
      }
      _activeEditField = ProfileEditField.none;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$fieldLabel berhasil disimpan'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _cancelEditing() {
    setState(() {
      _activeEditField = ProfileEditField.none;
    });
  }

  void _handleNotification() {
    AppNavigator.push(context, const NotificationPage());
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
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
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
                      onPressed: () {
                        Navigator.pop(dialogContext);
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0072CE), // Bright vibrant blue
            Color(0xFF265C8C), // Muted deeper blue
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              AppTopBar(
                showDropdown: false,
                showBackButton: false,
                onNotificationPressed: _handleNotification,
                iconColor: Colors.white,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // Header Title & Subtitle
                      const Center(
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
                      const SizedBox(height: 3),
                      const Center(
                        child: Text(
                          'Kelola informasi akun Anda',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Main White Card Content & Overlapping Avatar (Non-scrollable)
                      Expanded(
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            // White Container Card with fully rounded corners
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 45, bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              padding: const EdgeInsets.fromLTRB(20, 60, 20, 14),
                              child: Column(
                                children: [
                                  // User Name & Role
                                  Text(
                                    _name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  GestureDetector(
                                    onTap: () => _startEditing(ProfileEditField.name),
                                    child: Text(
                                      _role,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  // Email & Phone Row Info
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.email_outlined,
                                        size: 13,
                                        color: Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _email,
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.phone_outlined,
                                        size: 13,
                                        color: Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _phone,
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  // 1. NAMA LENGKAP
                                  EditableProfileItem(
                                    icon: Icons.person_outline_rounded,
                                    title: 'Nama Lengkap',
                                    value: _name,
                                    isEditing: _activeEditField == ProfileEditField.name,
                                    controller: _editController,
                                    focusNode: _editFocusNode,
                                    keyboardType: TextInputType.name,
                                    onTap: () => _startEditing(ProfileEditField.name),
                                    onSave: _saveActiveField,
                                    onCancel: _cancelEditing,
                                  ),
                                  const SizedBox(height: 10),

                                  // 2. EMAIL
                                  EditableProfileItem(
                                    icon: Icons.email_outlined,
                                    title: 'Email',
                                    value: _email,
                                    isEditing: _activeEditField == ProfileEditField.email,
                                    controller: _editController,
                                    focusNode: _editFocusNode,
                                    keyboardType: TextInputType.emailAddress,
                                    onTap: () => _startEditing(ProfileEditField.email),
                                    onSave: _saveActiveField,
                                    onCancel: _cancelEditing,
                                  ),
                                  const SizedBox(height: 10),

                                  // 3. NOMOR TELEPON
                                  EditableProfileItem(
                                    icon: Icons.phone_outlined,
                                    title: 'Nomor Telepon',
                                    value: _phone,
                                    isEditing: _activeEditField == ProfileEditField.phone,
                                    controller: _editController,
                                    focusNode: _editFocusNode,
                                    keyboardType: TextInputType.phone,
                                    onTap: () => _startEditing(ProfileEditField.phone),
                                    onSave: _saveActiveField,
                                    onCancel: _cancelEditing,
                                  ),
                                  const SizedBox(height: 10),

                                  // 4. LOKASI
                                   EditableProfileItem(
                                    icon: Icons.location_on_outlined,
                                    title: 'Lokasi',
                                    value: _location,
                                    isEditing: _activeEditField == ProfileEditField.location,
                                    controller: _editController,
                                    focusNode: _editFocusNode,
                                    keyboardType: TextInputType.streetAddress,
                                    onTap: () => _startEditing(ProfileEditField.location),
                                    onSave: _saveActiveField,
                                    onCancel: _cancelEditing,
                                  ),

                                  const Spacer(flex: 1),

                                  // Log Out Button
                                  GestureDetector(
                                    onTap: _showLogoutDialog,
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 6),
                                      child: Text(
                                        'Log Out',
                                        style: TextStyle(
                                          color: Color(0xFFEF4444),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const Spacer(flex: 1),
                                ],
                              ),
                            ),

                            // Avatar Badge Overlapping Header and White Card
                            Positioned(
                              top: 0,
                              child: _buildAvatarBadge(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavbar(
          currentIndex: 2,
          onTap: _handleNavTap,
        ),
      ),
    );
  }

  Widget _buildAvatarBadge() {
    return Stack(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFFE2EBF8),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
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
          child: GestureDetector(
            onTap: () => _startEditing(ProfileEditField.name),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF084B83),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
