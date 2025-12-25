import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../styles/colors.dart' as app_colors;
import '../widgets/animated_logo.dart';
import '../widgets/premium_button.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonsFade;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _buttonsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_colors.bg,
      body: Stack(
        children: [
          // Background with cinema image
          Positioned.fill(
            child: Image.asset(
              'assets/images/cinema-bgk.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // Gradient overlay - premium dark fade
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.3, 0.6, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.5),
                    app_colors.bg.withValues(alpha: 0.9),
                    app_colors.bg,
                  ],
                ),
              ),
            ),
          ),

          // Golden accent gradient at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -1),
                  radius: 1.5,
                  colors: [
                    app_colors.primary.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Logo with animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const AnimatedLogo(size: 100),
                  ),

                  const SizedBox(height: 28),

                  // Brand name
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                app_colors.textPrimary,
                                app_colors.primary,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'SanTix',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Pesan tiket bioskop favoritmu\nkapan saja, di mana saja!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: app_colors.textSecondary,
                              height: 1.5,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Feature highlights
                  FadeTransition(
                    opacity: _buttonsFade,
                    child: const _FeatureHighlights(),
                  ),

                  const SizedBox(height: 40),

                  // Buttons with glass effect
                  FadeTransition(
                    opacity: _buttonsFade,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          PremiumButton(
                            label: 'Masuk',
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.login,
                            ),
                          ),
                          const SizedBox(height: 14),
                          PremiumButton(
                            label: 'Daftar Akun Baru',
                            outline: true,
                            onTap: () => Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.register,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Terms text
                  FadeTransition(
                    opacity: _buttonsFade,
                    child: Text(
                      'Dengan melanjutkan, kamu menyetujui\nSyarat & Ketentuan serta Kebijakan Privasi kami',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: app_colors.textTertiary,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Feature highlights row
class _FeatureHighlights extends StatelessWidget {
  const _FeatureHighlights();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: app_colors.glassWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: app_colors.glassBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _FeatureItem(
                icon: Icons.confirmation_number_outlined,
                label: 'Tiket Instan',
              ),
              Container(
                width: 1,
                height: 30,
                color: app_colors.glassBorder,
              ),
              _FeatureItem(
                icon: Icons.local_offer_outlined,
                label: 'Promo Eksklusif',
              ),
              Container(
                width: 1,
                height: 30,
                color: app_colors.glassBorder,
              ),
              _FeatureItem(
                icon: Icons.event_seat_outlined,
                label: 'Pilih Kursi',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: app_colors.primary,
          size: 24,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: app_colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
