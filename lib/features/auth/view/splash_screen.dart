import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tranzoop_mobile_app/core/app_colors.dart';
import 'package:tranzoop_mobile_app/features/auth/view/launch_screen.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/view/dashboard_screen.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/view/home_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool isLoggedIn;
  const SplashScreen({super.key, required this.isLoggedIn});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _truckBounceController;
  late final AnimationController _roadScrollController;
  late final AnimationController _exitController;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _exitFade;

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    // Brand reveal: logo pops in, tagline + truck follow shortly after.
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _logoScale = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.45, 1.0, curve: Curves.easeIn),
      ),
    );

    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
      ),
    );

    // Gentle suspension bob for the truck.
    _truckBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Continuous dashed-road scroll to suggest forward motion.
    _roadScrollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();

    // Smooth fade-out instead of an abrupt cut before navigating.
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _exitFade = Tween<double>(begin: 1, end: 0).animate(_exitController);

    _entryController.forward();

    // Timer (not Future.delayed) so it can be reliably cancelled in dispose.
    _navTimer = Timer(const Duration(milliseconds: 3200), _goNext);
  }

  Future<void> _goNext() async {
    if (!mounted) return;
    await _exitController.forward();
    if (!mounted) return; // guard context use after the async gap
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) =>
        widget.isLoggedIn
            ? const DashboardScreen()
            : const LaunchScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _entryController.dispose();
    _truckBounceController.dispose();
    _roadScrollController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.btnColor,
      body: FadeTransition(
        opacity: _exitFade,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.btnColor,
                AppColors.btnColor.withOpacity(0.88),
                Colors.black.withOpacity(0.18),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 18),
                            const AnimatedTranzoopText(),
                              const SizedBox(height: 8),
                              SlideTransition(
                                position: _taglineSlide,
                                child: FadeTransition(
                                  opacity: _taglineFade,
                                  child: Text(
                                    "SMART LOGISTICS • TRUSTED DELIVERY",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(.85),
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      FadeTransition(
                        opacity: _taglineFade,
                        child: _TruckLoader(
                          bounceController: _truckBounceController,
                          roadController: _roadScrollController,
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
  }
}

class _TruckLoader extends StatelessWidget {
  final AnimationController bounceController;
  final AnimationController roadController;

  const _TruckLoader({
    required this.bounceController,
    required this.roadController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 48,
      child: AnimatedBuilder(
        animation: Listenable.merge([bounceController, roadController]),
        builder: (context, _) {
          final bob = math.sin(bounceController.value * math.pi) * 3;
          return Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: _DashedLine(scroll: roadController.value),
              ),
              Positioned(
                bottom: 10 + bob,
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  final double scroll; // 0..1

  const _DashedLine({required this.scroll});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashedLinePainter(scroll: scroll),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final double scroll; // 0..1

  _DashedLinePainter({required this.scroll});

  static const double _dashWidth = 8;
  static const double _dashSpace = 6;
  static const double _segment = _dashWidth + _dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round;

    // Shifting by exactly one segment per loop keeps the pattern seamless
    // when `scroll` wraps back from 1 to 0.
    final shift = scroll * _segment;
    var x = -_segment + shift;
    final y = size.height / 2;

    while (x < size.width) {
      final start = x.clamp(0.0, size.width);
      final end = (x + _dashWidth).clamp(0.0, size.width);
      if (end > start) {
        canvas.drawLine(Offset(start, y), Offset(end, y), paint);
      }
      x += _segment;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.scroll != scroll;
}

class AnimatedTranzoopText extends StatefulWidget {
  const AnimatedTranzoopText({super.key});

  @override
  State<AnimatedTranzoopText> createState() =>
      _AnimatedTranzoopTextState();
}

class _AnimatedTranzoopTextState
    extends State<AnimatedTranzoopText>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  final String word = "TRANZOOP";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final center = (word.length - 1) / 2;

    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(word.length, (index) {

          double startOffset =
              (index - center) * 25;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {

              final progress =
              Curves.easeOutCubic.transform(
                  _controller.value);

              return Transform.translate(
                offset: Offset(
                  startOffset * (1 - progress),
                  0,
                ),
                child: Opacity(
                  opacity: progress,
                  child: Text(
                    word[index],
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}