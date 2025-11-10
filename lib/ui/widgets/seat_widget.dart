import 'package:flutter/material.dart';
import '../styles/colors.dart';

class SeatWidget extends StatelessWidget {
  final bool taken;
  final bool selected;
  final VoidCallback? onTap;
  const SeatWidget({
    super.key,
    this.taken = false,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (taken)
      bg = accentRed;
    else if (selected)
      bg = primary;
    else
      bg = const Color(0xFF1E2535);

    return GestureDetector(
      onTap: taken ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 28,
        height: 28,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
