import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/secure_credential_service.dart';
import '../area_operasional/area_operasional_page.dart';
import '../login/login_page.dart';

class SplashPage extends StatefulWidget {
  final Widget? nextPage;

  const SplashPage({super.key, this.nextPage});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(milliseconds: 2800), _goToNextPage);
  }

  Future<void> _goToNextPage() async {
    if (!mounted) return;

    Widget targetPage = widget.nextPage ?? const LoginPage();

    if (widget.nextPage == null) {
      try {
        final token =
            ApiService.authToken ?? await SecureCredentialService.getAuthToken();
        final isSessionActive =
            await SecureCredentialService.isSessionActive();

        if (token != null && token.isNotEmpty && isSessionActive) {
          ApiService.setAuthToken(token);

          if (AuthService.currentUser == null) {
            final userData = await SecureCredentialService.getUserData();
            if (userData != null && userData.isNotEmpty) {
              final decoded = jsonDecode(userData);
              if (decoded is Map<String, dynamic>) {
                AuthService.currentUser = UserModel.fromJson(decoded);
              }
            }
          }

          if (AuthService.currentUser != null) {
            targetPage = const AreaOperasionalPage();
          }
        }
      } catch (e) {
        debugPrint('Error restoring session in splash: $e');
      }
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetPage,
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Lottie.asset(
            'assets/animations/splash_animation.json',
            width: 220,
            height: 250,
            fit: BoxFit.contain,
            repeat: false,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/logo_pilar.png',
              width: 90,
              height: 90,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.shield_rounded, color: Color(0xFF2878D7), size: 64),
            ),
          ),
        ),
      ),
    );
  }
}

