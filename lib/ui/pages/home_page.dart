import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_routes.dart';
import '../../data/repositories/movie_repository.dart';
import '../../data/models/movie_model.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/universal_image.dart';
import '../styles/colors.dart' as app_colors;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final repo = MovieRepository();
  final ScrollController _scrollController = ScrollController();
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Future<List<Movie>> _moviesFuture; // Cache the future
  
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    
    // Cache the future so it doesn't refetch on every rebuild
    _moviesFuture = repo.fetchNowShowing();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
    
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Make status bar transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    return Scaffold(
      backgroundColor: app_colors.bg,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: _buildBottomNav(),
      body: FutureBuilder<List<Movie>>(
        future: _moviesFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return _buildLoadingState();
          }
          final movies = snap.data ?? [];
          if (movies.isEmpty) {
            return _buildEmptyState();
          }
          return _buildContent(movies);
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return AppBottomNav(
      currentIndex: 0,
      onTap: (i) {
        if (i == 0) return;
        if (i == 1) {
          Navigator.pushReplacementNamed(context, AppRoutes.cinemas);
        } else if (i == 2) {
          Navigator.pushReplacementNamed(context, AppRoutes.fun);
        } else if (i == 3) {
          Navigator.pushReplacementNamed(context, AppRoutes.ticket);
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(app_colors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat film...',
            style: TextStyle(color: app_colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_outlined, size: 64, color: app_colors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'Tidak ada film tersedia',
            style: TextStyle(
              color: app_colors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<Movie> movies) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero Banner
              SliverToBoxAdapter(
                child: _HeroBanner(
                  movie: movies.first,
                  scrollOffset: _scrollOffset,
                  onPlay: () => Navigator.pushNamed(
                    context,
                    AppRoutes.detail,
                    arguments: movies.first.id,
                  ),
                  onInfo: () => Navigator.pushNamed(
                    context,
                    AppRoutes.detail,
                    arguments: movies.first.id,
                  ),
                ),
              ),

          // Now Showing Section
          SliverToBoxAdapter(
            child: _MovieSection(
              title: 'Sedang Tayang',
              movies: movies,
              onSeeAll: () => Navigator.pushNamed(context, AppRoutes.nowShowing),
              onMovieTap: (movie) => Navigator.pushNamed(
                context,
                AppRoutes.detail,
                arguments: movie.id,
              ),
            ),
          ),

          // Coming Soon Section
          if (movies.length > 3)
            SliverToBoxAdapter(
              child: _MovieSection(
                title: 'Segera Tayang',
                movies: movies.sublist(3).reversed.toList(),
                showRank: false,
                onMovieTap: (movie) => Navigator.pushNamed(
                  context,
                  AppRoutes.detail,
                  arguments: movie.id,
                ),
              ),
            ),

          // Popular Section
          if (movies.length > 2)
            SliverToBoxAdapter(
              child: _MovieSection(
                title: 'Populer Minggu Ini',
                movies: movies.sublist(0, movies.length > 5 ? 5 : movies.length),
                showRank: true,
                isLarge: true,
                onMovieTap: (movie) => Navigator.pushNamed(
                  context,
                  AppRoutes.detail,
                  arguments: movie.id,
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
            ],
          ),

          // Top Bar overlay (always on top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(
              scrollOffset: _scrollOffset,
              onProfileTap: () => Navigator.pushNamed(context, AppRoutes.account),
              onSearchTap: () => Navigator.pushNamed(context, AppRoutes.search),
            ),
          ),
        ],
      ),
    );
  }
}

/// Netflix-style Hero Banner
class _HeroBanner extends StatelessWidget {
  final Movie movie;
  final double scrollOffset;
  final VoidCallback? onPlay;
  final VoidCallback? onInfo;

  const _HeroBanner({
    required this.movie,
    required this.scrollOffset,
    this.onPlay,
    this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final double opacity = (1 - (scrollOffset / 300)).clamp(0.0, 1.0);
    final double scale = (1 - (scrollOffset / 1000)).clamp(0.9, 1.0);

    return Transform.scale(
      scale: scale,
      child: SizedBox(
        height: 500,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image with parallax
            Transform.translate(
              offset: Offset(0, scrollOffset * 0.3),
              child: UniversalImage(
                path: movie.poster,
                fit: BoxFit.cover,
              ),
            ),

            // Gradient overlays
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.3, 0.6, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    app_colors.bg.withValues(alpha: 0.7),
                    app_colors.bg,
                  ],
                ),
              ),
            ),

            // Content
            Positioned(
              left: 20,
              right: 20,
              bottom: 40,
              child: Opacity(
                opacity: opacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Movie title
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Tags
                    Row(
                      children: [
                        _Tag(label: 'TOP 10', color: app_colors.accentRed),
                        const SizedBox(width: 8),
                        _Tag(label: 'Film #1 Hari Ini', isOutlined: true),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _HeroButton(
                            icon: Icons.play_arrow_rounded,
                            label: 'Pesan Tiket',
                            isPrimary: true,
                            onTap: onPlay,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _HeroButton(
                            icon: Icons.info_outline_rounded,
                            label: 'Info',
                            onTap: onInfo,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top navigation bar with fade effect
class _TopBar extends StatelessWidget {
  final double scrollOffset;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchTap;

  const _TopBar({
    required this.scrollOffset,
    this.onProfileTap,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final double bgOpacity = (scrollOffset / 100).clamp(0.0, 1.0);

    return Transform.translate(
      offset: Offset(0, -500 + MediaQuery.of(context).padding.top),
      child: Container(
        height: 60 + MediaQuery.of(context).padding.top,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: BoxDecoration(
          color: app_colors.bg.withValues(alpha: bgOpacity),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Logo
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [app_colors.primary, app_colors.accentChampagne],
                ).createShader(bounds),
                child: const Text(
                  'SanTix',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),

              const Spacer(),

              // Search
              IconButton(
                onPressed: onSearchTap,
                icon: const Icon(Icons.search_rounded),
                color: Colors.white,
                iconSize: 26,
              ),

              // Profile
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [app_colors.primary, app_colors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Movie section with horizontal scroll
class _MovieSection extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final bool showRank;
  final bool isLarge;
  final VoidCallback? onSeeAll;
  final Function(Movie)? onMovieTap;

  const _MovieSection({
    required this.title,
    required this.movies,
    this.showRank = false,
    this.isLarge = false,
    this.onSeeAll,
    this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    final double posterHeight = isLarge ? 180.0 : 150.0;
    final double posterWidth = posterHeight * 0.67;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: app_colors.textPrimary,
                  ),
                ),
                if (onSeeAll != null)
                  GestureDetector(
                    onTap: onSeeAll,
                    child: Row(
                      children: [
                        Text(
                          'Lihat Semua',
                          style: TextStyle(
                            fontSize: 12,
                            color: app_colors.textSecondary,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: app_colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Movie list
          SizedBox(
            height: posterHeight + (showRank ? 20 : 0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => onMovieTap?.call(movie),
                    child: showRank
                        ? _RankedMovieCard(
                            movie: movie,
                            rank: index + 1,
                            width: posterWidth,
                            height: posterHeight,
                          )
                        : _MovieCard(
                            movie: movie,
                            width: posterWidth,
                            height: posterHeight,
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple movie card
class _MovieCard extends StatelessWidget {
  final Movie movie;
  final double width;
  final double height;

  const _MovieCard({
    required this.movie,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: UniversalImage(
          path: movie.poster,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: app_colors.surface,
            child: Icon(
              Icons.movie_outlined,
              color: app_colors.textTertiary,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

/// Movie card with rank number (Netflix Top 10 style)
class _RankedMovieCard extends StatelessWidget {
  final Movie movie;
  final int rank;
  final double width;
  final double height;

  const _RankedMovieCard({
    required this.movie,
    required this.rank,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width + 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Rank number
          Positioned(
            left: 0,
            bottom: 0,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w900,
                color: app_colors.bg,
                height: 0.8,
                shadows: [
                  Shadow(
                    color: app_colors.textTertiary,
                    blurRadius: 0,
                    offset: const Offset(2, 0),
                  ),
                  Shadow(
                    color: app_colors.textTertiary,
                    blurRadius: 0,
                    offset: const Offset(-2, 0),
                  ),
                ],
              ),
            ),
          ),

          // Movie poster
          Positioned(
            right: 0,
            top: 0,
            child: _MovieCard(
              movie: movie,
              width: width,
              height: height,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tag widget
class _Tag extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isOutlined;

  const _Tag({
    required this.label,
    this.color,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : color,
        borderRadius: BorderRadius.circular(4),
        border: isOutlined
            ? Border.all(color: Colors.white54, width: 1)
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isOutlined ? Colors.white : Colors.white,
        ),
      ),
    );
  }
}

/// Hero action button
class _HeroButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;

  const _HeroButton({
    required this.icon,
    required this.label,
    this.isPrimary = false,
    this.onTap,
  });

  @override
  State<_HeroButton> createState() => _HeroButtonState();
}

class _HeroButtonState extends State<_HeroButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 42,
        decoration: BoxDecoration(
          color: widget.isPrimary
              ? (_isPressed ? app_colors.primaryDark : app_colors.primary)
              : (_isPressed ? Colors.white24 : Colors.white.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(6),
          border: widget.isPrimary
              ? null
              : Border.all(color: Colors.white30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}