import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/glass_container.dart';
import '../styles/colors.dart' as app_colors;
import '../../services/session.dart';
import '../../services/auth_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = Session.name ?? 'Guest';
    final email = Session.email ?? '-';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'G';

    return Scaffold(
      backgroundColor: app_colors.bg,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          } else if (i == 1) {
            Navigator.pushNamed(context, AppRoutes.cinemas);
          } else if (i == 2) {
            Navigator.pushNamed(context, AppRoutes.fun);
          }
        },
      ),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.5),
                  radius: 1.2,
                  colors: [
                    app_colors.primary.withValues(alpha: 0.12),
                    app_colors.bg,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: app_colors.glassWhite,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: app_colors.glassBorder),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: app_colors.textPrimary,
                                size: 18,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Profil Saya',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: app_colors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.settings_outlined,
                              color: app_colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Profile Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _ProfileHeader(
                        name: name,
                        email: email,
                        initials: initials,
                      ),
                    ),
                  ),

                  // Stats Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.confirmation_number_rounded,
                              value: '12',
                              label: 'Tiket',
                              color: app_colors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.local_offer_rounded,
                              value: '5',
                              label: 'Voucher',
                              color: app_colors.accentGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.stars_rounded,
                              value: '2.5K',
                              label: 'Poin',
                              color: app_colors.accentChampagne,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),

                  // VIP Banner
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _VIPBanner(),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),

                  // Menu Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            _MenuTile(
                              icon: Icons.movie_outlined,
                              title: 'Film Saya',
                              subtitle: 'Riwayat film yang ditonton',
                              onTap: () {},
                            ),
                            _MenuDivider(),
                            _MenuTile(
                              icon: Icons.local_offer_outlined,
                              title: 'Voucher Saya',
                              subtitle: '5 voucher aktif',
                              badge: '5',
                              onTap: () {},
                            ),
                            _MenuDivider(),
                            _MenuTile(
                              icon: Icons.favorite_outline_rounded,
                              title: 'Wishlist',
                              subtitle: 'Film yang ingin ditonton',
                              onTap: () {},
                            ),
                            _MenuDivider(),
                            _MenuTile(
                              icon: Icons.share_outlined,
                              title: 'Bagikan & Dapatkan Koin',
                              subtitle: 'Kode referal: KDHGKT',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),

                  // Settings Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            _MenuTile(
                              icon: Icons.help_outline_rounded,
                              title: 'Bantuan',
                              onTap: () {},
                            ),
                            _MenuDivider(),
                            _MenuTile(
                              icon: Icons.info_outline_rounded,
                              title: 'Tentang Aplikasi',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),

                  // Logout Button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _LogoutButton(
                        onPressed: () async {
                          await AuthService.logout();
                          Session.clear();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.login,
                              (r) => false,
                            );
                          }
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 32),
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

/// Profile header with avatar and info
class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String initials;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar with glow
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  app_colors.primary,
                  app_colors.primaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: app_colors.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: app_colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: app_colors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: app_colors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: app_colors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: app_colors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Member',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: app_colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Edit button
          IconButton(
            onPressed: () {},
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: app_colors.glassWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: app_colors.glassBorder),
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 18,
                color: app_colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: app_colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: app_colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// VIP Banner
class _VIPBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            app_colors.primary.withValues(alpha: 0.3),
            app_colors.primaryDark.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: app_colors.primary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: app_colors.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: app_colors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      app_colors.primary,
                      app_colors.accentChampagne,
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    'Upgrade ke VIP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Nikmati promo eksklusif member VIP!',
                  style: TextStyle(
                    fontSize: 12,
                    color: app_colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: app_colors.primary,
            size: 18,
          ),
        ],
      ),
    );
  }
}

/// Menu tile widget
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: app_colors.glassWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: app_colors.textSecondary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: app_colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: app_colors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: app_colors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: app_colors.textTertiary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

/// Menu divider
class _MenuDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        color: app_colors.glassBorder,
        height: 1,
      ),
    );
  }
}

/// Logout button
class _LogoutButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _LogoutButton({required this.onPressed});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        decoration: BoxDecoration(
          color: _isPressed
              ? app_colors.accentRed.withValues(alpha: 0.2)
              : app_colors.glassWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: app_colors.accentRed.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: app_colors.accentRed,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Keluar dari Akun',
              style: TextStyle(
                color: app_colors.accentRed,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
