import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'screens/splash/splash_page.dart';
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
