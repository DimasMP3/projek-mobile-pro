import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../widgets/app_bottom_nav.dart';

class CinemasPage extends StatefulWidget {
  const CinemasPage({super.key});

  @override
  State<CinemasPage> createState() => _CinemasPageState();
}

class _CinemasPageState extends State<CinemasPage> {
  // ====== DATA KONFIGURASI (dummy) ======
  final Map<String, List<String>> _cinemasByCity = const {
    'DEPOK': [
      'CINERE',
      'CINERE BELLEVUE XXI',
      'CIPLAZ PARUNG XXI',
      'CITIMALL CIMANGGIS XXI',
      'DEPOK MALL CGV',
      'DEPOK TOWN SQUARE CINEPOLIS',
      'DEPOK XXI',
      'DTC DEPOK CGV',
      'MARGO CITY IMAX',
      'MARGO CITY PREMIERE',
      'MARGO CITY XXI',
    ],

    'JAKARTA': [
      'GANDARIA CITY XXI',
      'PLAZA SENAYAN XXI',
      'PACIFIC PLACE XXI',
      'KOTA KASABLANKA XXI',
      'GRAND INDONESIA CGV',
      'PIK AVENUE XXI',
      'EMPORIUM PLUIT XXI',
      'KELAPA GADING XXI',
      'ARION XXI',
      'CIPUTRA WORLD XXI',
      'BASSURA CITY XXI',
      'TAMAN ANGGREK XXI',
      'BLOK M SQUARE XXI',
      'KUNINGAN CITY XXI',
      'CITRALAND XXI',
      'PLAZA INDONESIA XXI',
      'CENTRAL PARK CGV',
      'AEON MALL TAMAN ANGGREK XXI',
    ],

    'BEKASI': [
      'SUMMARECON BEKASI XXI',
      'GRAND GALAXY PARK XXI',
      'MEGA BEKASI HYPERMALL XXI',
      'REVO TOWN XXI',
      'MALL GRAND METROPOLITAN XXI',
      'BEKASI CYBER PARK XXI',
      'LIVING PLAZA CGV',
      'AEON MALL JGC XXI',
    ],

    'TANGERANG': [
      'SUMMARECON MALL SERPONG XXI',
      'BINTARO JAYA XCHANGE XXI',
      'AEON MALL BSD XXI',
      'LIVING WORLD ALAM SUTERA XXI',
      'SUPERMAL KARAWACI XXI',
      'MALL @ALAM SUTERA XXI',
      'M-TOWN CGV',
      'CIPUTRA SERPONG XXI',
    ],

    'BANDUNG': [
      'PASKAL 23 CGV',
      'PVJ CGV',
      'CIWALK XXI',
      'BRAGA XXI',
      'BTC XXI',
      'CINEPOLIS PARIS VAN JAVA',
      'BIP XXI',
      'SUMMARECON BANDUNG XXI',
      'MIKO MALL CGV',
      'TRANS STUDIO MALL XXI',
    ],

    'SURABAYA': [
      'TP 6 XXI',
      'GALAXY XXI',
      'PAKUWON MALL XXI',
      'LENMARC XXI',
      'TUNJUNGAN PLAZA CGV',
      'MARVEL CITY XXI',
      'GRAND CITY XXI',
      'CIPUTRA WORLD XXI',
      'ROYAL PLAZA CGV',
      'CITY OF TOMORROW XXI',
    ],

    'YOGYAKARTA': [
      'AMBARUKMO PLAZA XXI',
      'JOGJA CITY MALL XXI',
      'SLEMAN CITY HALL XXI',
      'LIPPO PLAZA JOGJA XXI',
      'HARTONO MALL XXI',
      'EMPIRE XXI',
      'GALERIA XXI',
    ],

    'SEMARANG': [
      'PARAGON XXI',
      'CIPUTRA MALL XXI',
      'TENTREM MALL XXI',
      'DP MALL XXI',
      'TRANSMART SETIABUDI XXI',
      'PLAZA SIMPANG LIMA XXI',
    ],

    'MEDAN': [
      'CENTRAL POINT XXI',
      'SUN PLAZA XXI',
      'CAMBRIDGE CITY SQUARE XXI',
      'RINGROAD CITY WALK XXI',
      'MANHATTAN TIMES SQUARE XXI',
      'DELIPARK XXI',
      'PLAZA MEDAN FAIR XXI',
    ],

    'MAKASSAR': [
      'TRANS STUDIO MAKASSAR XXI',
      'NIPAH MALL XXI',
      'PANAkkUKANG SQUARE XXI',
      'MARI MALL XXI',
      'MYKO HOTEL CGV',
      'LIVING PLAZA CGV',
    ],

    'BALIKPAPAN': [
      'E-WALK XXI',
      'BALIKPAPAN SUPERBLOCK XXI',
      'LIVING PLAZA XXI',
    ],

    'DENPASAR': [
      'LEVEL 21 XXI',
      'TRANSMART DUTA PLAZA XXI',
      'BEACHWALK XXI',
      'LIPPO MALL KUTA XXI',
    ],
  };

  final TextEditingController _search = TextEditingController();
  String _selectedCity = 'DEPOK';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<String> _filteredCinemas() {
    final list = _cinemasByCity[_selectedCity] ?? const <String>[];
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((e) => e.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredCinemas();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),

      // 👇 BOTTOM NAV diletakkan di Scaffold (bukan di Column)
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1, // tab "Bioskop" aktif
        onTap: (i) {
          if (i == 1) return;
          if (i == 0) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          } else if (i == 2) {
            Navigator.pushNamed(context, AppRoutes.fun);
          } else if (i == 3) {
            Navigator.pushNamed(context, AppRoutes.ticket);
          }
        },
      ),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ====== Search bar + avatar + bell ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Cari di SanTix',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.account_circle_rounded),
                    color: Colors.white70,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded),
                    color: Colors.white70,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ====== Bar lokasi (dropdown kota) ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.place_outlined, color: Colors.white70),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCity,
                          dropdownColor: const Color(0xFF1A2236),
                          iconEnabledColor: Colors.white70,
                          items: _cinemasByCity.keys
                              .map(
                                (city) => DropdownMenuItem<String>(
                                  value: city,
                                  child: Text(
                                    city,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              _selectedCity = v;
                              _search.clear();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ====== List bioskop ======
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 6, bottom: 12),
                itemCount: items.length,
                separatorBuilder: (_, __) => Divider(
                  color: Colors.white.withOpacity(0.06),
                  height: 1,
                  thickness: 1,
                ),
                itemBuilder: (context, i) {
                  final name = items[i];
                  return InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Buka detail: $name'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(milliseconds: 1200),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_border_rounded,
                            color: Colors.white.withOpacity(0.75),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: .2,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
