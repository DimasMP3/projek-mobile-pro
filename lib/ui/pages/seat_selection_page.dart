import 'package:flutter/material.dart';
import '../widgets/seat_widget.dart';
import '../../utils/date_formatter.dart';
import '../../config/app_routes.dart';

class SeatSelectionPage extends StatefulWidget {
  final String movieId;
  final DateTime? time;
  final String? cinema;
  const SeatSelectionPage({super.key, required this.movieId, this.time, this.cinema});

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  final selected = <String>{};

  @override
  Widget build(BuildContext context) {
    // grid 8x10 sederhana
    final rows = 'ABCDEFGH'.split('');
    final cols = List.generate(10, (i) => i + 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Seats'),
        backgroundColor: const Color(0xFF0B0F1A),
        elevation: 0,
      ),
      body: Column(
        children: [
          if (widget.time != null || widget.cinema != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF151B2A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_seat, color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        [
                          if (widget.cinema != null) widget.cinema,
                          if (widget.time != null) formatShowTime(widget.time!),
                        ].whereType<String>().join('  •  '),
                        style: const TextStyle(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          const Text('Screen', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: rows.map((r) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: cols.map((c) {
                      final code = '$r$c';
                      final taken =
                          (r == 'C' &&
                          (c == 5 || c == 6)); // contoh kursi terisi
                      final isSel = selected.contains(code);
                      return SeatWidget(
                        taken: taken,
                        selected: isSel,
                        onTap: () {
                          setState(() {
                            if (isSel) {
                              selected.remove(code);
                            } else {
                              selected.add(code);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: selected.isEmpty
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
              child: Text(
                'Pay (${selected.length} seat${selected.length > 1 ? 's' : ''})',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
