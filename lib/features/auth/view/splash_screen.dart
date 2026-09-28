import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:bizoop_driver_app/core/app_colors.dart';
import 'package:bizoop_driver_app/features/auth/view/launch_screen.dart';
import 'package:bizoop_driver_app/features/homeScreen/view/dashboard_screen.dart';
import 'package:bizoop_driver_app/features/homeScreen/view/home_screen.dart';

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
  late Future<void> _imagePreload;

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
      duration: const Duration(milliseconds: 1400),
    )..repeat();

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _imagePreload = precacheImage(
      const AssetImage('assets/images/building.webp'),
      context,
    );
  }

  Future<void> _goNext() async {
    if (!mounted) return;

    await Future.wait([
      _imagePreload,
      Future.delayed(const Duration(milliseconds: 2200)),
    ]);
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
                            const AnimatedBizoopText(),
                              const SizedBox(height: 8),
                              SlideTransition(
                                position: _taglineSlide,
                                child: FadeTransition(
                                  opacity: _taglineFade,
                                  child: Text(
                                    "ONE PLATFORM • EVERY BUSINESS NEED",
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
                        child: _OrbitRingLoader(controller: _truckBounceController),
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

class _OrbitRingLoader extends StatelessWidget {
  final AnimationController controller;

  const _OrbitRingLoader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _OrbitRingPainter(t: controller.value),
          );
        },
      ),
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  final double t; // 0..1, loops continuously

  _OrbitRingPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final rotation = t * 2 * math.pi;

    // Faint full track so the ring shape reads even before the arc passes.
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Sweeping gradient arc — the "eye-catching" motion element.
    final rect = Rect.fromCircle(center: center, radius: radius);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        transform: GradientRotation(rotation),
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.9),
        ],
      ).createShader(rect);

    canvas.drawArc(rect, rotation, math.pi * 1.1, false, arcPaint);

    // Lead dot at the head of the arc for a crisp focal point.
    final headAngle = rotation + math.pi * 1.1;
    final headPos = center + Offset(math.cos(headAngle), math.sin(headAngle)) * radius;
    canvas.drawCircle(headPos, 4, Paint()..color = Colors.white);
    canvas.drawCircle(headPos, 8, Paint()..color = Colors.white.withOpacity(0.18));
  }

  @override
  bool shouldRepaint(covariant _OrbitRingPainter oldDelegate) => oldDelegate.t != t;
}

class AnimatedBizoopText extends StatefulWidget {
  const AnimatedBizoopText({super.key});

  @override
  State<AnimatedBizoopText> createState() =>
      _AnimatedBizoopTextState();
}

class _AnimatedBizoopTextState
    extends State<AnimatedBizoopText>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  final String word = "BIZOOP";

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