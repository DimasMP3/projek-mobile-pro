import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../styles/colors.dart' as app_colors;
import '../widgets/glass_container.dart';
import '../../utils/format_currency.dart';

class PaymentSuccessPage extends StatefulWidget {
  const PaymentSuccessPage({super.key});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final map = (args is Map) ? Map<String, dynamic>.from(args) : <String, dynamic>{};
    
    final status = map['status'] as String? ?? 'success';
    final orderId = map['orderId'] as String? ?? '-';
    final movieTitle = map['movieTitle'] as String? ?? 'Unknown Movie';
    final cinema = map['cinema'] as String? ?? 'Unknown Cinema';
    final seats = (map['seats'] as List?)?.cast<String>() ?? <String>[];
    final total = map['total'] as int? ?? 0;

    final isSuccess = status == 'success';

    return Scaffold(
      backgroundColor: app_colors.bg,
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 1.2,
                  colors: [
                    (isSuccess ? app_colors.accentGreen : Colors.red).withValues(alpha: 0.1),
                    app_colors.bg,
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),

                  // Success/Failed Icon
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isSuccess
                              ? [app_colors.accentGreen, app_colors.accentGreen.withValues(alpha: 0.7)]
                              : [Colors.red, Colors.red.withValues(alpha: 0.7)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isSuccess ? app_colors.accentGreen : Colors.red).withValues(alpha: 0.4),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        isSuccess ? Icons.check_rounded : Icons.close_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          isSuccess ? 'Pembayaran Berhasil!' : 'Pembayaran Gagal',
                          style: TextStyle(
                            color: app_colors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isSuccess
                              ? 'Tiket Anda sudah siap'
                              : 'Silakan coba lagi atau hubungi customer service',
                          style: TextStyle(
                            color: app_colors.textSecondary,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // E-Ticket Card (only for success)
                  if (isSuccess)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _ETicketCard(
                        orderId: orderId,
                        movieTitle: movieTitle,
                        cinema: cinema,
                        seats: seats,
                        total: total,
                      ),
                    ),

                  const Spacer(),

                  // Buttons
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        if (isSuccess) ...[
                          // View Tickets Button
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.ticket,
                                (route) => false,
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [app_colors.primary, app_colors.primaryDark],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: app_colors.primary.withValues(alpha: 0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.confirmation_number_rounded, color: Colors.white),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Lihat Tiket Saya',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        // Back to Home
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.home,
                              (route) => false,
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: app_colors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: app_colors.glassBorder),
                            ),
                            child: Center(
                              child: Text(
                                isSuccess ? 'Kembali ke Beranda' : 'Coba Lagi',
                                style: TextStyle(
                                  color: app_colors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// E-TICKET CARD
// ============================================================================

class _ETicketCard extends StatelessWidget {
  final String orderId;
  final String movieTitle;
  final String cinema;
  final List<String> seats;
  final int total;

  const _ETicketCard({
    required this.orderId,
    required this.movieTitle,
    required this.cinema,
    required this.seats,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        children: [
          // QR Code placeholder
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_2_rounded,
                    size: 64,
                    color: app_colors.bg,
                  ),
                  Text(
                    orderId.substring(orderId.length - 6),
                    style: TextStyle(
                      color: app_colors.bg,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Movie title
          Text(
            movieTitle,
            style: TextStyle(
              color: app_colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Cinema & Seats
          Text(
            '$cinema • ${seats.join(", ")}',
            style: TextStyle(
              color: app_colors.textSecondary,
              fontSize: 14,
            ),
          ),

          // Dashed divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: List.generate(
                30,
                (index) => Expanded(
                  child: Container(
                    height: 1,
                    color: index.isEven ? app_colors.glassBorder : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),

          // Order ID & Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ID',
                    style: TextStyle(
                      color: app_colors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    orderId.length > 20 ? '${orderId.substring(0, 20)}...' : orderId,
                    style: TextStyle(
                      color: app_colors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      color: app_colors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    toRupiah(total.toDouble()),
                    style: TextStyle(
                      color: app_colors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
