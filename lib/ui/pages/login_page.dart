import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../../services/auth_service.dart';
import '../styles/colors.dart' as app_colors;
import '../widgets/glass_container.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  bool _isLoading = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final token = await AuthService.loginWithGoogle();
      if (!mounted) return;
      if (token != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: $e'),
          backgroundColor: app_colors.accentRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_colors.bg,
      body: Stack(
        children: [
          // Subtle gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.5),
                  radius: 1.5,
                  colors: [
                    app_colors.primary.withValues(alpha: 0.08),
                    app_colors.bg,
                  ],
                ),
              ),
            ),
          ),

          // Decorative cinema elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    app_colors.primary.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),

                        // Back button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: app_colors.glassWhite,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: app_colors.glassBorder,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: app_colors.textPrimary,
                                size: 18,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Welcome header
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              app_colors.textPrimary,
                              app_colors.primary,
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'Selamat Datang\ndi SanTix',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.2,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Masuk untuk memesan tiket dan nikmati\npromo eksklusif untuk member!',
                          style: TextStyle(
                            fontSize: 14,
                            color: app_colors.textSecondary,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Cinema illustration card
                        GlassContainer(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      app_colors.primary.withValues(alpha: 0.3),
                                      app_colors.primaryDark
                                          .withValues(alpha: 0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        app_colors.primary.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Icon(
                                  Icons.movie_filter_rounded,
                                  color: app_colors.primary,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Premium Cinema Experience',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: app_colors.textPrimary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Nikmati pengalaman menonton terbaik\ndengan kemudahan booking dalam genggaman',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: app_colors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Google login button
                        _GoogleLoginButton(
                          onTap: _handleGoogleLogin,
                          isLoading: _isLoading,
                        ),

                        const SizedBox(height: 24),

                        // Divider with text
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: app_colors.glassBorder,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'atau',
                                style: TextStyle(
                                  color: app_colors.textTertiary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: app_colors.glassBorder,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Register link
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.register,
                            ),
                            child: RichText(
                              text: TextSpan(
                                text: 'Belum punya akun? ',
                                style: TextStyle(
                                  color: app_colors.textSecondary,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Daftar Sekarang',
                                    style: TextStyle(
                                      color: app_colors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Terms
                        Text(
                          'Dengan masuk, kamu menyetujui Kebijakan Privasi\ndan Ketentuan Layanan kami.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: app_colors.textTertiary,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium Google login button
class _GoogleLoginButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const _GoogleLoginButton({
    required this.onTap,
    this.isLoading = false,
  });

  @override
  State<_GoogleLoginButton> createState() => _GoogleLoginButtonState();
}

class _GoogleLoginButtonState extends State<_GoogleLoginButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 56,
        decoration: BoxDecoration(
          color: _isPressed ? app_colors.surfaceLight : app_colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isPressed ? app_colors.primary.withValues(alpha: 0.5) : app_colors.glassBorder,
            width: 1.5,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: app_colors.primary.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: widget.isLoading
            ? Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      app_colors.primary,
                    ),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/icons8-google-logo-color-120.png',
                    height: 24,
                    width: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Lanjutkan dengan Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: app_colors.textPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
