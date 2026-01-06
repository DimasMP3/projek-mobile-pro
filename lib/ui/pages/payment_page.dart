import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../../data/repositories/movie_repository.dart';
import '../../data/models/movie_model.dart';
import '../../services/payment_service.dart';
import '../../services/session.dart';
import '../../utils/format_currency.dart';
import '../../utils/date_formatter.dart';
import '../styles/colors.dart' as app_colors;
import '../widgets/glass_container.dart';

// Available payment methods
enum PaymentMethod {
  qris('QRIS', Icons.qr_code_2_rounded, ['qris']),
  gopay('GoPay', Icons.account_balance_wallet_rounded, ['gopay']),
  shopeepay('ShopeePay', Icons.shopping_bag_rounded, ['shopeepay']),
  bankTransfer('Bank Transfer', Icons.account_balance_rounded, ['bank_transfer', 'bca_va', 'bni_va', 'bri_va', 'permata_va']),
  creditCard('Kartu Kredit', Icons.credit_card_rounded, ['credit_card']);

  final String label;
  final IconData icon;
  final List<String> midtransPaymentTypes;

  const PaymentMethod(this.label, this.icon, this.midtransPaymentTypes);
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Page state
  bool _isLoading = false;
  bool _isLoadingData = true;
  String? _errorMessage;
  PaymentMethod? _selectedMethod;
  
  // Data from arguments
  String? _movieId;
  int? _showtimeId;
  String? _cinema;
  DateTime? _time;
  List<String> _seats = [];
  
  // Loaded data
  Movie? _movie;
  bool _dataInitialized = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataInitialized) {
      _dataInitialized = true;
      _loadArguments();
      _loadMovieData();
    }
  }

  void _loadArguments() {
    final args = ModalRoute.of(context)?.settings.arguments;
    debugPrint('PaymentPage: Raw arguments = $args');
    
    if (args is Map) {
      final map = Map<String, dynamic>.from(args);
      _movieId = map['movieId']?.toString();
      _showtimeId = map['showtimeId'] as int?;
      _cinema = map['cinema']?.toString();
      _time = map['time'] as DateTime?;
      _seats = (map['seats'] as List?)?.cast<String>() ?? [];
      
      debugPrint('PaymentPage: Parsed - movieId=$_movieId, showtimeId=$_showtimeId, cinema=$_cinema, seats=$_seats');
    } else {
      debugPrint('PaymentPage: Arguments is not a Map!');
    }
  }

  Future<void> _loadMovieData() async {
    debugPrint('PaymentPage: _loadMovieData called with movieId=$_movieId');
    
    if (_movieId == null || _movieId!.isEmpty) {
      debugPrint('PaymentPage: movieId is null or empty!');
      setState(() {
        _isLoadingData = false;
        _errorMessage = 'Data film tidak ditemukan (movieId kosong)';
      });
      return;
    }

    try {
      final repo = MovieRepository();
      debugPrint('PaymentPage: Calling repo.getMovie($_movieId)...');
      final movie = await repo.getMovie(_movieId!);
      debugPrint('PaymentPage: Movie result = ${movie?.title}');
      
      if (mounted) {
        setState(() {
          _movie = movie;
          _isLoadingData = false;
          if (movie == null) {
            _errorMessage = 'Gagal memuat data film (response null)';
          }
        });
      }
    } catch (e, stack) {
      debugPrint('PaymentPage: Error loading movie - $e');
      debugPrint('PaymentPage: Stack trace - $stack');
      if (mounted) {
        setState(() {
          _isLoadingData = false;
          _errorMessage = 'Gagal memuat data: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _selectPaymentMethod(PaymentMethod method) {
    setState(() {
      _selectedMethod = method;
      _errorMessage = null;
    });
  }

  int get _total {
    final price = _movie?.price ?? 0;
    return (price * _seats.length).toInt();
  }

  Future<void> _processPayment(BuildContext context) async {
    // Validate payment method selection
    if (_selectedMethod == null) {
      setState(() {
        _errorMessage = 'Silakan pilih metode pembayaran terlebih dahulu';
      });
      return;
    }

    // Validate required data
    if (_movieId == null || _movieId!.isEmpty) {
      setState(() {
        _errorMessage = 'Data film tidak valid';
      });
      return;
    }

    final movieIdInt = int.tryParse(_movieId!);
    if (movieIdInt == null) {
      setState(() {
        _errorMessage = 'ID film tidak valid';
      });
      return;
    }

    if (_total <= 0) {
      setState(() {
        _errorMessage = 'Total pembayaran tidak valid';
      });
      return;
    }

    if (_seats.isEmpty) {
      setState(() {
        _errorMessage = 'Silakan pilih kursi terlebih dahulu';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final paymentService = PaymentService();
      final response = await paymentService.createPayment(
        movieId: movieIdInt,
        movieTitle: _movie?.title ?? 'Unknown Movie',
        showtimeId: _showtimeId,
        cinema: _cinema ?? 'Unknown Cinema',
        seats: _seats,
        amount: _total,
        customerName: Session.name ?? 'Guest User',
        customerEmail: Session.email ?? 'guest@santix.io',
        enabledPayments: _selectedMethod!.midtransPaymentTypes,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        // Navigate to WebView payment page
        Navigator.pushNamed(
          context,
          AppRoutes.paymentWebview,
          arguments: {
            'orderId': response.orderId,
            'redirectUrl': response.redirectUrl,
            'token': response.token,
            'paymentMethod': _selectedMethod!.label,
            'movieId': _movieId,
            'movieTitle': _movie?.title,
            'showtimeId': _showtimeId,
            'cinema': _cinema,
            'time': _time,
            'seats': _seats,
            'total': _total,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memproses pembayaran: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_colors.bg,
      body: Stack(
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
                    child: _isLoadingData
                        ? _buildLoadingState()
                        : ListView(
                            padding: const EdgeInsets.all(20),
                            children: [
                              // Order Summary Card
                              _OrderSummaryCard(
                                movie: _movie,
                                cinema: _cinema,
                                time: _time,
                                seats: _seats,
                                total: _total,
                              ),

                              const SizedBox(height: 20),

                              // Payment Methods Card
                              _PaymentMethodsCard(
                                selectedMethod: _selectedMethod,
                                onMethodSelected: _selectPaymentMethod,
                              ),

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
            child: _buildBottomCTA(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: app_colors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat data...',
            style: TextStyle(
              color: app_colors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
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

  Widget _buildBottomCTA(BuildContext context) {
    final canPay = _selectedMethod != null && !_isLoading && !_isLoadingData && _total > 0;
    
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
                  toRupiah(_total.toDouble()),
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
            onTap: canPay ? () => _processPayment(context) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: canPay
                    ? LinearGradient(colors: [app_colors.primary, app_colors.primaryDark])
                    : null,
                color: canPay ? null : app_colors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: canPay
                    ? [
                        BoxShadow(
                          color: app_colors.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
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
                        Icon(
                          Icons.lock_rounded,
                          color: canPay ? Colors.white : app_colors.textTertiary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedMethod == null ? 'Pilih Metode' : 'Bayar Sekarang',
                          style: TextStyle(
                            color: canPay ? Colors.white : app_colors.textTertiary,
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
  final PaymentMethod? selectedMethod;
  final Function(PaymentMethod) onMethodSelected;

  const _PaymentMethodsCard({
    required this.selectedMethod,
    required this.onMethodSelected,
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
                    selectedMethod == null ? 'Pilih salah satu' : selectedMethod!.label,
                    style: TextStyle(
                      color: selectedMethod == null 
                          ? app_colors.textTertiary 
                          : app_colors.accentGreen,
                      fontSize: 12,
                      fontWeight: selectedMethod == null ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Payment methods list - vertical for better UX
          ...PaymentMethod.values.map((method) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PaymentMethodTile(
              method: method,
              isSelected: selectedMethod == method,
              onTap: () => onMethodSelected(method),
            ),
          )),

          const SizedBox(height: 6),

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

class _PaymentMethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected 
              ? app_colors.primary.withValues(alpha: 0.15)
              : app_colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? app_colors.primary 
                : app_colors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? app_colors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? app_colors.primary : app_colors.textTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 14),
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? app_colors.primary.withValues(alpha: 0.2)
                    : app_colors.glassWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                method.icon,
                color: isSelected ? app_colors.primary : app_colors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            // Label
            Expanded(
              child: Text(
                method.label,
                style: TextStyle(
                  color: isSelected ? app_colors.primary : app_colors.textPrimary,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isSelected ? app_colors.primary : app_colors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
