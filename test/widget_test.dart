import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tickets/main.dart'; // pastikan path benar

void main() {
  testWidgets('App starts and shows first screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TicketApp()); // <— ganti MyApp -> TicketApp

    // Sesuaikan expectation dengan layar awalmu
    // contoh kalau AppBar 'Now Showing' muncul:
    expect(find.text('Now Showing'), findsOneWidget);
  });
}
