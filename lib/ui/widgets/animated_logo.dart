import 'package:flutter/material.dart';
import '../styles/colors.dart' as app_colors;

/// Animated logo widget with floating, glow, and pulse effects
/// Used in splash and intro screens for premium branding
class AnimatedLogo extends StatefulWidget {
  final double size;
  final bool showGlow;
  final bool animate;

  const AnimatedLogo({
    super.key,
    this.size = 120,
    this.showGlow = true,
    this.animate = true,
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _glowController;
  late AnimationController _scaleController;

  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Floating animation (subtle up-down)
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _floatAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Glow pulse animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Scale-in animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    if (widget.animate) {
      _scaleController.forward();
      _floatController.repeat(reverse: true);
      _glowController.repeat(reverse: true);
    } else {
      _scaleController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _glowController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatAnimation,
        _glowAnimation,
        _scaleAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_floatAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.size * 0.25),
                boxShadow: widget.showGlow
                    ? [
                        BoxShadow(
                          color: app_colors.glowGold
                              .withValues(alpha: _glowAnimation.value),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: app_colors.primary
                              .withValues(alpha: _glowAnimation.value * 0.5),
                          blurRadius: 60,
                          spreadRadius: 5,
                        ),
                      ]
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(widget.size * 0.25),
                  border: Border.all(
                    color: app_colors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.size * 0.25),
                  child: Padding(
                    padding: EdgeInsets.all(widget.size * 0.15),
                    child: Image.asset(
                      'assets/images/logo-santix.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
