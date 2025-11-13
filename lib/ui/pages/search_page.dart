import 'package:flutter/material.dart';
import '../../data/repositories/movie_repository.dart';
import '../../data/models/movie_model.dart';
import '../widgets/movie_list_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _repo = MovieRepository();
  final _q = TextEditingController();
  List<Movie> _all = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _repo.fetchNowShowing();
    setState(() => _all = list);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _all.where((m) {
      final q = _query.toLowerCase();
      return q.isEmpty || m.title.toLowerCase().contains(q) || m.genre.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F1A),
        elevation: 0,
        title: TextField(
          controller: _q,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Cari film...',
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _q.clear();
              setState(() => _query = '');
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final m = filtered[i];
            return MovieListTile(
              movie: m,
              onBuy: () {},
            );
          },
        ),
      ),
    );
  }
}

