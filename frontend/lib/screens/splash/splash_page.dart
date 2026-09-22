import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_colors.dart';
import '../../utils/page_transitions.dart';
import '../login/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Durasi total 7.2 detik: memberikan waktu untuk gerakan organik, jeda alami, dan interaksi yang tenang
  static const int _totalDurationMs = 7200;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalDurationMs),
    );

    _controller.forward();
    _startNavigationTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startNavigationTimer() async {
    await Future.delayed(const Duration(milliseconds: _totalDurationMs));
    if (!mounted) return;

    AppNavigator.pushReplacement(
      context,
      const LoginPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final shortestSide = media.size.shortestSide;

    // Sizing tipografi proporsional untuk brand "Pilar"
    final fontSize = (shortestSide * 0.115).clamp(42.0, 50.0);

    // Style typography KONSISTEN 100% untuk SEMUA huruf (P, i, l, a, r)
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      color: const Color(0xFFF1F5F9),
      letterSpacing: 0.5,
      shadows: const [
        Shadow(
          color: Colors.black45,
          offset: Offset(0, 2.5),
          blurRadius: 5,
        ),
      ],
    );

    // Pengukuran metrik teks presisi
    final scale = fontSize / 46.0;
    final pilaPainter = TextPainter(
      text: TextSpan(text: 'Pila', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final rPainter = TextPainter(
      text: TextSpan(text: 'r', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final baseline = pilaPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    final pilaWidth = pilaPainter.width;
    final rWidth = rPainter.width;
    final textHeight = pilaPainter.height;

    // UKURAN PJU DIPERBESAR SIGNIFIKAN (~1.65x tinggi tulisan "Pilar")
    final pjuHeight = fontSize * 1.65;
    final pjuWidth = fontSize * 0.92;

    // POSISI TARGET AKHIR PJU: Digeser lebih ke kanan (+5px) agar tidak mepet dengan huruf 'a'
    const double rKerning = 6.0;
    final targetX = pilaWidth + rKerning;
    final targetY = baseline - pjuHeight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF071220),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF071220),
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;

            // SCENE 1: Background & "Pilar" muncul LENGKAP & NORMAL (0.00 - 0.32 = 0.0s - 2.3s)
            // 0.0s - 0.8s: Background fade-in
            final bgFade = (t / 0.111).clamp(0.0, 1.0);

            // 0.8s - 1.8s: Tulisan "Pilar" muncul lengkap (P, i, l, a, r identik dan rapi)
            final textP = ((t - 0.111) / 0.139).clamp(0.0, 1.0);
            final textEase = Curves.easeOutCubic.transform(textP);
            final wordOpacity = textEase;
            final wordOffsetY = (1.0 - textEase) * 16.0;

            // Reaksi fisik huruf "r" (tetap normal sampai interaksi di t >= 0.653 = 4.7s)
            final rState = _calculateRLetterState(t);

            // Pergerakan alami & luwes PJU (arc organik, jarak tidak kejauhan, pause, satu interaksi, settle)
            final pjuMotion = _calculatePjuKinematics(
              t: t,
              targetX: targetX,
              targetY: targetY,
            );

            // SCENE 7: Lampu PJU menyala perlahan setelah settle (t: 0.889 - 0.958 = 6.4s - 6.9s)
            double lampProgress = 0.0;
            if (t >= 0.889) {
              final rawLamp = ((t - 0.889) / 0.069).clamp(0.0, 1.0);
              lampProgress = Curves.easeInOutCubic.transform(rawLamp);
            }

            // SCENE 8: Subtitle muncul & final hold (t: 0.910 - 1.000 = 6.5s - 7.2s)
            final subP = ((t - 0.910) / 0.070).clamp(0.0, 1.0);
            final subOpacity = Curves.easeOut.transform(subP);

            return Opacity(
              opacity: bgFade,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.06),
                    radius: 1.30,
                    colors: [
                      Color(0xFF0D223B), // Biru malam pusat pendaran
                      Color(0xFF081729),
                      Color(0xFF050D17), // Vignette bersih & pekat
                    ],
                    stops: [0.0, 0.52, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- ARENA UTAMA: "Pilar" + INTERAKSI PJU ALAMI ---
                        SizedBox(
                          width: pilaWidth + rWidth + 40.0,
                          height: textHeight + 20.0,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Pendaran cahaya hangat saat lampu PJU menyala
                              if (lampProgress > 0)
                                Positioned(
                                  left: targetX - (fontSize * 1.6),
                                  top: targetY - 20,
                                  child: Opacity(
                                    opacity: lampProgress,
                                    child: Container(
                                      width: fontSize * 3.8,
                                      height: fontSize * 2.5,
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          center: const Alignment(0.40, -0.30),
                                          radius: 0.85,
                                          colors: [
                                            const Color(0xFFFDE68A).withValues(alpha: 0.28),
                                            const Color(0xFFF59E0B).withValues(alpha: 0.10),
                                            Colors.transparent,
                                          ],
                                          stops: const [0.0, 0.45, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              // TULISAN "Pilar" LENGKAP & KONSISTEN DI AWAL
                              // Menggunakan satu baris yang sama dengan TextBaseline.alphabetic
                              Positioned(
                                left: 0,
                                top: 10 + wordOffsetY,
                                child: Opacity(
                                  opacity: wordOpacity,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text('P', style: _getLetterStyle(textStyle, lampProgress * 0.15)),
                                      Text('i', style: _getLetterStyle(textStyle, lampProgress * 0.30)),
                                      Text('l', style: _getLetterStyle(textStyle, lampProgress * 0.55)),
                                      Text('a', style: _getLetterStyle(textStyle, lampProgress * 0.85)),

                                      // Jeda spasi natural agar 'r' dan PJU geser pas ke kanan (+5px)
                                      const SizedBox(width: rKerning),

                                      // Huruf "r" kecil: 100% sama persis di awal, baru bergerak saat interaksi (t >= 0.653)
                                      Transform.translate(
                                        offset: Offset(rState.xOffset, rState.yOffset),
                                        child: Transform.scale(
                                          scaleX: rState.squashX,
                                          scaleY: rState.squashY,
                                          alignment: Alignment.bottomCenter,
                                          child: Opacity(
                                            opacity: rState.opacity,
                                            child: Text('r', style: textStyle),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // BAYANGAN LANTAI DINAMIS TIANG PJU
                              if (pjuMotion.opacity > 0)
                                Positioned(
                                  left: pjuMotion.x + (pjuWidth * 0.08) - ((pjuWidth * 0.75 * pjuMotion.shadowScale) / 2),
                                  top: 10 + pjuMotion.groundY + pjuHeight - 2,
                                  child: Opacity(
                                    opacity: pjuMotion.shadowOpacity,
                                    child: Container(
                                      width: pjuWidth * 0.75 * pjuMotion.shadowScale,
                                      height: 4.5,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.75),
                                        borderRadius: BorderRadius.circular(3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.50),
                                            blurRadius: 7 * pjuMotion.shadowScale,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              // KARAKTER UTAMA: TIANG PJU BESAR & REALISTIS
                              if (pjuMotion.opacity > 0)
                                Positioned(
                                  left: pjuMotion.x,
                                  top: 10 + pjuMotion.y,
                                  child: Opacity(
                                    opacity: pjuMotion.opacity,
                                    child: Transform.rotate(
                                      angle: pjuMotion.tilt,
                                      alignment: Alignment.bottomLeft,
                                      child: Transform.scale(
                                        scaleX: pjuMotion.squashX,
                                        scaleY: pjuMotion.squashY,
                                        alignment: Alignment.bottomLeft,
                                        child: CustomPaint(
                                          size: Size(pjuWidth, pjuHeight),
                                          painter: _RealisticPjuStreetlightPainter(
                                            lampProgress: lampProgress,
                                            scale: scale,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // --- SUBTITLE RESMI & MINIMALIS ---
                        Opacity(
                          opacity: subOpacity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SISTEM PENERANGAN JALAN UMUM',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: (fontSize * 0.22).clamp(10.5, 12.5),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 28,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ],
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
    );
  }

  TextStyle _getLetterStyle(TextStyle base, double illumination) {
    if (illumination <= 0) return base;

    final illuminatedColor = Color.lerp(
      base.color,
      const Color(0xFFFEF3C7),
      illumination,
    )!;

    return base.copyWith(
      color: illuminatedColor,
      shadows: [
        ...?base.shadows,
        Shadow(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35 * illumination),
          offset: const Offset(-1, 0),
          blurRadius: 8 * illumination,
        ),
      ],
    );
  }

  /// Menghitung reaksi fisik huruf "r" asli:
  /// Normal di awal -> disentuh sekali di t=0.653 -> terdorong sedikit -> meluncur keluar secara halus
  _RState _calculateRLetterState(double t) {
    // 1. Awal (0.00 - 0.653 = 0.0s - 4.7s): "r" tenang, normal, tidak bergerak sama sekali
    if (t < 0.653) {
      return _RState(
        xOffset: 0.0,
        yOffset: 0.0,
        squashX: 1.0,
        squashY: 1.0,
        opacity: 1.0,
      );
    }

    // 2. Interaksi Utama (0.653 - 0.736 = 4.7s - 5.3s): PJU melompat menyentuh "r" -> terdorong sedikit (+5px) & squash halus
    if (t < 0.736) {
      final p = (t - 0.653) / 0.083;
      final touchP = (p < 0.50) ? (p / 0.50) : 1.0;
      final squash = (p >= 0.50) ? math.sin((p - 0.50) / 0.50 * math.pi) : 0.0;
      return _RState(
        xOffset: 5.0 * Curves.easeOut.transform(touchP),
        yOffset: 1.0 * squash,
        squashX: 1.0 + (0.08 * squash),
        squashY: 1.0 - (0.10 * squash),
        opacity: 1.0,
      );
    }

    // 3. Huruf "r" terdorong keluar secara halus (0.736 - 0.819 = 5.3s - 5.9s, transisi ~0.6 detik)
    if (t < 0.819) {
      final p = (t - 0.736) / 0.083;
      final slide = Curves.easeInOutCubic.transform(p);
      return _RState(
        xOffset: 5.0 + (28.0 * slide),
        yOffset: 5.0 * slide,
        squashX: 1.0,
        squashY: 1.0,
        opacity: (1.0 - slide).clamp(0.0, 1.0),
      );
    }

    // 4. Huruf "r" sudah sepenuhnya tergantikan oleh tiang PJU
    return _RState(
      xOffset: 33.0,
      yOffset: 5.0,
      squashX: 1.0,
      squashY: 1.0,
      opacity: 0.0,
    );
  }

  /// Menghitung kinematika pergerakan PJU:
  /// Masuk dekat dari kiri (jarak tidak kejauhan) -> Arc kurva luwes di atas logo -> Landing dekat di kanan -> Pause -> Dekati r -> Satu interaksi halus -> Ambil posisi r (geser ke kanan) -> Settle
  _PjuState _calculatePjuKinematics({
    required double t,
    required double targetX,
    required double targetY,
  }) {
    // JARAK LOMPATAN DI-PENDEKKAN & LEBIH INTIM DENGAN LOGO:
    // Tidak melompat dari luar layar kejauhan, melainkan melompat luwes di area logo
    final pEntryStart = Offset(targetX - 88, targetY + 6);   // Di samping kiri huruf 'P'
    final pRightLanding = Offset(targetX + 36, targetY);    // Mendarat dekat di sisi kanan logo
    final pBesideR = Offset(targetX + 14, targetY);         // Di dekat samping huruf 'r'
    final pFinal = Offset(targetX, targetY);                // Posisi akhir pengganti huruf 'r' (geser pas ke kanan)

    // 1. Sebelum masuk (0.00 - 0.319 = 0.0s - 2.3s): PJU belum tampil
    if (t < 0.319) {
      return _PjuState(
        x: pEntryStart.dx,
        y: pEntryStart.dy,
        groundY: pEntryStart.dy,
        squashX: 1.0,
        squashY: 1.0,
        tilt: 0.0,
        shadowScale: 0.0,
        shadowOpacity: 0.0,
        opacity: 0.0,
      );
    }

    // 2. SCENE 3: SATU GERAKAN ARC KURVA LUWES & TIDAK KEJAUHAN (0.319 - 0.514 = 2.3s - 3.7s)
    // Melompat luwes melewati bagian atas tulisan "Pilar" -> mendarat di sisi kanan logo
    if (t < 0.514) {
      final p = (t - 0.319) / 0.195;

      // Trajektori melayang di udara (0.00 - 0.85)
      if (p < 0.85) {
        final airP = p / 0.85;

        // Menggunakan kurva easeInOutSine untuk pergerakan X yang luwes dan tidak kaku
        final smoothX = Curves.easeInOutSine.transform(airP);
        final currentX = pEntryStart.dx + (pRightLanding.dx - pEntryStart.dx) * smoothX;

        // Gravitasi busur sinusoidal organik (puncak busur ~34px, proporsional dan tidak berlebihan)
        const peakHeight = 34.0;
        final arc = math.sin(airP * math.pi);
        final currentY = pEntryStart.dy + (pRightLanding.dy - pEntryStart.dy) * airP - (peakHeight * arc);
        final groundY = pEntryStart.dy + (pRightLanding.dy - pEntryStart.dy) * airP;

        // Kemiringan lembut mengikuti kecepatan (luwes, tidak kaku)
        final tilt = math.sin(airP * math.pi) * 0.08;

        // Respon bayangan: mengecil lembut saat di puncak, membesar saat mendekati permukaan
        final shadowShrink = (1.0 - (0.45 * arc)).clamp(0.40, 1.0);
        final shadowFade = (0.75 - (0.30 * arc)).clamp(0.30, 0.75);

        return _PjuState(
          x: currentX,
          y: currentY,
          groundY: groundY,
          squashX: 1.0 - (0.06 * arc),
          squashY: 1.0 + (0.08 * arc),
          tilt: tilt,
          shadowScale: shadowShrink,
          shadowOpacity: shadowFade,
          opacity: (airP * 3.0).clamp(0.0, 1.0),
        );
      }

      // Landing halus di sisi kanan logo (0.85 - 1.00)
      final landP = (p - 0.85) / 0.15;
      final bounce = math.sin(landP * math.pi) * math.exp(-landP * 3.0);
      return _PjuState(
        x: pRightLanding.dx,
        y: pRightLanding.dy + (1.6 * bounce),
        groundY: pRightLanding.dy,
        squashX: 1.0 + (0.08 * bounce),
        squashY: 1.0 - (0.08 * bounce),
        tilt: 0.0,
        shadowScale: 1.0 + (0.12 * bounce),
        shadowOpacity: 0.75 + (0.12 * bounce),
        opacity: 1.0,
      );
    }

    // 3. SCENE 4A: PAUSE DI SISI KANAN LOGO (0.514 - 0.583 = 3.7s - 4.2s, ~0.5 detik berhenti santai)
    if (t < 0.583) {
      final pauseP = (t - 0.514) / 0.069;
      final curious = math.sin(pauseP * math.pi) * -0.03;
      return _PjuState(
        x: pRightLanding.dx,
        y: pRightLanding.dy,
        groundY: pRightLanding.dy,
        squashX: 1.0,
        squashY: 1.0,
        tilt: curious,
        shadowScale: 1.0,
        shadowOpacity: 0.75,
        opacity: 1.0,
      );
    }

    // 4. SCENE 4B: MENDEKATI HURUF "r" SECARA SANTAI (0.583 - 0.653 = 4.2s - 4.7s)
    if (t < 0.653) {
      final stepP = Curves.easeInOutCubic.transform((t - 0.583) / 0.070);
      final currentX = pRightLanding.dx + (pBesideR.dx - pRightLanding.dx) * stepP;
      final hopY = math.sin(stepP * math.pi) * 6.0;

      return _PjuState(
        x: currentX,
        y: pBesideR.dy - hopY,
        groundY: pBesideR.dy,
        squashX: 1.0,
        squashY: 1.0,
        tilt: -0.02 * math.sin(stepP * math.pi),
        shadowScale: (1.0 - 0.15 * (hopY / 6.0)).clamp(0.7, 1.0),
        shadowOpacity: (0.75 - 0.12 * (hopY / 6.0)).clamp(0.45, 0.75),
        opacity: 1.0,
      );
    }

    // 5. SCENE 5: SATU INTERAKSI PENDEK DENGAN HURUF "r" (0.653 - 0.736 = 4.7s - 5.3s)
    // Lompatan sangat dekat menyentuh "r" -> terdorong sedikit -> PJU bounce kecil
    if (t < 0.736) {
      final p = (t - 0.653) / 0.083;

      // Lompatan pendek ke arah 'r' (0.00 - 0.55)
      if (p < 0.55) {
        final airP = p / 0.55;
        final arc = math.sin(airP * math.pi);
        final currentX = pBesideR.dx + ((targetX + 3.0) - pBesideR.dx) * airP;
        final currentY = targetY - (12.0 * arc);

        return _PjuState(
          x: currentX,
          y: currentY,
          groundY: targetY,
          squashX: 1.0 - (0.05 * arc),
          squashY: 1.0 + (0.06 * arc),
          tilt: -0.04 * (1.0 - airP),
          shadowScale: (1.0 - 0.25 * arc).clamp(0.6, 1.0),
          shadowOpacity: (0.75 - 0.15 * arc).clamp(0.4, 0.75),
          opacity: 1.0,
        );
      }

      // Impact menyentuh 'r' & bounce kecil (0.55 - 1.00)
      final bounceP = (p - 0.55) / 0.45;
      final bounce = math.sin(bounceP * math.pi) * math.exp(-bounceP * 2.8);
      return _PjuState(
        x: targetX + 3.0,
        y: targetY + (1.2 * bounce),
        groundY: targetY,
        squashX: 1.0 + (0.06 * bounce),
        squashY: 1.0 - (0.06 * bounce),
        tilt: 0.0,
        shadowScale: 1.0 + (0.10 * bounce),
        shadowOpacity: 0.75 + (0.08 * bounce),
        opacity: 1.0,
      );
    }

    // 6. SCENE 6: PJU MENGAMBIL POSISI FINAL HURUF "r" (0.736 - 0.819 = 5.3s - 5.9s)
    // PJU melangkah tepat ke posisi baseline 'r' (geser pas ke kanan)
    if (t < 0.819) {
      final pjuSlide = Curves.easeOutCubic.transform((t - 0.736) / 0.083);
      final currentX = (targetX + 3.0) + (targetX - (targetX + 3.0)) * pjuSlide;

      return _PjuState(
        x: currentX,
        y: targetY,
        groundY: targetY,
        squashX: 1.0,
        squashY: 1.0,
        tilt: 0.0,
        shadowScale: 1.0,
        shadowOpacity: 0.75,
        opacity: 1.0,
      );
    }

    // 7. SCENE 6B: PJU SETTLE TEGAK SEMPURNA (0.819 - 0.889 = 5.9s - 6.4s)
    double settleSquashY = 1.0;
    double settleSquashX = 1.0;
    if (t < 0.889) {
      final sP = (t - 0.819) / 0.070;
      final oscillation = math.sin(sP * math.pi * 3) * math.exp(-sP * 4.0);
      settleSquashY = 1.0 + (0.05 * oscillation);
      settleSquashX = 1.0 - (0.04 * oscillation);
    }

    return _PjuState(
      x: pFinal.dx,
      y: pFinal.dy,
      groundY: pFinal.dy,
      squashX: settleSquashX,
      squashY: settleSquashY,
      tilt: 0.0,
      shadowScale: 1.0,
      shadowOpacity: 0.75,
      opacity: 1.0,
    );
  }
}

/// Data state pergerakan PJU
class _PjuState {
  final double x;
  final double y;
  final double groundY;
  final double squashX;
  final double squashY;
  final double tilt;
  final double shadowScale;
  final double shadowOpacity;
  final double opacity;

  _PjuState({
    required this.x,
    required this.y,
    required this.groundY,
    required this.squashX,
    required this.squashY,
    required this.tilt,
    required this.shadowScale,
    required this.shadowOpacity,
    required this.opacity,
  });
}

/// Data state reaksi fisik huruf "r" asli
class _RState {
  final double xOffset;
  final double yOffset;
  final double squashX;
  final double squashY;
  final double opacity;

  _RState({
    required this.xOffset,
    required this.yOffset,
    required this.squashX,
    required this.squashY,
    required this.opacity,
  });
}

/// CustomPainter untuk menggambar Tiang PJU berukuran besar (~1.65x tinggi tulisan "Pilar")
/// yang realistis, ramping, modern, dan melengkapi kata "Pila" menjadi "Pilar"
class _RealisticPjuStreetlightPainter extends CustomPainter {
  final double lampProgress;
  final double scale;

  _RealisticPjuStreetlightPainter({
    required this.lampProgress,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Base Plate Dudukan Tiang (Flange dudukan baut di baseline)
    final basePaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.03, h - 3.5, w * 0.38, 3.5),
        const Radius.circular(1.2),
      ),
      basePaint,
    );

    // 2. Batang Tiang Baja Vertikal (Tiang utama di sisi kiri)
    final mastPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF8FAFC), Color(0xFF94A3B8), Color(0xFF475569)],
        stops: [0.0, 0.50, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w * 0.32, h))
      ..style = PaintingStyle.fill;

    final mastPath = Path();
    final mastLeft = w * 0.08;
    final mastRight = w * 0.22;

    mastPath.moveTo(mastLeft, h - 3.0);
    mastPath.lineTo(mastRight, h - 3.0);
    mastPath.lineTo(mastRight, h * 0.26);
    mastPath.lineTo(mastLeft, h * 0.26);
    mastPath.close();
    canvas.drawPath(mastPath, mastPaint);

    // 3. Lengan Kantilever Melengkung PJU (Membentuk busur atas huruf 'r')
    final armPath = Path();
    armPath.moveTo(mastLeft + 1.5, h * 0.30);
    armPath.cubicTo(
      mastLeft + 1.5, h * 0.02,   // Melengkung anggun ke atas
      w * 0.84, h * 0.02,          // Menuju sisi kanan membentuk busur khas 'r'
      w * 0.88, h * 0.35,          // Turun menuju dudukan lampu LED
    );

    final armPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.13
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(armPath, armPaint);

    // 4. Rumah Lampu LED PJU (Modern Aerodynamic Luminaire / Cobra Head)
    final luminaireX = w * 0.84;
    final luminaireY = h * 0.35;

    final headPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(luminaireX, luminaireY),
          width: w * 0.34,
          height: h * 0.13,
        ),
        const Radius.circular(2.5),
      ),
      headPaint,
    );

    // 5. Emisi Cahaya LED PJU (Warm lighting lembut di akhir animasi)
    if (lampProgress > 0) {
      // Inti LED
      final ledPaint = Paint()
        ..color = Color.lerp(
          const Color(0xFFFEF3C7),
          Colors.white,
          lampProgress,
        )!
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(luminaireX, luminaireY + 1.5), 2.5, ledPaint);

      // Glow radial lembut
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFDE68A).withValues(alpha: 0.85 * lampProgress),
            const Color(0xFFF59E0B).withValues(alpha: 0.35 * lampProgress),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(luminaireX, luminaireY + 1.5),
            radius: 18 * lampProgress,
          ),
        );
      canvas.drawCircle(
        Offset(luminaireX, luminaireY + 1.5),
        18 * lampProgress,
        glowPaint,
      );

      // Sorotan kerucut lembut ke bawah (Soft downward light cone)
      final conePath = Path();
      conePath.moveTo(luminaireX - 3.5, luminaireY + 3.0);
      conePath.lineTo(luminaireX + 3.5, luminaireY + 3.0);
      conePath.lineTo(w * 1.25, h + 10);
      conePath.lineTo(w * 0.05, h + 10);
      conePath.close();

      final conePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFDE68A).withValues(alpha: 0.35 * lampProgress),
            const Color(0xFFF59E0B).withValues(alpha: 0.10 * lampProgress),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(conePath.getBounds());
      canvas.drawPath(conePath, conePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RealisticPjuStreetlightPainter oldDelegate) {
    return oldDelegate.lampProgress != lampProgress || oldDelegate.scale != scale;
  }
}
