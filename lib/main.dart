import 'package:flutter/material.dart';
import 'config/app_routes.dart';
import 'config/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/env/.env");
  runApp(const TicketApp());
}

class TicketApp extends StatelessWidget {
  const TicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SanTix Movie App',
      debugShowCheckedModeBanner: false,

      // Tema global (dark theme khusus aplikasi kamu)
      theme: AppTheme.dark,

      // Halaman awal saat aplikasi dijalankan
      initialRoute: AppRoutes.splash,

      // Sistem routing utama aplikasi
      onGenerateRoute: AppRoutes.onGenerateRoute,

      // (Opsional) transisi default untuk Android/iOS
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}
