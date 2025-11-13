import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../models/movie_model.dart';
import '../../models/schedule_model.dart';

class MovieApi {
  final Dio _dio = ApiClient.dio;

  Future<List<Movie>> fetchMovies() async {
    final res = await _dio.get('/movies');
    final List data = res.data['data'] as List? ?? [];
    return data.map((j) => _mapMovie(j)).toList();
  }

  Future<Movie?> getMovie(int id) async {
    final res = await _dio.get('/movies/$id');
    final j = res.data['data'];
    if (j == null) return null;
    return _mapMovie(j);
  }

  Future<List<Schedule>> getSchedules(int movieId) async {
    final res = await _dio.get('/showtimes', queryParameters: { 'movieId': movieId });
    final List data = res.data['data'] as List? ?? [];
    return data.map((j) {
      final startsAt = DateTime.tryParse(j['startsAt']?.toString() ?? '') ?? DateTime.now();
      final theaterId = j['theaterId']?.toString() ?? '-';
      return Schedule(
        movieId: movieId.toString(),
        time: startsAt,
        cinema: 'Theater $theaterId',
      );
    }).toList();
  }

  Movie _mapMovie(Map<String, dynamic> j) {
    final int id = (j['id'] as num?)?.toInt() ?? 0;
    final String title = j['title']?.toString() ?? '-';
    final String genre = j['genre']?.toString() ?? '-';
    final int duration = (j['durationMin'] as num?)?.toInt() ?? 0;
    // Poster from DB asset if present
    final posterAssetId = (j['posterAssetId'] as num?)?.toInt();
    final poster = posterAssetId != null
        ? "${ApiClient.dio.options.baseUrl}/assets/$posterAssetId"
        : '';
    return Movie(
      id: id.toString(),
      title: title,
      poster: poster,
      genre: genre,
      durationMin: duration,
      price: 55000,
    );
  }
}

