import '../models/movie_model.dart';
import '../models/schedule_model.dart';
import '../sources/remote/movie_api.dart';

class MovieRepository {
  final _api = MovieApi();
  Future<List<Movie>> fetchNowShowing() async {
    try {
      final data = await _api.fetchMovies();
      return data;
    } catch (_) {
      return <Movie>[];
    }
  }

  Future<Movie?> getMovie(String id) async {
    try {
      final numId = int.tryParse(id);
      if (numId == null) return null;
      final m = await _api.getMovie(numId);
      return m;
    } catch (_) {
      return null;
    }
  }

  Future<List<Schedule>> getSchedules(String movieId) async {
    try {
      final numId = int.tryParse(movieId);
      if (numId == null) return <Schedule>[];
      final items = await _api.getSchedules(numId);
      if (items.isNotEmpty) return items;
      // Fallback demo showtimes when API has no data
      final now = DateTime.now();
      final baseDay = DateTime(now.year, now.month, now.day);
      final slots = <Duration>[
        const Duration(hours: 13),
        const Duration(hours: 15, minutes: 30),
        const Duration(hours: 18),
        const Duration(hours: 20, minutes: 30),
      ];
      final cinemas = ['Theater 1', 'Theater 2', 'Theater 3', 'Theater 1'];
      return List.generate(slots.length, (i) => Schedule(
            movieId: movieId,
            time: baseDay.add(slots[i]),
            cinema: cinemas[i],
          ));
    } catch (_) {
      return <Schedule>[];
    }
  }
}
