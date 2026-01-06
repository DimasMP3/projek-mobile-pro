class Schedule {
  final int? id; // Showtime ID from backend
  final String movieId;
  final DateTime time; // jadwal (tanggal+jam)
  final String cinema; // nama bioskop
  final String lang; // Language: ID, EN
  final String type; // Type: 2D, 3D, IMAX, 4DX

  Schedule({
    this.id,
    required this.movieId,
    required this.time,
    required this.cinema,
    this.lang = 'ID',
    this.type = '2D',
  });
}
