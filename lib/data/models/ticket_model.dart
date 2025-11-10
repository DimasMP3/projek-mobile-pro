class TicketInfo {
  final String movieTitle;
  final String cinemaName;
  final DateTime showTime;
  final List<String> seats;

  const TicketInfo({
    required this.movieTitle,
    required this.cinemaName,
    required this.showTime,
    required this.seats,
  });
}
