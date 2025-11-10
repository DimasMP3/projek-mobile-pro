import 'package:flutter/material.dart';

import '../../config/app_routes.dart';
import '../../data/repositories/movie_repository.dart';
import '../../data/models/movie_model.dart';
import '../../data/models/schedule_model.dart';
import '../../utils/format_currency.dart';
import '../../utils/date_formatter.dart';

class MovieDetailPage extends StatelessWidget {
  final String movieId;
  const MovieDetailPage({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    final repo = MovieRepository();

    // Pakai Future.wait<Object?> lalu cast di builder
    final Future<List<Object?>> future = Future.wait<Object?>([
      repo.getMovie(movieId),          // -> Movie?
      repo.getSchedules(movieId),      // -> List<Schedule>
    ]);

    return Scaffold(
      body: FutureBuilder<List<Object?>>(
        future: future,
        builder: (context, snapshot) {
          // Biar analyzer senang, pakai block {}
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data'));
          }

          // ===== CAST DENGAN TIPE YANG JELAS =====
          final data = snapshot.data!;
          final Movie? movie = data[0] as Movie?;
          final List<Schedule> times = (data[1] as List<Schedule>);

          if (movie == null) {
            return const Center(child: Text('Movie not found'));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(movie.title),
                  background: Image.asset(
                    movie.poster,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(movie.genre, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text('Duration ${movie.durationMin} min'),
                      const SizedBox(height: 16),
                      const Text('Select Time', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      // times sudah non-null (List<Schedule>)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final s in times)
                            OutlinedButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.seats,
                                arguments: movie.id,
                              ),
                              child: Text('${formatShowTime(s.time)} • ${s.cinema}'),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.seats,
                          arguments: movie.id,
                        ),
                        child: Text('Buy Tickets • ${toRupiah(movie.price)}'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
