import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../../services/payment_service.dart';
import '../../services/session.dart';
import '../styles/colors.dart' as app_colors;
import '../widgets/glass_container.dart';
import '../../utils/format_currency.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Ticket> _tickets = [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final email = Session.email;
    if (email == null || email.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Silakan login terlebih dahulu';
      });
      return;
    }

    try {
      final ticketsData = await PaymentService().getTicketHistory(email);
      final tickets = ticketsData
          .map((t) => Ticket.fromJson(t as Map<String, dynamic>))
          .toList();
      
      if (mounted) {
        setState(() {
          _tickets = tickets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat tiket: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_colors.bg,
      appBar: AppBar(
        backgroundColor: app_colors.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: app_colors.textPrimary),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          ),
        ),
        title: Text(
          'Tiket Saya',
          style: TextStyle(
            color: app_colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: app_colors.textPrimary),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _loadTickets();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: app_colors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: app_colors.textTertiary),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: app_colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadTickets();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: app_colors.primary,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 80,
              color: app_colors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada tiket',
              style: TextStyle(
                color: app_colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tiket yang sudah dibeli akan muncul di sini',
              style: TextStyle(color: app_colors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
              icon: const Icon(Icons.movie_outlined),
              label: const Text('Beli Tiket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: app_colors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTickets,
      color: app_colors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          final ticket = _tickets[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TicketCard(ticket: ticket),
          );
        },
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Ticket ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Row(
        children: [
          // Movie icon/poster placeholder
          Container(
            width: 64,
            height: 80,
            decoration: BoxDecoration(
              color: app_colors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.movie_rounded,
              color: app_colors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          // Ticket details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.movieTitle,
                  style: TextStyle(
                    color: app_colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: app_colors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ticket.cinema,
                        style: TextStyle(
                          color: app_colors.textSecondary,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.event_seat_outlined,
                      size: 14,
                      color: app_colors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ticket.seats.join(', '),
                      style: TextStyle(
                        color: app_colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 14,
                      color: app_colors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      toRupiah(ticket.amount.toDouble()),
                      style: TextStyle(
                        color: app_colors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: app_colors.accentGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'LUNAS',
              style: TextStyle(
                color: app_colors.accentGreen,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ticket model
class Ticket {
  final int id;
  final String orderId;
  final String movieTitle;
  final String cinema;
  final List<String> seats;
  final int amount;
  final String status;
  final String? paymentType;
  final String? paidAt;

  Ticket({
    required this.id,
    required this.orderId,
    required this.movieTitle,
    required this.cinema,
    required this.seats,
    required this.amount,
    required this.status,
    this.paymentType,
    this.paidAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int,
      orderId: json['orderId'] as String,
      movieTitle: json['movieTitle'] as String? ?? 'Unknown Movie',
      cinema: json['cinema'] as String? ?? 'Unknown Cinema',
      seats: (json['seats'] as List<dynamic>?)?.cast<String>() ?? [],
      amount: json['amount'] as int? ?? 0,
      status: json['status'] as String? ?? 'paid',
      paymentType: json['paymentType'] as String?,
      paidAt: json['paidAt'] as String?,
    );
  }
}
