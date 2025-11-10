import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../widgets/app_bottom_nav.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: AppBottomNav(
        currentIndex:
            3, // tab "Tiket" di contohmu, bebas diset. Di sini pakai 3.
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
          } else if (i == 3) {
            // sudah di halaman tiket/akun – biarkan
          }
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Akun Saya',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Header User Info + VIP pill =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDEF3FF), Color(0xFFF6F9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nouval',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '+62857 1234 5678',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                // VIP pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.monetization_on, color: Colors.amber),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Jadilah SAN TIX VIP 🌟 Dapatkan untung lebih 😄',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.black45),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // (Opsional) Kartu dompet/DANA
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: const [
                Icon(Icons.account_balance_wallet_outlined, color: Colors.blue),
                SizedBox(width: 12),
                Text(
                  'DANA',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                Spacer(),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ===== Menu List =====
          _MenuTile(
            icon: Icons.local_offer_outlined,
            title: 'Voucher Saya',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.movie_outlined,
            title: 'Film Saya',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.thumb_up_outlined,
            title: 'Konten Yang Disukai',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.campaign_outlined,
            title: 'Bagikan TIX ID & Dapatkan Koin!',
            trailing: const Text(
              'KDHGKT',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ===== Widget Helper untuk Menu =====
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: Colors.grey[800]),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing:
          trailing ?? const Icon(Icons.chevron_right, color: Colors.black45),
      onTap: onTap,
    );
  }
}
