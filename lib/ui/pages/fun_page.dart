import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';

class FunPage extends StatelessWidget {
  const FunPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F1A),
        elevation: 0,
        title: const Text(
          'TIX Fun 🎈',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2, // sesuaikan index dengan posisi tab “Fun”
        onTap: (index) {
          // navigasi ke tab lain jika diinginkan
          Navigator.pop(context);
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Daftar Aktivitas TIX Fun',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12),
          _FunCard(
            title: 'Funworld Cinere Mall',
            price: 'Rp200.000',
            image: 'assets/images/Fun-Tix-1.jpg',
          ),
          _FunCard(
            title: 'Timezone Kota Kasablanka',
            price: 'Rp185.000',
            image: 'assets/images/Fun-Tix-2.jpg',
          ),
          _FunCard(
            title: 'Playtopia Grand Indonesia',
            price: 'Rp175.000',
            image: 'assets/images/Fun-Tix-3.jpg',
          ),
          _FunCard(
            title: 'Playtopia Grand Indonesia',
            price: 'Rp175.000',
            image: 'assets/images/Fun-Tix-4.jpg',
          ),
          _FunCard(
            title: 'Playtopia Grand Indonesia',
            price: 'Rp175.000',
            image: 'assets/images/Fun-Tix-5.jpg',
          ),
          _FunCard(
            title: 'Playtopia Grand Indonesia',
            price: 'Rp175.000',
            image: 'assets/images/Fun-Tix-6.jpg',
          ),
        ],
      ),
    );
  }
}

class _FunCard extends StatelessWidget {
  final String title;
  final String price;
  final String image;

  const _FunCard({
    required this.title,
    required this.price,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xCC18203A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 180,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
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
