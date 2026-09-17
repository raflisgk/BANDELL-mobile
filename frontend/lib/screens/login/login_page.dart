import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_colors.dart';
import '../../utils/page_transitions.dart';
import '../area_operasional/area_operasional_page.dart';
import '../../services/api_service.dart';
import '../../services/secure_credential_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  late final AnimationController _animController;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _formFadeAnimation;
  late final Animation<Offset> _formSlideAnimation;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _usernameFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
    _usernameController.addListener(_clearErrorOnTyping);
    _passwordController.addListener(_clearErrorOnTyping);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _logoFadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.70, curve: Curves.easeOut),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.70, curve: Curves.easeOut),
      ),
    );

    _formFadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.20, 1.0, curve: Curves.easeOut),
    );

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.20, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -3.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -3.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    _animController.forward();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final saved = await SecureCredentialService.getSavedCredentials();
      if (saved != null && mounted) {
        setState(() {
          _rememberMe = true;
          _usernameController.text = saved['email'] ?? '';
          _passwordController.text = saved['password'] ?? '';
        });
      }
    } catch (_) {
      // Ignore secure storage read errors gracefully
    }
  }

  void _clearErrorOnTyping() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _animController.dispose();
    _shakeController.dispose();
    _usernameController.removeListener(_clearErrorOnTyping);
    _passwordController.removeListener(_clearErrorOnTyping);
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.removeListener(_onFocusChange);
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleRememberMeChanged(bool? value) async {
    final newValue = value ?? false;
    setState(() {
      _rememberMe = newValue;
    });

    if (!newValue) {
      try {
        await SecureCredentialService.clearCredentials();
      } catch (_) {}
    }
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    setState(() {
      _errorMessage = null;
    });

    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Silakan masukkan email dan password.';
      });
      _shakeController.forward(from: 0.0);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final loginResult = await ApiService.login(
        email: email,
        password: password,
      );

      if (_rememberMe) {
        await SecureCredentialService.saveCredentials(
          email: email,
          password: password,
        );
      } else {
        await SecureCredentialService.clearCredentials();
      }

      if (loginResult['user'] != null) {
        await SecureCredentialService.setSession(
          isLoggedIn: true,
          userDataJson: jsonEncode(loginResult['user']),
        );
      } else {
        await SecureCredentialService.setSession(isLoggedIn: true);
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      AppNavigator.pushAndRemoveUntil(
        context,
        const AreaOperasionalPage(),
      );
    } catch (e, stackTrace) {
      if (!mounted) return;

      debugPrint('LOGIN ERROR: $e');
      debugPrint('LOGIN STACKTRACE: $stackTrace');

      String displayMessage = 'Terjadi kesalahan. Silakan coba lagi.';

      if (e is ApiException) {
        displayMessage = e.message;
      } else {
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('timeout')) {
          displayMessage = 'Koneksi ke server timeout.';
        } else if (errorStr.contains('socket') ||
            errorStr.contains('clientexception') ||
            errorStr.contains('connection abort') ||
            errorStr.contains('connection refused') ||
            errorStr.contains('network is unreachable') ||
            errorStr.contains('failed host lookup')) {
          displayMessage = 'Koneksi ke server gagal.';
        } else if (errorStr.contains('500') ||
            errorStr.contains('server error') ||
            errorStr.contains('internal server')) {
          displayMessage = 'Terjadi kesalahan pada server.';
        } else if (errorStr.contains('401') ||
            errorStr.contains('email atau password salah') ||
            errorStr.contains('unauthorized')) {
          displayMessage = 'Email atau password salah.';
        }
      }

      // Strict sanitization: ensure NO raw technical details leak to the UI
      final lower = displayMessage.toLowerCase();
      if (lower.contains('clientexception') ||
          lower.contains('socketexception') ||
          lower.contains('os error') ||
          lower.contains('errno') ||
          lower.contains('address') ||
          lower.contains('port') ||
          lower.contains('http://') ||
          lower.contains('https://') ||
          lower.contains('exception:') ||
          lower.contains('stack trace')) {
        displayMessage = 'Koneksi ke server gagal.';
      }

      setState(() {
        _isLoading = false;
        _errorMessage = displayMessage;
      });
      _shakeController.forward(from: 0.0);
    }
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

  Future<void> _handleContactAdmin() async {
    const adminPhone = '62895627111665';
    final message = Uri.encodeComponent(
      'Halo Admin, saya ingin menghubungi Admin terkait akun aplikasi.',
    );
    final whatsappUrl = Uri.parse('https://wa.me/$adminPhone?text=$message');

    try {
      final canLaunch = await canLaunchUrl(whatsappUrl);
      if (!canLaunch) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WhatsApp tidak tersedia di perangkat.'),
              backgroundColor: Color(0xFFDC2626),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      final launched = await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp tidak tersedia di perangkat.'),
            backgroundColor: Color(0xFFDC2626),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp tidak tersedia di perangkat.'),
            backgroundColor: Color(0xFFDC2626),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
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
          physics: const ClampingScrollPhysics(),
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
                    child: FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: ScaleTransition(
                        scale: _logoScaleAnimation,
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
                    ),
                  ),

                  // 2. BOTTOM AREA (BLUE BANDELL BACKGROUND FORM)
                  Expanded(
                    child: FadeTransition(
                      opacity: _formFadeAnimation,
                      child: SlideTransition(
                        position: _formSlideAnimation,
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

                          _buildErrorMessage(),

                          // Username Field Container
                          _buildInputFieldContainer(
                            icon: Icons.person_outline_rounded,
                            label: 'Username',
                            hint: 'Masukkan username',
                            controller: _usernameController,
                            focusNode: _usernameFocusNode,
                            hasError: _errorMessage != null,
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
                            hasError: _errorMessage != null,
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
                                      onChanged: _handleRememberMeChanged,
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
                                  GestureDetector(
                                    onTap: () => _handleRememberMeChanged(!_rememberMe),
                                    child: const Text(
                                      'Ingat saya',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
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
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow,
                                foregroundColor: AppColors.primary,
                                disabledBackgroundColor: Colors.yellow.withValues(alpha: 0.6),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                        strokeWidth: 2.2,
                                      ),
                                    )
                                  : const Text(
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
    bool hasError = false,
    VoidCallback? onTogglePasswordVisibility,
  }) {
    final isFocused = focusNode.hasFocus;

    final borderColor = hasError
        ? const Color(0xFFEF4444)
        : (isFocused ? AppColors.primary : AppColors.border);
    final borderWidth = (hasError || isFocused) ? 1.5 : 1.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
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

  Widget _buildErrorMessage() {
    if (_errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: child,
            );
          },
          child: Text(
            _errorMessage!,
            style: const TextStyle(
              color: Color(0xFFFF6B6B),
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}
