import '../models/movie_model.dart';
import '../models/schedule_model.dart';

final List<Movie> movies = <Movie>[
  Movie(
    id: 'm1',
    title: 'Taxi Driver',
    poster: 'assets/images/poster-4.jpg',
    genre: 'Drama, Crime',
    durationMin: 235,
    price: 50000,
  ),
  Movie(
    id: 'm2',
    title: 'Avengers: infinity War',
    poster: 'assets/images/poster-2.jpg',
    genre: 'Action, Fantasy',
    durationMin: 148,
    price: 55000,
  ),
  Movie(
    id: 'm3',
    title: 'Captain America: Brave New World',
    poster: 'assets/images/poster-3.jpg',
    genre: 'Action, Fantasy',
    durationMin: 133,
    price: 55000,
  ),
  Movie(
    id: 'm4',
    title: 'Spiderman Beyond ',
    poster: 'assets/images/poster-1.jpg',
    genre: 'Action, Fantasy',
    durationMin: 136,
    price: 55000,
  ),
  Movie(
    id: 'm5',
    title: 'Harry Potter',
    poster: 'assets/images/poster-5.jpg',
    genre: 'Action, Fantasy',
    durationMin: 136,
    price: 55000,
  ),
  Movie(
    id: 'm6',
    title: 'Dilan 1991',
    poster: 'assets/images/poster-6.jpg',
    genre: 'Romance, Drama',
    durationMin: 136,
    price: 55000,
  ),
  Movie(
    id: 'm7',
    title: 'Deadpool',
    poster: 'assets/images/poster-7.jpg',
    genre: 'Action, Fantasy',
    durationMin: 136,
    price: 55000,
  ),
  Movie(
    id: 'm8',
    title: 'Komang',
    poster: 'assets/images/poster-8.jpg',
    genre: 'Romance, Drama',
    durationMin: 136,
    price: 55000,
  ),
  Movie(
    id: 'm9',
    title: 'After Met You',
    poster: 'assets/images/poster-9.jpg',
    genre: 'Romance, Drama',
    durationMin: 120,
    price: 55000,
  ),
  Movie(
    id: 'm10',
    title: 'Mariposa',
    poster: 'assets/images/poster-10.jpg',
    genre: 'Romance, Drama',
    durationMin: 136,
    price: 55000,
  ),
  Movie(
    id: 'm11',
    title: 'My Comic Boyfriend',
    poster: 'assets/images/poster-11.jpg',
    genre: 'Romance, Drama',
    durationMin: 136,
    price: 55000,
  ),
  Movie(
    id: 'm12',
    title: 'Titanic',
    poster: 'assets/images/poster-12.jpg',
    genre: 'Romance, Drama',
    durationMin: 195,
    price: 55000,
  ),
];

final List<Schedule> schedules = <Schedule>[
  // m1
  Schedule(
    movieId: 'm1',
    time: DateTime(2025, 11, 3, 13, 00),
    cinema: 'XXI Margo City',
  ),
  Schedule(
    movieId: 'm1',
    time: DateTime(2025, 11, 3, 15, 00),
    cinema: 'XXI The Park Sawangan',
  ),
  // m2
  Schedule(
    movieId: 'm2',
    time: DateTime(2025, 11, 3, 17, 00),
    cinema: 'CGV Teras Kota',
  ),
  Schedule(
    movieId: 'm2',
    time: DateTime(2025, 11, 3, 20, 00),
    cinema: 'XXI Grand Indonesia',
  ),
  // m3
  Schedule(
    movieId: 'm3',
    time: DateTime(2025, 11, 3, 14, 30),
    cinema: 'Cinépolis Central Park',
  ),
  // m4
  Schedule(
    movieId: 'm4',
    time: DateTime(2025, 11, 3, 19, 15),
    cinema: 'XXI Plaza Indonesia',
  ),
];
