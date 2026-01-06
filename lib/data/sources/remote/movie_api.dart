import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../models/movie_model.dart';
import '../../models/schedule_model.dart';

class MovieApi {
  final Dio _dio = ApiClient.dio;

  // Cache theater names to avoid repeated API calls
  Map<int, String> _theaterCache = {};

  Future<List<Movie>> fetchMovies() async {
    final res = await _dio.get('/api/movies');
    final List data = res.data['data'] as List? ?? [];
    return data.map((j) => _mapMovie(j)).toList();
  }

  Future<Movie?> getMovie(int id) async {
    final res = await _dio.get('/api/movies/$id');
    final j = res.data['data'];
    if (j == null) return null;
    return _mapMovie(j);
  }

  Future<List<Schedule>> getSchedules(int movieId) async {
    final res = await _dio.get('/api/showtimes', queryParameters: {'movieId': movieId});
    final List data = res.data['data'] as List? ?? [];
    
    // Fetch theater names if not cached
    await _loadTheaters();
    
    return data.map((j) {
      final startsAt = DateTime.tryParse(j['startsAt']?.toString() ?? '') ?? DateTime.now();
      final theaterId = (j['theaterId'] as num?)?.toInt() ?? 0;
      final theaterName = _theaterCache[theaterId] ?? 'Theater $theaterId';
      final showtimeId = (j['id'] as num?)?.toInt();
      final lang = j['lang']?.toString() ?? 'ID';
      final type = j['type']?.toString() ?? '2D';
      
      return Schedule(
        id: showtimeId,
        movieId: movieId.toString(),
        time: startsAt,
        cinema: theaterName,
        lang: lang,
        type: type,
      );
    }).toList();
  }

  Future<void> _loadTheaters() async {
    if (_theaterCache.isNotEmpty) return;
    try {
      final res = await _dio.get('/api/theaters');
      final List data = res.data['data'] as List? ?? [];
      for (final t in data) {
        final id = (t['id'] as num?)?.toInt() ?? 0;
        final name = t['name']?.toString() ?? 'Theater $id';
        _theaterCache[id] = name;
      }
    } catch (_) {
      // Ignore errors, use fallback names
    }
  }

  Movie _mapMovie(Map<String, dynamic> j) {
    final int id = (j['id'] as num?)?.toInt() ?? 0;
    final String title = j['title']?.toString() ?? '-';
    final String genre = j['genre']?.toString() ?? '-';
    final int duration = (j['durationMin'] as num?)?.toInt() ?? 0;
    final String rating = j['rating']?.toString() ?? '';
    // Poster from DB asset if present
    final posterAssetId = (j['posterAssetId'] as num?)?.toInt();
    final baseUrl = ApiClient.dio.options.baseUrl;
    final poster = posterAssetId != null
        ? "$baseUrl/api/assets/$posterAssetId"
        : '';
    return Movie(
      id: id.toString(),
      title: title,
      poster: poster,
      genre: genre,
      durationMin: duration,
      price: 55000,
      rating: rating,
    );
  }
}

