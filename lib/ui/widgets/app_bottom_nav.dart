import 'package:flutter/material.dart';
import '../../config/app_routes.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            if (currentIndex != 0) {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
            break;
          case 1:
            if (currentIndex != 1) {
              Navigator.pushReplacementNamed(context, AppRoutes.cinemas);
            }
            break;
          case 2:
            if (currentIndex != 2) {
              Navigator.pushReplacementNamed(context, AppRoutes.fun);
            }
            break;
          case 3:
            if (currentIndex != 3) {
              Navigator.pushReplacementNamed(context, AppRoutes.ticket);
            }
            break;
        }
      },
      backgroundColor: const Color(0xFF0B0F1A),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.movie_rounded),
          label: 'Bioskop',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_emotions_rounded),
          label: 'Fun',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.confirmation_number_rounded),
          label: 'Tiket',
        ),
      ],
    );
  }
}
