import 'dart:ui';
import 'package:flutter/material.dart';

import '../../config/app_routes.dart';
import '../../data/repositories/movie_repository.dart';
import '../../data/models/movie_model.dart';
import '../../data/models/schedule_model.dart';
import '../../utils/format_currency.dart';
import '../../utils/date_formatter.dart';
import '../widgets/universal_image.dart' as uiw;
import '../styles/colors.dart' as app_colors;

class MovieDetailPage extends StatefulWidget {
  final String movieId;
  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage>
    with SingleTickerProviderStateMixin {
  final repo = MovieRepository();
  int? _selectedIndex;
  double _scrollOffset = 0;

  late final ScrollController _scrollController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  late final Future<List<Object?>> _future = Future.wait<Object?>([
    repo.getMovie(widget.movieId),
    repo.getSchedules(widget.movieId),
  ]);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() => _scrollOffset = _scrollController.offset);
      });

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final headerHeight = width * 1.4;

    return Scaffold(
      backgroundColor: app_colors.bg,
      extendBodyBehindAppBar: true,
      body: FutureBuilder<List<Object?>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _buildLoadingState();
          }
          if (!snapshot.hasData) {
            return _buildErrorState('No data available');
          }

          final data = snapshot.data!;
          final Movie? movie = data[0] as Movie?;
          final List<Schedule> times = (data[1] as List<Schedule>);

          if (movie == null) {
            return _buildErrorState('Movie not found');
          }

          return Stack(
            children: [
              // Main content
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Hero Banner
                  SliverToBoxAdapter(
                    child: _HeroBanner(
                      movie: movie,
                      height: headerHeight,
                      scrollOffset: _scrollOffset,
                    ),
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _MovieContent(
                        movie: movie,
                        times: times,
                        selectedIndex: _selectedIndex,
                        onTimeSelected: (index) {
                          setState(() => _selectedIndex = index);
                        },
                      ),
                    ),
                  ),

                  // Bottom spacing for CTA
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),

              // Top bar
              _buildTopBar(context, movie),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomCTA(),
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
            'Loading...',
            style: TextStyle(color: app_colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: app_colors.textTertiary),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: app_colors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, Movie movie) {
    final double opacity = (_scrollOffset / 200).clamp(0.0, 1.0);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: BoxDecoration(
          color: app_colors.bg.withValues(alpha: opacity),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              // Back button
              _GlassIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const Spacer(),
              // Title (fades in as you scroll)
              Opacity(
                opacity: opacity,
                child: Text(
                  movie.title,
                  style: TextStyle(
                    color: app_colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              // Share button
              _GlassIconButton(
                icon: Icons.share_rounded,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomCTA() {
    return FutureBuilder<List<Object?>>(
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

        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: app_colors.bg,
            border: Border(
              top: BorderSide(color: app_colors.glassBorder, width: 1),
            ),
          ),
          child: _PremiumButton(
            label: movie == null
                ? 'Beli Tiket'
                : 'Beli Tiket  •  ${toRupiah(movie.price)}',
            enabled: enabled,
            onTap: enabled
                ? () {
                    final pick = times[_selectedIndex!];
                    Navigator.pushNamed(
                      context,
                      AppRoutes.seats,
                      arguments: {
                        'movieId': movie!.id,
                        'showtimeId': pick.id,
                        'time': pick.time,
                        'cinema': pick.cinema,
                      },
                    );
                  }
                : null,
          ),
        );
      },
    );
  }
}

// ============================================================================
// HERO BANNER
// ============================================================================

class _HeroBanner extends StatelessWidget {
  final Movie movie;
  final double height;
  final double scrollOffset;

  const _HeroBanner({
    required this.movie,
    required this.height,
    required this.scrollOffset,
  });

  @override
  Widget build(BuildContext context) {
    final double parallax = scrollOffset * 0.4;
    final double opacity = (1 - (scrollOffset / 300)).clamp(0.0, 1.0);

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background poster with parallax
          Transform.translate(
            offset: Offset(0, parallax),
            child: uiw.UniversalImage(
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
                stops: const [0.0, 0.4, 0.7, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  app_colors.bg.withValues(alpha: 0.8),
                  app_colors.bg,
                ],
              ),
            ),
          ),

          // Movie info at bottom
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Opacity(
              opacity: opacity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [app_colors.textPrimary, app_colors.primary],
                    ).createShader(bounds),
                    child: Text(
                      movie.title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        height: 1.1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Meta tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaTag(
                        icon: Icons.star_rounded,
                        label: '8.5',
                        isHighlight: true,
                      ),
                      _MetaTag(
                        icon: Icons.access_time_rounded,
                        label: '${movie.durationMin} min',
                      ),
                      _MetaTag(
                        label: movie.genre.split(',').first.trim(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MOVIE CONTENT
// ============================================================================

class _MovieContent extends StatelessWidget {
  final Movie movie;
  final List<Schedule> times;
  final int? selectedIndex;
  final ValueChanged<int> onTimeSelected;

  const _MovieContent({
    required this.movie,
    required this.times,
    required this.selectedIndex,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Synopsis
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sinopsis',
                  style: TextStyle(
                    color: app_colors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  movie.synopsis.isNotEmpty
                      ? movie.synopsis
                      : 'Deskripsi film belum tersedia. Silakan periksa kembali nanti untuk informasi lebih lanjut tentang film ini.',
                  style: TextStyle(
                    color: app_colors.textSecondary,
                    fontSize: 14,
                    height: 1.6,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Showtimes
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: app_colors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pilih Jadwal',
                      style: TextStyle(
                        color: app_colors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (times.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: app_colors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: app_colors.textTertiary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Tidak ada jadwal tersedia',
                          style: TextStyle(color: app_colors.textSecondary),
                        ),
                      ],
                    ),
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (int i = 0; i < times.length; i++)
                        _TimeChip(
                          time: formatShowTime(times[i].time),
                          cinema: times[i].cinema,
                          isSelected: selectedIndex == i,
                          onTap: () => onTimeSelected(i),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WIDGETS
// ============================================================================

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: app_colors.glassWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: app_colors.glassBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: app_colors.glassWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: app_colors.glassBorder),
            ),
            child: Icon(icon, color: app_colors.textPrimary, size: 20),
          ),
        ),
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool isHighlight;

  const _MetaTag({
    this.icon,
    required this.label,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlight
            ? app_colors.primary.withValues(alpha: 0.2)
            : app_colors.glassWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHighlight ? app_colors.primary : app_colors.glassBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: isHighlight ? app_colors.primary : app_colors.textSecondary,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: isHighlight ? app_colors.primary : app_colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String time;
  final String cinema;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeChip({
    required this.time,
    required this.cinema,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? app_colors.primary.withValues(alpha: 0.2)
              : app_colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? app_colors.primary : app_colors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              time,
              style: TextStyle(
                color: isSelected ? app_colors.primary : app_colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              cinema,
              style: TextStyle(
                color: app_colors.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  const _PremiumButton({
    required this.label,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: enabled
              ? LinearGradient(
                  colors: [app_colors.primary, app_colors.primaryDark],
                )
              : null,
          color: enabled ? null : app_colors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: app_colors.primary.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_rounded,
              color: enabled ? Colors.white : app_colors.textTertiary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: enabled ? Colors.white : app_colors.textTertiary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
