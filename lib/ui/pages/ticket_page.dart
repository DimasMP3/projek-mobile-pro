import 'package:flutter/material.dart';

class TicketPage extends StatelessWidget {
  const TicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F1A),
        elevation: 0,
        title: const Text('Tiket Saya'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ticketCard(
            title: 'Contoh Film',
            cinema: 'SanTix XXI',
            time: 'Hari Ini • 19:30',
            seats: 'C5, C6',
          ),
          const SizedBox(height: 12),
          _ticketCard(
            title: 'Contoh Film 2',
            cinema: 'SanTix CGV',
            time: 'Besok • 14:15',
            seats: 'B3, B4',
          ),
        ],
      ),
    );
  }

  Widget _ticketCard({
    required String title,
    required String cinema,
    required String time,
    required String seats,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151B2A),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF223055),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.movie, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(cinema, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 2),
                  Text(
                    '$time  •  $seats',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white54),
        ],
      ),
    );
  }
}
