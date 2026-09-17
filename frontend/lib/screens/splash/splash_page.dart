import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/secure_credential_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/page_transitions.dart';
import '../area_operasional/area_operasional_page.dart';
import '../login/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    final stopwatch = Stopwatch()..start();
    bool isAuthenticated = false;

    try {
      if (AuthService.currentUser != null) {
        isAuthenticated = true;
      } else {
        final hasActiveSession = await SecureCredentialService.isSessionActive();
        if (hasActiveSession) {
          final cachedUserJson = await SecureCredentialService.getUserData();
          if (cachedUserJson != null && cachedUserJson.isNotEmpty) {
            try {
              final userMap = jsonDecode(cachedUserJson) as Map<String, dynamic>;
              AuthService.currentUser = UserModel.fromJson(userMap);
              isAuthenticated = true;
            } catch (e) {
              debugPrint('Splash parse cached user error: $e');
            }
          }

          // Verifikasi / refresh session jika ada kredensial tersimpan
          final savedCreds = await SecureCredentialService.getSavedCredentials();
          if (savedCreds != null &&
              savedCreds['email'] != null &&
              savedCreds['password'] != null) {
            try {
              final res = await ApiService.login(
                email: savedCreds['email']!,
                password: savedCreds['password']!,
              );
              if (res['user'] != null) {
                await SecureCredentialService.setSession(
                  isLoggedIn: true,
                  userDataJson: jsonEncode(res['user']),
                );
              }
              isAuthenticated = true;
            } catch (e) {
              if (e is ApiException && e.statusCode == 401) {
                // Kredensial sudah tidak valid di server
                isAuthenticated = false;
                AuthService.currentUser = null;
                await SecureCredentialService.setSession(isLoggedIn: false);
              }
              // Jika offline/network error namun sudah ada cachedUser, biarkan isAuthenticated tetap true
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Splash auth check error: $e');
    }

    // Durasi minimal splash screen agar animasi tampil halus dan nyaman dilihat
    const minSplashDurationMs = 1800;
    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < minSplashDurationMs) {
      await Future.delayed(
        Duration(milliseconds: minSplashDurationMs - elapsed),
      );
    }

    if (!mounted) return;

    if (isAuthenticated && AuthService.currentUser != null) {
      AppNavigator.pushReplacement(
        context,
        const AreaOperasionalPage(),
      );
    } else {
      AppNavigator.pushReplacement(
        context,
        const LoginPage(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final shortestSide = media.size.shortestSide;
    // Ukuran logo responsif proporsional terhadap ukuran layar HP
    final logoSize = (shortestSide * 0.36).clamp(110.0, 160.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SizedBox(
                width: logoSize,
                height: logoSize,
                child: Image.asset(
                  'assets/images/logo bandell 1.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: logoSize * 0.6,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

