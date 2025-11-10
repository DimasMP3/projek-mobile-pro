import 'package:flutter/material.dart';
import '../widgets/seat_widget.dart';
import '../../config/app_routes.dart';

class SeatSelectionPage extends StatefulWidget {
  final String movieId;
  const SeatSelectionPage({super.key, required this.movieId});

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
      appBar: AppBar(title: const Text('Select Seats')),
      body: Column(
        children: [
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
                            if (isSel)
                              selected.remove(code);
                            else
                              selected.add(code);
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
                      arguments: selected.toList(),
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
