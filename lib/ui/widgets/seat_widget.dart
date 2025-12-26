import 'package:flutter/material.dart';
import '../styles/colors.dart' as app_colors;

/// Premium seat widget with animations and luxury styling
class SeatWidget extends StatefulWidget {
  final String code;
  final bool taken;
  final bool selected;
  final bool isVIP;
  final VoidCallback? onTap;

  const SeatWidget({
    super.key,
    required this.code,
    this.taken = false,
    this.selected = false,
    this.isVIP = false,
    this.onTap,
  });

  @override
  State<SeatWidget> createState() => _SeatWidgetState();
}

class _SeatWidgetState extends State<SeatWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    if (widget.taken) {
      return app_colors.accentRed.withValues(alpha: 0.6);
    } else if (widget.selected) {
      return app_colors.primary;
    } else if (widget.isVIP) {
      return app_colors.accentChampagne.withValues(alpha: 0.3);
    } else {
      return app_colors.surface;
    }
  }

  Color get _borderColor {
    if (widget.taken) {
      return app_colors.accentRed;
    } else if (widget.selected) {
      return app_colors.primaryLight;
    } else if (widget.isVIP) {
      return app_colors.accentChampagne;
    } else {
      return app_colors.glassBorder;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.taken
          ? null
          : (_) {
              _controller.forward();
            },
      onTapUp: widget.taken
          ? null
          : (_) {
              _controller.reverse();
              widget.onTap?.call();
            },
      onTapCancel: widget.taken
          ? null
          : () {
              _controller.reverse();
            },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _borderColor,
                  width: widget.selected ? 2 : 1,
                ),
                boxShadow: widget.selected
                    ? [
                        BoxShadow(
                          color: app_colors.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: widget.taken
                  ? Center(
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: app_colors.accentRed,
                      ),
                    )
                  : widget.isVIP && !widget.selected
                      ? Center(
                          child: Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: app_colors.accentChampagne,
                          ),
                        )
                      : null,
            ),
          );
        },
      ),
    );
  }
}

/// Legend item for seat types
class SeatLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool hasBorder;
  final Color? borderColor;
  final IconData? icon;

  const SeatLegendItem({
    super.key,
    required this.color,
    required this.label,
    this.hasBorder = false,
    this.borderColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
            border: hasBorder
                ? Border.all(color: borderColor ?? app_colors.glassBorder)
                : null,
          ),
          child: icon != null
              ? Center(
                  child: Icon(icon, size: 10, color: borderColor),
                )
              : null,
        ),
        const SizedBox(width: 6),
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
