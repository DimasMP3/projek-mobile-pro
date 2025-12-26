import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../styles/colors.dart' as app_colors;
import '../widgets/premium_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<OnboardingData> _pages = [
    OnboardingData(
      imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?q=80&w=1000&auto=format&fit=crop',
      title: 'Selamat Datang\ndi SanTix',
      subtitle: 'Rasakan kemewahan menonton film\ndengan layanan premier terbaik',
      gradient: [
        const Color(0xFFC5A059),
        const Color(0xFF8B6B3F),
      ],
    ),
    OnboardingData(
      imageUrl: 'https://images.unsplash.com/photo-1513106580091-1d82408b8cd6?q=80&w=1000&auto=format&fit=crop',
      title: 'Pesan Tiket\ndengan Mudah',
      subtitle: 'Pilih film favorit dan jadwal tayang\ndari ribuan bioskop terkemuka',
      gradient: [
        const Color(0xFF2C3E50),
        const Color(0xFF000000),
      ],
    ),
    OnboardingData(
      imageUrl: 'https://images.unsplash.com/photo-1585647347384-2593bc35786b?q=80&w=1000&auto=format&fit=crop',
      title: 'Pilih Kursi\nTerbaik',
      subtitle: 'Rasakan kenyamanan menonton dengan\npilihan kursi premium terbaik kami',
      gradient: [
        const Color(0xFF8E44AD),
        const Color(0xFF000000),
      ],
    ),
    OnboardingData(
      imageUrl: 'https://images.unsplash.com/photo-1594909122845-11baa439b7bf?q=80&w=1000&auto=format&fit=crop',
      title: 'TIX Fun &\nPenawaran Menarik',
      subtitle: 'Dapatkan berbagai promo eksklusif\ndan poin reward untuk setiap transaksi',
      gradient: [
        const Color(0xFFC5A059),
        const Color(0xFF8B6B3F),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToIntro();
    }
  }

  void _goToIntro() {
    Navigator.pushReplacementNamed(context, AppRoutes.intro);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_colors.bg,
      body: Stack(
        children: [
          // Background gradient based on current page
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.5),
                radius: 1.5,
                colors: [
                  _pages[_currentPage].gradient[0].withValues(alpha: 0.15),
                  app_colors.bg,
                ],
              ),
            ),
          ),

          // Page content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _goToIntro,
                        child: Text(
                          'Lewati',
                          style: TextStyle(
                            color: app_colors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      _fadeController.reset();
                      _slideController.reset();
                      _fadeController.forward();
                      _slideController.forward();
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _OnboardingSlide(
                        data: _pages[index],
                        fadeAnimation: _fadeAnimation,
                        slideAnimation: _slideAnimation,
                      );
                    },
                  ),
                ),

                // Bottom section
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                  child: Column(
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => _PageIndicator(
                            isActive: index == _currentPage,
                            color: _pages[_currentPage].gradient[0],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Next/Get Started button
                      PremiumButton(
                        label: _currentPage == _pages.length - 1
                            ? 'Mulai Sekarang'
                            : 'Lanjut',
                        icon: _currentPage == _pages.length - 1
                            ? Icons.arrow_forward_rounded
                            : null,
                        onTap: _nextPage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Onboarding slide widget
class _OnboardingSlide extends StatelessWidget {
  final OnboardingData data;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const _OnboardingSlide({
    required this.data,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Premium Realistic Image
          FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: data.gradient[0].withValues(alpha: 0.1),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      Image.network(
                        data.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: app_colors.surface,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              app_colors.bg.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Title
          FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    app_colors.textPrimary,
                    data.gradient[0],
                  ],
                ).createShader(bounds),
                child: Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Subtitle
          FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: app_colors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

/// Animated icon box with glow effect
class _AnimatedIconBox extends StatefulWidget {
  final IconData icon;
  final List<Color> gradient;

  const _AnimatedIconBox({
    required this.icon,
    required this.gradient,
  });

  @override
  State<_AnimatedIconBox> createState() => _AnimatedIconBoxState();
}

class _AnimatedIconBoxState extends State<_AnimatedIconBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.gradient,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: widget.gradient[0].withValues(alpha: _glowAnimation.value),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: widget.gradient[1].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              size: 64,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

/// Page indicator dot
class _PageIndicator extends StatelessWidget {
  final bool isActive;
  final Color color;

  const _PageIndicator({
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: isActive ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? color : app_colors.glassBorder,
        borderRadius: BorderRadius.circular(10),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
    );
  }
}

/// Data model for onboarding pages
class OnboardingData {
  final String imageUrl;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  OnboardingData({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}
