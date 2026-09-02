import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'project_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _usernameFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.removeListener(_onFocusChange);
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    debugPrint('Login attempted: username=$username, password=$password, rememberMe=$_rememberMe');

    // Navigation for UI preview
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ProjectPage(),
      ),
    );
  }

  void _handleForgotPassword() {
    debugPrint('Lupa password clicked');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lupa password (Aksi UI Sementara)'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleContactAdmin() {
    debugPrint('Hubungi Admin clicked');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hubungi Admin (Aksi UI Sementara)'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;
    final availableHeight = mediaQuery.size.height - mediaQuery.padding.top;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: isKeyboardOpen
              ? const BouncingScrollPhysics()
              : const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: availableHeight > 0 ? availableHeight : 600,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. TOP AREA (WHITE BACKGROUND)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.fastOutSlowIn,
                    color: AppColors.backgroundWhite,
                    constraints: BoxConstraints(
                      minHeight: isKeyboardOpen ? 0 : (availableHeight * 0.55),
                    ),
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                      top: isKeyboardOpen ? 16.0 : 44.0,
                      bottom: isKeyboardOpen ? 12.0 : 24.0,
                      left: 24.0,
                      right: 24.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Shield Crest BANDELL Logo with smooth AnimatedContainer sizing
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.fastOutSlowIn,
                          width: isKeyboardOpen ? 60 : 90,
                          height: isKeyboardOpen ? 60 : 90,
                          child: Image.asset(
                            'assets/images/logo bandell 1.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.shield_outlined,
                                  color: Colors.white,
                                  size: isKeyboardOpen ? 34 : 48,
                                ),
                              );
                            },
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.fastOutSlowIn,
                          height: isKeyboardOpen ? 8 : 14,
                        ),

                        // BANDELL Title Text
                        const Text(
                          'BANDELL',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Subtitle Text
                        const Text(
                          'Silakan login untuk melanjutkan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. BOTTOM AREA (BLUE BANDELL BACKGROUND FORM)
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.loginBlueGradientStart,
                            AppColors.loginBlueGradientEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                        top: 32.0,
                        bottom: 32.0 + mediaQuery.padding.bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),

                          // Username Field Container
                          _buildInputFieldContainer(
                            icon: Icons.person_outline_rounded,
                            label: 'Username',
                            hint: 'Masukkan username',
                            controller: _usernameController,
                            focusNode: _usernameFocusNode,
                          ),

                          const SizedBox(height: 16),

                          // Password Field Container
                          _buildInputFieldContainer(
                            icon: Icons.lock_outline_rounded,
                            label: 'Password',
                            hint: 'Masukkan password',
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            isPassword: true,
                            isPasswordVisible: _isPasswordVisible,
                            onTogglePasswordVisibility: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),

                          const SizedBox(height: 14),

                          // Remember Me & Forgot Password Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Remember Me Checkbox
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: Colors.white,
                                      checkColor: AppColors.primary,
                                      side: const BorderSide(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Ingat saya',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              // Forgot Password Link
                              GestureDetector(
                                onTap: _handleForgotPassword,
                                child: const Text(
                                  'Lupa password?',
                                  style: TextStyle(
                                    color: AppColors.loginLinkCyan,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Login Button (White Background)
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Hubungi Admin Footer Link
                          GestureDetector(
                            onTap: _handleContactAdmin,
                            child: Center(
                              child: Text.rich(
                                TextSpan(
                                  text: 'Belum punya akun? ',
                                  style: const TextStyle(
                                    color: Color(0xD9FFFFFF),
                                    fontSize: 12.5,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Hubungi Admin',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputFieldContainer({
    required IconData icon,
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePasswordVisibility,
  }) {
    final isFocused = focusNode.hasFocus;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? AppColors.primary : AppColors.border,
          width: isFocused ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.hintColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  obscureText: isPassword && !isPasswordVisible,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: AppColors.hintColor,
                      fontSize: 14,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          if (isPassword && onTogglePasswordVisibility != null)
            IconButton(
              onPressed: onTogglePasswordVisibility,
              icon: Icon(
                isPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.hintColor,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
