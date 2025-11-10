import 'package:collection/collection.dart';
import '../dummy/dummy_data.dart';
import '../models/movie_model.dart';
import '../models/schedule_model.dart';

class MovieRepository {
  Future<List<Movie>> fetchNowShowing() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return movies;
  }

  Future<Movie?> getMovie(String id) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return movies.firstWhereOrNull((m) => m.id == id);
  }

  Future<List<Schedule>> getSchedules(String movieId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return schedules.where((s) => s.movieId == movieId).toList();
  }
}
