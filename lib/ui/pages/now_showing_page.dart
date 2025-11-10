import 'package:flutter/material.dart';
import '../../data/repositories/movie_repository.dart';
import '../../data/models/movie_model.dart';
import '../../config/app_routes.dart';

class NowShowingPage extends StatelessWidget {
  const NowShowingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = MovieRepository();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F1A),
        elevation: 0,
        title: const Text('Film Bioskop'),
      ),
      body: FutureBuilder<List<Movie>>(
        future: repo.fetchNowShowing(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final movies = snap.data ?? [];
          if (movies.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada film yang sedang tayang',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: Row(
                    children: const [
                      Text(
                        'SEDANG TAYANG',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .3,
                        ),
                      ),
                      SizedBox(width: 16),
                      // Text(
                      //   'AKAN DATANG',
                      //   style: TextStyle(
                      //     color: Colors.white24,
                      //     fontWeight: FontWeight.w700,
                      //     letterSpacing: .3,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),

              // GRID: buat item lebih tinggi + jarak lega
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 24, // jarak antar baris
                    crossAxisSpacing: 14, // jarak antar kolom
                    childAspectRatio: 0.56, // <-- LEBIH TINGGI dari 0.62
                  ),
                  itemCount: movies.length,
                  itemBuilder: (context, i) => _MovieGridCard(movie: movies[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MovieGridCard extends StatelessWidget {
  const _MovieGridCard({required this.movie});
  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.detail, arguments: movie.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster mengisi sisa tinggi agar tidak overflow
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      movie.poster,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF151B2A),
                        alignment: Alignment.center,
                        child: const Text(
                          'Poster\nunavailable',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Judul dibatasi 2 baris
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),

          // Genre 1 baris
          Text(
            movie.genre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
