import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../../data/repositories/movie_repository.dart';
import '../../data/models/movie_model.dart';
import '../../utils/format_currency.dart';
import '../../utils/date_formatter.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final map = (args is Map) ? args : <String, dynamic>{};
    final movieId = map['movieId'] as String?;
    final cinema = map['cinema'] as String?;
    final DateTime? time = map['time'] as DateTime?;
    final seats = (map['seats'] as List?)?.cast<String>() ?? <String>[];

    final repo = MovieRepository();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F1A),
        elevation: 0,
        title: const Text('Pembayaran'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Ringkasan pesanan
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF151B2A),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  if (movieId == null)
                    const _RowText('Film', '-')
                  else
                    FutureBuilder<Movie?>(
                      future: repo.getMovie(movieId),
                      builder: (context, snap) {
                        final movie = snap.data;
                        final harga = movie?.price ?? 0;
                        final total = harga * seats.length;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _RowText('Film', movie?.title ?? '-'),
                            _RowText('Bioskop', cinema ?? '-'),
                            _RowText('Jadwal', time == null ? '-' : formatShowTime(time)),
                            _RowText('Kursi', seats.isEmpty ? '-' : seats.join(', ')),
                            const Divider(color: Colors.white24, height: 20),
                            _RowText('Total', toRupiah(total), isBold: true),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Metode pembayaran (dummy)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF151B2A),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Metode Pembayaran',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _payMethod('Transfer Bank'),
                _payMethod('Kartu Kredit / Debit'),
                _payMethod('E-Wallet'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Tombol Bayar
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () {
                // TANPA argumen—langsung ke halaman tiket
                Navigator.pushNamed(context, AppRoutes.ticket);
              },
              child: const Text(
                'Bayar Sekarang',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: .3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _payMethod(String name) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.radio_button_unchecked, color: Colors.white70),
      title: Text(name, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () {},
    );
  }
}

class _RowText extends StatelessWidget {
  const _RowText(this.left, this.right, {this.isBold = false});
  final String left;
  final String right;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Colors.white.withValues(alpha: .9),
      fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(left, style: style)),
          Text(right, style: style),
        ],
      ),
    );
  }
}
