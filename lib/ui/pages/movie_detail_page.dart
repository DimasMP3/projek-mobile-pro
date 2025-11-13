import 'package:flutter/material.dart';

import '../../config/app_routes.dart';
import '../../data/repositories/movie_repository.dart';
import '../../data/models/movie_model.dart';
import '../../data/models/schedule_model.dart';
import '../../utils/format_currency.dart';
import '../../utils/date_formatter.dart';
import '../widgets/universal_image.dart' as uiw;

class MovieDetailPage extends StatefulWidget {
  final String movieId;
  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final repo = MovieRepository();
  int? _selectedIndex;

  late final Future<List<Object?>> _future = Future.wait<Object?>([
    repo.getMovie(widget.movieId),
    repo.getSchedules(widget.movieId),
  ]);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Poster ratio 2:3 => height = 1.5 * width to show full image
    final headerHeight = width * 1.5;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: FutureBuilder<List<Object?>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data', style: TextStyle(color: Colors.white70)));
          }

          final data = snapshot.data!;
          final Movie? movie = data[0] as Movie?;
          final List<Schedule> times = (data[1] as List<Schedule>);

          if (movie == null) {
            return const Center(child: Text('Movie not found', style: TextStyle(color: Colors.white70)));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFF0B0F1A),
                surfaceTintColor: Colors.transparent,
                expandedHeight: headerHeight,
                pinned: true,
                stretch: true,
                title: Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Fit width so the entire poster is visible without cropping
                      uiw.UniversalImage(
                        path: movie.poster,
                        fit: BoxFit.fitWidth,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.08),
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121826),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    movie.genre,
                                    style: const TextStyle(color: Colors.white70),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('\u2022', style: TextStyle(color: Colors.white38)),
                                const SizedBox(width: 8),
                                Text(
                                  'Duration ${movie.durationMin} min',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Showtimes card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121826),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Time',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (times.isEmpty)
                              const Text('No showtimes available', style: TextStyle(color: Colors.white54))
                            else
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (int i = 0; i < times.length; i++)
                                    ChoiceChip(
                                      label: Text(
                                        '${formatShowTime(times[i].time)}  \u2022  ${times[i].cinema}',
                                      ),
                                      labelStyle: TextStyle(
                                        color: _selectedIndex == i ? Colors.white : Colors.white70,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      selected: _selectedIndex == i,
                                      selectedColor: const Color(0xFF2563EB),
                                      backgroundColor: const Color(0xFF1A2234),
                                      side: BorderSide(
                                        color: _selectedIndex == i ? const Color(0xFF2563EB) : Colors.white24,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      onSelected: (_) => setState(() => _selectedIndex = i),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FutureBuilder<List<Object?>>(
                future: _future,
                builder: (context, snapshot) {
                  Movie? movie;
                  List<Schedule> times = const [];
                  if (snapshot.hasData) {
                    final data = snapshot.data!;
                    movie = data[0] as Movie?;
                    times = data[1] as List<Schedule>;
                  }
                  final enabled = _selectedIndex != null && movie != null;
                  return SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: enabled ? const Color(0xFF2563EB) : Colors.white10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: enabled
                          ? () {
                              final pick = times[_selectedIndex!];
                              Navigator.pushNamed(
                                context,
                                AppRoutes.seats,
                                arguments: {
                                  'movieId': movie!.id,
                                  'time': pick.time,
                                  'cinema': pick.cinema,
                                },
                              );
                            }
                          : null,
                      child: Text(
                        movie == null
                            ? 'Buy Tickets'
                            : 'Buy Tickets  \u2022  ${toRupiah(movie.price)}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

