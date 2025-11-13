import 'package:flutter/material.dart';
import '../../data/models/movie_model.dart';
import 'universal_image.dart' as uiw;
import '../../utils/format_currency.dart';

class MovieListTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback onBuy;
  const MovieListTile({super.key, required this.movie, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121826),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: uiw.UniversalImage(path: movie.poster, fit: BoxFit.cover),
            ),
          ),

          // Info + Tombol
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  movie.genre,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  '${movie.durationMin} min • ${toRupiah(movie.price)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: onBuy,
                    child: const Text('BELI TIKET'),
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
