import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';
import '../../data/repositories/fun_repository.dart';
import '../../data/models/fun_item_model.dart';
import '../widgets/universal_image.dart' as uiw;

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
      body: _FunList(),
    );
  }
}

class _FunList extends StatelessWidget {
  _FunList();

  final repo = FunRepository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FunItem>>(
      future: repo.fetchFunItems(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? const <FunItem>[];
        if (items.isEmpty) {
          return const Center(
            child: Text('Belum ada item TIX Fun', style: TextStyle(color: Colors.white70)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, i) => _FunRemoteCard(item: items[i]),
        );
      },
    );
  }
}

class _FunRemoteCard extends StatelessWidget {
  const _FunRemoteCard({required this.item});
  final FunItem item;

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
            child: AspectRatio(
              aspectRatio: 16/9,
              child: uiw.UniversalImage(
                path: item.imageUrl ?? '',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      if ((item.subtitle ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(item.subtitle!, style: const TextStyle(color: Colors.white70)),
                        ),
                    ],
                  ),
                ),
                if ((item.linkUrl ?? '').isNotEmpty)
                  const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
