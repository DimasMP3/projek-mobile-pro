import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../../data/repositories/movie_repository.dart';
import '../../data/models/movie_model.dart';
import '../widgets/app_bottom_nav.dart';

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
                              fillColor: Colors.white.withOpacity(0.08),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                              ),
                            ),
                            onTap: () {
                              // TODO: buka halaman pencarian
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.account),

                          // TODO: buka profil
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
                              Image.asset(
                                'assets/images/carousel-${i + 1}.jpg',
                                fit: BoxFit.cover,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(.15),
                                      Colors.black.withOpacity(.45),
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
                              'Semua ›',
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
                                            child: Image.asset(
                                              m.poster,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                    color: const Color(
                                                      0xFF151B2A,
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: const Text(
                                                      'Poster tidak ditemukan',
                                                      style: TextStyle(
                                                        color: Colors.white54,
                                                      ),
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
                                                    Colors.black.withOpacity(
                                                      0.6,
                                                    ),
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
                                                  backgroundColor: const Color(
                                                    0xFF2563EB,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                onPressed: () =>
                                                    Navigator.pushNamed(
                                                      context,
                                                      AppRoutes.detail,
                                                      arguments: m.id,
                                                    ),
                                                child: const Text(
                                                  'BELI TIKET',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
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
                                        color: Colors.white.withOpacity(0.8),
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
                  child: const Text(
                    'Semua  ›',
                    style: TextStyle(color: Colors.white),
                  ),
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

        // List card horizontal
        SizedBox(
          height: 270, // cukup untuk gambar 16:9 + judul + bar harga
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _funItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final item = _funItems[i]; // <-- ambil by index (agar beda-beda)
              return SizedBox(
                width: 300,
                height: 270,
                child: _FunCard(item: item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FunCard extends StatelessWidget {
  const _FunCard({required this.item});
  final _FunItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: const Color(0xCC18203A), // transparent dark blue
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // gambar 16:9
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFE9EDF5),
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported, size: 36),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // judul
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),

          const Spacer(), // dorong bar harga ke bawah
          // "Mulai dari" + harga
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                const Text(
                  'Mulai dari',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  _idr(item.price), // <-- fungsi formatter tersedia di bawah
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
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

// ===== Data & util =====
class _FunItem {
  final String imagePath;
  final String title;
  final int price;
  const _FunItem(this.imagePath, this.title, this.price);
}

final List<_FunItem> _funItems = const [
  _FunItem('assets/images/Fun-Tix-1.jpg', 'Funworld Cinere Mall', 200000),
  _FunItem('assets/images/Fun-Tix-2.jpg', 'Timezone Kota Kasablanka', 185000),
  _FunItem('assets/images/Fun-Tix-3.jpg', 'Kidzilla Summarecon', 150000),
  _FunItem('assets/images/Fun-Tix-4.jpg', 'Playtopia Grand Indonesia', 175000),
  _FunItem(
    'assets/images/Fun-Tix-5.jpg',
    'Playtopia The Park Sawangan',
    175000,
  ),
  _FunItem('assets/images/Fun-Tix-6.jpg', 'Playtopia Ramayana Parung', 175000),
];

String _idr(int n) {
  // format Rupiah sederhana: Rp200.000
  final s = n.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final rev = s.length - i;
    b.write(s[i]);
    if (rev > 1 && rev % 3 == 1) b.write('.');
  }
  return 'Rp${b.toString()}';
}
