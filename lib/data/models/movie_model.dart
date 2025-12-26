class Movie {
  final String id;
  final String title;
  final String poster; // path asset
  final String genre;
  final int durationMin;
  final double price; // harga dasar
  final String synopsis;

  Movie({
    required this.id,
    required this.title,
    required this.poster,
    required this.genre,
    required this.durationMin,
    required this.price,
    this.synopsis = '',
  });
}
