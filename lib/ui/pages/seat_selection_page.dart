import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/seat_widget.dart';
import '../styles/colors.dart' as app_colors;
import '../widgets/premium_button.dart';
import '../widgets/glass_container.dart';
import '../../utils/date_formatter.dart';
import '../../config/app_routes.dart';

class SeatSelectionPage extends StatefulWidget {
  final String movieId;
  final DateTime? time;
  final String? cinema;
  const SeatSelectionPage({
    super.key,
    required this.movieId,
    this.time,
    this.cinema,
  });

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage>
    with TickerProviderStateMixin {
  final selected = <String>{};
  final int ticketPrice = 50000; // Harga per tiket

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // VIP rows (baris depan premium)
  final vipRows = ['A', 'B'];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  int get totalPrice => selected.length * ticketPrice;

  String _formatPrice(int price) {
    return 'Rp ${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    final rows = 'ABCDEFGH'.split('');
    final cols = List.generate(10, (i) => i + 1);

    // Contoh kursi yang sudah terisi
    final takenSeats = {'C5', 'C6', 'D7', 'D8', 'E5', 'F3', 'F4'};

    return Scaffold(
      backgroundColor: app_colors.bg,
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.8),
                  radius: 1.2,
                  colors: [
                    app_colors.primary.withValues(alpha: 0.1),
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
                  // Custom AppBar
                  Padding(
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
                            'Pilih Kursi',
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
                  ),

                  const SizedBox(height: 16),

                  // Cinema & time info
                  if (widget.time != null || widget.cinema != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(14),
                        borderRadius: 14,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: app_colors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.movie_filter_rounded,
                                color: app_colors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.cinema != null)
                                    Text(
                                      widget.cinema!,
                                      style: TextStyle(
                                        color: app_colors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  if (widget.time != null)
                                    Text(
                                      formatShowTime(widget.time!),
                                      style: TextStyle(
                                        color: app_colors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Cinema Screen with glow effect
                  const _CinemaScreen(),

                  const SizedBox(height: 20),

                  // Seat Grid
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          // Row labels and seats
                          ...rows.map((r) {
                            final isVIP = vipRows.contains(r);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Row label
                                  SizedBox(
                                    width: 24,
                                    child: Text(
                                      r,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isVIP
                                            ? app_colors.accentChampagne
                                            : app_colors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),

                                  // Seats with aisle gap
                                  ...cols.map((c) {
                                    final code = '$r$c';
                                    final taken = takenSeats.contains(code);
                                    final isSel = selected.contains(code);

                                    // Add aisle gap after column 5
                                    final hasGap = c == 5;

                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SeatWidget(
                                          code: code,
                                          taken: taken,
                                          selected: isSel,
                                          isVIP: isVIP,
                                          onTap: () {
                                            setState(() {
                                              if (isSel) {
                                                selected.remove(code);
                                              } else {
                                                selected.add(code);
                                              }
                                            });
                                          },
                                        ),
                                        if (hasGap) const SizedBox(width: 16),
                                      ],
                                    );
                                  }),

                                  // Row label (right side)
                                  SizedBox(
                                    width: 24,
                                    child: Text(
                                      r,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isVIP
                                            ? app_colors.accentChampagne
                                            : app_colors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 24),

                          // Legend
                          Wrap(
                            spacing: 20,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [
                              SeatLegendItem(
                                color: app_colors.surface,
                                label: 'Tersedia',
                                hasBorder: true,
                              ),
                              SeatLegendItem(
                                color: app_colors.primary,
                                label: 'Dipilih',
                              ),
                              SeatLegendItem(
                                color: app_colors.accentRed.withValues(alpha: 0.6),
                                label: 'Terisi',
                                hasBorder: true,
                                borderColor: app_colors.accentRed,
                                icon: Icons.close_rounded,
                              ),
                              SeatLegendItem(
                                color: app_colors.accentChampagne.withValues(alpha: 0.3),
                                label: 'VIP',
                                hasBorder: true,
                                borderColor: app_colors.accentChampagne,
                                icon: Icons.star_rounded,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom bar with selection summary
                  _BottomSummaryBar(
                    selectedSeats: selected.toList()..sort(),
                    totalPrice: totalPrice,
                    formatPrice: _formatPrice,
                    onPayPressed: selected.isEmpty
                        ? null
                        : () => Navigator.pushNamed(
                              context,
                              AppRoutes.payment,
                              arguments: {
                                'movieId': widget.movieId,
                                'time': widget.time,
                                'cinema': widget.cinema,
                                'seats': selected.toList(),
                              },
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

/// Cinema screen with glow effect
class _CinemaScreen extends StatelessWidget {
  const _CinemaScreen();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'LAYAR BIOSKOP',
          style: TextStyle(
            color: app_colors.textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                app_colors.primary.withValues(alpha: 0.8),
                app_colors.primary,
                app_colors.primary.withValues(alpha: 0.8),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: app_colors.primary.withValues(alpha: 0.6),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: app_colors.primary.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
        ),
        // Screen reflection effect
        Container(
          height: 30,
          margin: const EdgeInsets.symmetric(horizontal: 60),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                app_colors.primary.withValues(alpha: 0.15),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom summary bar
class _BottomSummaryBar extends StatelessWidget {
  final List<String> selectedSeats;
  final int totalPrice;
  final String Function(int) formatPrice;
  final VoidCallback? onPayPressed;

  const _BottomSummaryBar({
    required this.selectedSeats,
    required this.totalPrice,
    required this.formatPrice,
    this.onPayPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: app_colors.surface.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(color: app_colors.glassBorder),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selected seats display
              if (selectedSeats.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: app_colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: app_colors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_seat_rounded,
                        color: app_colors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          selectedSeats.join(', '),
                          style: TextStyle(
                            color: app_colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${selectedSeats.length} kursi',
                        style: TextStyle(
                          color: app_colors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

              // Price and button row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Harga',
                          style: TextStyle(
                            color: app_colors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatPrice(totalPrice),
                          style: TextStyle(
                            color: app_colors.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: PremiumButton(
                      label: 'Bayar',
                      icon: Icons.payment_rounded,
                      onTap: onPayPressed ?? () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
