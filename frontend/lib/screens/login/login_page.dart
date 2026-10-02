import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  late final AnimationController _animController;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _formFadeAnimation;
  late final Animation<Offset> _formSlideAnimation;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  late final AnimationController _focusAnimController;
  late final Animation<double> _focusScaleAnimation;
  late final Animation<double> _focusPaddingAnimation;

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

    _formSlideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.20, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 6.0, end: -3.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -3.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );

    _focusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _focusScaleAnimation = Tween<double>(begin: 1.0, end: 0.72).animate(
      CurvedAnimation(
        parent: _focusAnimController,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeInOutCubic,
      ),
    );

    _focusPaddingAnimation = Tween<double>(begin: 20.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _focusAnimController,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeInOutCubic,
      ),
    );

    _animController.forward();
  }

  void _clearErrorOnTyping() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  void _onFocusChange() {
    final hasFocus = _usernameFocusNode.hasFocus || _passwordFocusNode.hasFocus;
    if (hasFocus) {
      _focusAnimController.forward();
    } else {
      _focusAnimController.reverse();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _animController.dispose();
    _shakeController.dispose();
    _focusAnimController.dispose();
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

      AppNavigator.pushAndRemoveUntil(context, const AreaOperasionalPage());
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: isKeyboardOpen
                      ? const ClampingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      maxHeight: isKeyboardOpen
                          ? double.infinity
                          : constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. TOP AREA (WHITE BACKGROUND - BANDELL BRANDING)
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _focusAnimController,
                              builder: (context, child) {
                                return Container(
                                  color: AppColors.backgroundWhite,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                    vertical: _focusPaddingAnimation.value.h,
                                  ),
                                  child: FadeTransition(
                                    opacity: _logoFadeAnimation,
                                    child: ScaleTransition(
                                      scale: _logoScaleAnimation,
                                      child: Transform.scale(
                                        scale: _focusScaleAnimation.value,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Shield Crest BANDELL Logo
                                            SizedBox(
                                              width: 90.r,
                                              height: 90.r,
                                              child: Image.asset(
                                                'assets/images/logo bandell 1.png',
                                                fit: BoxFit.contain,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                              color: AppColors
                                                                  .primary,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                        child: Icon(
                                                          Icons.shield_outlined,
                                                          color: Colors.white,
                                                          size: 46.r,
                                                        ),
                                                      );
                                                    },
                                              ),
                                            ),
                                            SizedBox(height: 12.h),

                                            // BANDELL Title Text
                                            Text(
                                              'BANDELL',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 26.sp,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),

                                            // Subtitle Text
                                            Text(
                                              'Silakan login untuk melanjutkan',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 13.5.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // 2. BOTTOM AREA (BLUE BANDELL BACKGROUND FORM - COMPACT & SNUG)
                          FadeTransition(
                            opacity: _formFadeAnimation,
                            child: SlideTransition(
                              position: _formSlideAnimation,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.loginBlueGradientStart,
                                      AppColors.loginBlueGradientEnd,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(32.r),
                                  ),
                                ),
                                padding: EdgeInsets.fromLTRB(
                                  24.w,
                                  28.h,
                                  24.w,
                                  28.h +
                                      (isKeyboardOpen
                                          ? 0
                                          : mediaQuery.padding.bottom),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildErrorMessage(),

                                    // Username Field Container
                                    _buildInputFieldContainer(
                                      icon: Icons.person_rounded,
                                      label: 'Username',
                                      controller: _usernameController,
                                      focusNode: _usernameFocusNode,
                                      hasError: _errorMessage != null,
                                    ),

                                    SizedBox(height: 14.h),

                                    // Password Field Container
                                    _buildInputFieldContainer(
                                      icon: Icons.lock_rounded,
                                      label: 'Password',
                                      controller: _passwordController,
                                      focusNode: _passwordFocusNode,
                                      isPassword: true,
                                      isPasswordVisible: _isPasswordVisible,
                                      hasError: _errorMessage != null,
                                      onTogglePasswordVisibility: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                    ),

                                    SizedBox(height: 24.h),

                                    // Login Button (White Background)
                                    SizedBox(
                                      height: 48.h,
                                      child: ElevatedButton(
                                        onPressed: _isLoading
                                            ? null
                                            : _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.loginButtonBg,
                                          foregroundColor: AppColors.primary,
                                          disabledBackgroundColor:
                                              AppColors.loginButtonDisabledBg,
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                          ),
                                        ),
                                        child: _isLoading
                                            ? SizedBox(
                                                width: 22.r,
                                                height: 22.r,
                                                child:
                                                    const CircularProgressIndicator(
                                                      color: AppColors.primary,
                                                      strokeWidth: 2.2,
                                                    ),
                                              )
                                            : Text(
                                                'Login',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 15.5.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputFieldContainer({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    bool isPassword = false,
    bool isPasswordVisible = false,
    bool hasError = false,
    VoidCallback? onTogglePasswordVisibility,
  }) {
    final isFocused = focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: hasError
              ? AppColors.error
              : (isFocused ? AppColors.primary : const Color(0xFFE2E8F0)),
          width: hasError || isFocused ? 1.6 : 1.0,
        ),
        boxShadow: [
          if (hasError)
            BoxShadow(
              color: AppColors.error.withValues(alpha: 0.16),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          else if (isFocused)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword && !isPasswordVisible,
        cursorColor: AppColors.primary,
        style: TextStyle(
          color: const Color(0xFF0F172A),
          fontSize: 14.5.sp,
          fontWeight: FontWeight.normal,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: null,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: TextStyle(
            color: const Color(0xFF64748B),
            fontSize: 13.5.sp,
            fontWeight: FontWeight.normal,
          ),
          floatingLabelStyle: TextStyle(
            color: hasError ? AppColors.error : AppColors.primary,
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Icon(
              icon,
              color: hasError
                  ? AppColors.error
                  : (isFocused ? AppColors.primary : const Color(0xFF64748B)),
              size: 21.r,
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 48.w),
          suffixIcon: isPassword && onTogglePasswordVisibility != null
              ? Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: IconButton(
                    onPressed: onTogglePasswordVisibility,
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: isFocused
                          ? AppColors.primary
                          : const Color(0xFF94A3B8),
                      size: 20.r,
                    ),
                    splashRadius: 18.r,
                  ),
                )
              : null,
          filled: false,
          isDense: false,
          contentPadding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    if (_errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 2.w),
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
            style: TextStyle(
              color: AppColors.loginErrorRed,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}
