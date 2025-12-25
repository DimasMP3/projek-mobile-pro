import 'package:flutter/material.dart';
import '../styles/colors.dart' as app_colors;

/// Premium button with gradient, glow effects, and smooth animations
/// Supports filled, outline, and glass variants
class PremiumButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool outline;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const PremiumButton({
    super.key,
    required this.label,
    required this.onTap,
    this.outline = false,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 56,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.width ?? double.infinity,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.outline
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          app_colors.primary,
                          app_colors.primaryDark,
                        ],
                      ),
                color: widget.outline
                    ? (_isPressed
                        ? app_colors.glassWhite
                        : Colors.transparent)
                    : null,
                borderRadius: BorderRadius.circular(16),
                border: widget.outline
                    ? Border.all(
                        color: _isPressed
                            ? app_colors.primary
                            : app_colors.glassBorder,
                        width: 1.5,
                      )
                    : null,
                boxShadow: widget.outline
                    ? null
                    : [
                        BoxShadow(
                          color: app_colors.primary.withValues(
                            alpha: _isPressed ? 0.4 : 0.25,
                          ),
                          blurRadius: _isPressed ? 20 : 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.outline
                                ? app_colors.primary
                                : Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: widget.outline
                                  ? app_colors.textPrimary
                                  : Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: widget.outline
                                  ? app_colors.textPrimary
                                  : Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
