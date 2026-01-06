import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../../data/repositories/movie_repository.dart';
import '../../data/models/movie_model.dart';
import '../../services/payment_service.dart';
import '../../utils/format_currency.dart';
import '../../utils/date_formatter.dart';
import '../styles/colors.dart' as app_colors;
import '../widgets/glass_container.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _processPayment(BuildContext context, Map<String, dynamic> paymentData) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final paymentService = PaymentService();
      final response = await paymentService.createPayment(
        movieId: int.parse(paymentData['movieId']),
        movieTitle: paymentData['movieTitle'] ?? 'Unknown Movie',
        showtimeId: paymentData['showtimeId'],
        cinema: paymentData['cinema'] ?? 'Unknown Cinema',
        seats: (paymentData['seats'] as List).cast<String>(),
        amount: paymentData['total'] ?? 0,
        customerName: paymentData['customerName'] ?? 'Guest',
        customerEmail: paymentData['customerEmail'] ?? 'guest@santix.io',
      );

      if (mounted) {
        // Navigate to WebView payment page
        Navigator.pushNamed(
          context,
          AppRoutes.paymentWebview,
          arguments: {
            'orderId': response.orderId,
            'redirectUrl': response.redirectUrl,
            'token': response.token,
            ...paymentData,
          },
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final map = (args is Map) ? Map<String, dynamic>.from(args) : <String, dynamic>{};
    final movieId = map['movieId'] as String?;
    final cinema = map['cinema'] as String?;
    final DateTime? time = map['time'] as DateTime?;
    final seats = (map['seats'] as List?)?.cast<String>() ?? <String>[];

    final repo = MovieRepository();

    return Scaffold(
      backgroundColor: app_colors.bg,
      body: FutureBuilder<Movie?>(
        future: movieId != null ? repo.getMovie(movieId) : Future.value(null),
        builder: (context, snap) {
          final movie = snap.data;
          final ticketPrice = movie?.price ?? 50000;
          final total = (ticketPrice * seats.length).toInt();

          // Prepare payment data
          final paymentData = {
            'movieId': movieId,
            'movieTitle': movie?.title ?? 'Unknown Movie',
            'showtimeId': map['showtimeId'],
            'cinema': cinema,
            'time': time,
            'seats': seats,
            'total': total,
            'customerName': 'Guest User', // TODO: Get from Auth0
            'customerEmail': 'guest@santix.io', // TODO: Get from Auth0
          };

          return Stack(
            children: [
              // Background gradient
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

              // Main content
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // App Bar
                      _buildAppBar(context),

                      // Content
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            // Order Summary Card
                            _OrderSummaryCard(
                              movie: movie,
                              cinema: cinema,
                              time: time,
                              seats: seats,
                              total: total,
                            ),

                            const SizedBox(height: 20),

                            // Payment Methods Card
                            _PaymentMethodsCard(),

                            const SizedBox(height: 20),

                            // Error message
                            if (_errorMessage != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(color: Colors.red, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom CTA
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomCTA(context, total, paymentData),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: app_colors.glassWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: app_colors.glassBorder),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: app_colors.textPrimary,
                size: 18,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Pembayaran',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: app_colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBottomCTA(BuildContext context, int total, Map<String, dynamic> paymentData) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: app_colors.bg,
        border: Border(
          top: BorderSide(color: app_colors.glassBorder),
        ),
      ),
      child: Row(
        children: [
          // Total amount
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    color: app_colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  toRupiah(total.toDouble()),
                  style: TextStyle(
                    color: app_colors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // Pay button
          GestureDetector(
            onTap: _isLoading ? null : () => _processPayment(context, paymentData),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Bayar Sekarang',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
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
// ORDER SUMMARY CARD
// ============================================================================

class _OrderSummaryCard extends StatelessWidget {
  final Movie? movie;
  final String? cinema;
  final DateTime? time;
  final List<String> seats;
  final int total;

  const _OrderSummaryCard({
    this.movie,
    this.cinema,
    this.time,
    required this.seats,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: app_colors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: app_colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Ringkasan Pesanan',
                style: TextStyle(
                  color: app_colors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Movie info
          _InfoRow(
            icon: Icons.movie_rounded,
            label: 'Film',
            value: movie?.title ?? '-',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.location_on_rounded,
            label: 'Bioskop',
            value: cinema ?? '-',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: 'Jadwal',
            value: time != null ? formatShowTime(time!) : '-',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.event_seat_rounded,
            label: 'Kursi',
            value: seats.isEmpty ? '-' : seats.join(', '),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    app_colors.glassBorder.withValues(alpha: 0),
                    app_colors.glassBorder,
                    app_colors.glassBorder.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  color: app_colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                toRupiah(total.toDouble()),
                style: TextStyle(
                  color: app_colors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: app_colors.textTertiary, size: 18),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              color: app_colors.textTertiary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: app_colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// PAYMENT METHODS CARD
// ============================================================================

class _PaymentMethodsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: app_colors.accentGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.payment_rounded,
                  color: app_colors.accentGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                      color: app_colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Pilih saat checkout',
                    style: TextStyle(
                      color: app_colors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Payment methods grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _PaymentMethodChip(label: 'QRIS', icon: Icons.qr_code_2_rounded),
              _PaymentMethodChip(label: 'GoPay', icon: Icons.account_balance_wallet_rounded),
              _PaymentMethodChip(label: 'ShopeePay', icon: Icons.shopping_bag_rounded),
              _PaymentMethodChip(label: 'Bank Transfer', icon: Icons.account_balance_rounded),
              _PaymentMethodChip(label: 'Kartu Kredit', icon: Icons.credit_card_rounded),
            ],
          ),

          const SizedBox(height: 16),

          // Security note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: app_colors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: app_colors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_user_rounded, color: app_colors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pembayaran diproses dengan aman oleh Midtrans',
                    style: TextStyle(
                      color: app_colors.textSecondary,
                      fontSize: 12,
                    ),
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

class _PaymentMethodChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _PaymentMethodChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: app_colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: app_colors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: app_colors.textSecondary, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: app_colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
