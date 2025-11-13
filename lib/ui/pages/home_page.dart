import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../../data/repositories/movie_repository.dart';
import '../../data/models/movie_model.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/universal_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final repo = MovieRepository();

  // Banner
  final PageController _bannerCtrl = PageController(
    viewportFraction: 0.92,
    keepPage: true,
  );
  int _bannerIndex = 0;

  // Carousel film
  final PageController _movieCtrl = PageController(
    viewportFraction: 0.78,
    keepPage: true,
  );

  @override
  void dispose() {
    _bannerCtrl.dispose();
    _movieCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0, // tab yang sedang aktif = Beranda
        onTap: (i) {
          if (i == 0) return; // sudah di Beranda
          if (i == 1) {
            Navigator.pushReplacementNamed(context, AppRoutes.cinemas);
          } else if (i == 2) {
            Navigator.pushReplacementNamed(context, AppRoutes.fun);
          } else if (i == 3) {
            Navigator.pushReplacementNamed(context, AppRoutes.ticket);
          }
        },
      ),

      body: SafeArea(
        child: FutureBuilder<List<Movie>>(
          future: repo.fetchNowShowing(),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final movies = snap.data ?? [];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),

                  // ================== SEARCH BAR ==================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'Cari di SanTix',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.08),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.search);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.account),
                          icon: const Icon(Icons.account_circle_rounded),
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ================== BANNER CAROUSEL ==================
                  SizedBox(
                    height: 140,
                    child: PageView.builder(
                      controller: _bannerCtrl,
                      itemCount: 3,
                      padEnds: false,
                      pageSnapping: true,
                      physics: const PageScrollPhysics(),
                      clipBehavior: Clip.none,
                      onPageChanged: (i) => setState(() => _bannerIndex = i),
                      itemBuilder: (context, i) => Padding(
                        padding: EdgeInsets.only(
                          left: i == 0 ? 16 : 8,
                          right: i == 2 ? 16 : 8,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (movies.isNotEmpty)
                                UniversalImage(
                                  path: movies[i % movies.length].poster,
                                  fit: BoxFit.cover,
                                )
                              else
                                Container(color: const Color(0xFF151B2A)),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: .15),
                                      Colors.black.withValues(alpha: .45),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final active = _bannerIndex == i;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active ? Colors.white : Colors.white24,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),

                  // ================== SEDANG TAYANG ==================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '🎬  Sedang Tayang',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.nowShowing,
                          ),
                            child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Text(
                              'Semua',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (movies.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Tidak ada film yang sedang tayang',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  else
                    // ===== Carousel film (poster + judul & teks digabung di item) =====
                    SizedBox(
                      height: 420,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: PageView.builder(
                          controller: _movieCtrl,
                          padEnds: false,
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          physics: const BouncingScrollPhysics(),
                          allowImplicitScrolling: true,
                          itemCount: movies.length,
                          itemBuilder: (context, i) {
                            final m = movies[i];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Poster + tombol
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: UniversalImage(
                                              path: m.poster,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                color: const Color(0xFF151B2A),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Gambar tidak tersedia',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned.fill(
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black.withValues(alpha: 0.6),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              margin: const EdgeInsets.all(12),
                                              height: 44,
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF2563EB),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                onPressed: () => Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.detail,
                                                  arguments: m.id,
                                                ),
                                                child: const Text(
                                                  'Pesan Tiket',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Badge nomor opsional
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Container(
                                              width: 26,
                                              height: 26,
                                              alignment: Alignment.center,
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                '${i + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Judul & teks (bagian dari item)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      m.title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Text(
                                      'Pesan tiket presale film ini, supaya kamu bisa nonton film ini lebih awal! 🚀',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // ================== TIX FUN (FIX OVERFLOW + NAV) ==================
                  _FunSection(
                    onTapSeeAll: () {
                      // arahkan ke tab / halaman Fun
                      Navigator.pushNamed(context, AppRoutes.fun);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// =====================  TIX FUN SECTION (FIXED)  =====================

class _FunSection extends StatelessWidget {
  const _FunSection({this.onTapSeeAll});
  final VoidCallback? onTapSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header & tombol "Semua"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                '🎈  TIX Fun',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: onTapSeeAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A3452),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text('Semua', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Dapatkan pengalaman yang seru & mendebarkan!',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        const SizedBox(height: 12),

        // Removed local image-based content (Fun Tix) to rely solely on DB data
        const SizedBox.shrink(),
      ],
    );
  }
}

// Fun Tix section removed to ensure all dynamic content comes from DB



