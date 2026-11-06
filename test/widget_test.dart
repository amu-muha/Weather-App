import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whether_app/main.dart';

void main() {
  testWidgets('WeatherApp smoke test loads MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(const WeatherApp());
    expect(find.byType(WeatherApp), findsOneWidget);
  });
}
