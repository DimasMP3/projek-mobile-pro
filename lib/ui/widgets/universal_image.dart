import 'package:flutter/material.dart';

class UniversalImage extends StatelessWidget {
  const UniversalImage({
    super.key,
    required this.path,
    this.fit,
    this.errorBuilder,
  });

  final String path;
  final BoxFit? fit;
  final ImageErrorWidgetBuilder? errorBuilder;

  bool get _isNetwork => path.startsWith('http://') || path.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final fallback = errorBuilder ??
        (_, __, ___) => Container(
              color: const Color(0xFF151B2A),
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported, color: Colors.white54),
            );

    if (path.trim().isEmpty) {
      return Container(
        color: const Color(0xFF151B2A),
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported, color: Colors.white54),
      );
    }
    if (_isNetwork) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: fallback,
      );
    }
    return Image.asset(
      path,
      fit: fit,
      errorBuilder: fallback,
    );
  }
}
