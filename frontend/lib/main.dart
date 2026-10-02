import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'models/user_model.dart';
import 'screens/splash/splash_page.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/local_cache_service.dart';
import 'services/offline_sync_service.dart';
import 'services/secure_credential_service.dart';
import 'utils/app_colors.dart';
import 'utils/page_transitions.dart';

class LocalDevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (
        X509Certificate cert,
        String host,
        int port,
      ) => true;
  }
}

/// ScrollBehavior default yang menonaktifkan efek stretch / overscroll indicator
/// dan menggunakan ClampingScrollPhysics secara konsisten di seluruh aplikasi.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = LocalDevHttpOverrides();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  await initializeDateFormatting('id_ID', null);
  await LocalCacheService.init();
  await OfflineSyncService().init();

  // Restore Sanctum auth token & user session if available
  try {
    await SecureCredentialService.cleanupLegacyCredentials();
    final token = await SecureCredentialService.getAuthToken();
    if (token != null && token.isNotEmpty) {
      ApiService.setAuthToken(token);
    }
    final userData = await SecureCredentialService.getUserData();
    if (userData != null && userData.isNotEmpty) {
      final decoded = jsonDecode(userData);
      if (decoded is Map<String, dynamic>) {
        AuthService.currentUser = UserModel.fromJson(decoded);
      }
    }
  } catch (_) {}

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'BANDELL Mobile',
          debugShowCheckedModeBanner: false,
          scrollBehavior: const AppScrollBehavior(),
          theme: ThemeData(
            useMaterial3: true,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FastPageTransitionsBuilder(),
                TargetPlatform.iOS: FastPageTransitionsBuilder(),
                TargetPlatform.windows: FastPageTransitionsBuilder(),
              },
            ),
          ),
          builder: (context, child) {
            return SkeletonizerConfig(
              data: SkeletonizerConfigData(
                containersColor: AppColors.skeletonContainer,
                effectResolver: (brightness) => const ShimmerEffect(
                  baseColor: AppColors.skeletonBase,
                  highlightColor: AppColors.skeletonHighlight,
                ),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const SplashPage(),
        );
      },
    );
  }
}
