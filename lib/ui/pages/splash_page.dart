import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../styles/colors.dart' as app_colors;
import '../widgets/animated_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _textController;
  late AnimationController _loadingController;

  late Animation<double> _bgAnimation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _taglineOpacity;
  late Animation<double> _loadingOpacity;

  @override
  void initState() {
    super.initState();

    // Background gradient animation
    _bgController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);
    _bgAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    // Loading animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeIn),
    );

    // Start animations sequence
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _loadingController.forward();
    });

    // Navigate after splash
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_colors.bg,
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _bgAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      0.3 * math.sin(_bgAnimation.value * math.pi),
                      -0.3 + 0.2 * math.cos(_bgAnimation.value * math.pi),
                    ),
                    radius: 1.2,
                    colors: [
                      app_colors.primary.withValues(alpha: 0.08),
                      app_colors.bg,
                    ],
                  ),
                ),
              );
            },
          ),

          // Subtle particle effect overlay
          const _ParticleOverlay(),

          // Main content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Animated Logo
                  const AnimatedLogo(size: 120),

                  const SizedBox(height: 32),

                  // Brand name with animation
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            app_colors.textPrimary,
                            app_colors.primary,
                            app_colors.textPrimary,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ).createShader(bounds),
                        child: const Text(
                          'SanTix',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tagline
                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: Text(
                      'Premium Cinema Experience',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: app_colors.textSecondary,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Loading indicator
                  FadeTransition(
                    opacity: _loadingOpacity,
                    child: const _PremiumLoadingIndicator(),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium loading indicator with golden ring
class _PremiumLoadingIndicator extends StatefulWidget {
  const _PremiumLoadingIndicator();

  @override
  State<_PremiumLoadingIndicator> createState() =>
      _PremiumLoadingIndicatorState();
}

class _PremiumLoadingIndicatorState extends State<_PremiumLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _LoadingRingPainter(
              progress: _controller.value,
              color: app_colors.primary,
            ),
          );
        },
      ),
    );
  }
}

class _LoadingRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LoadingRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Background ring
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          color.withValues(alpha: 0.0),
          color,
          color,
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
        transform: GradientRotation(progress * math.pi * 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 1.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _LoadingRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Subtle floating particle effect
class _ParticleOverlay extends StatefulWidget {
  const _ParticleOverlay();

  @override
  State<_ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<_ParticleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Create random particles
    final random = math.Random();
    _particles = List.generate(20, (index) {
      return _Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 2 + random.nextDouble() * 3,
        speed: 0.2 + random.nextDouble() * 0.5,
        opacity: 0.2 + random.nextDouble() * 0.4,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            color: app_colors.primary,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final y = (particle.y - progress * particle.speed) % 1.0;
      final paint = Paint()
        ..color = color.withValues(alpha: particle.opacity * (1 - y))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(particle.x * size.width, y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
