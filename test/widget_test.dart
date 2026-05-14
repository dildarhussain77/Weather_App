// Basic smoke test for GetMaterialApp bootstrap.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app1/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Weather app shows home title', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(WeatherApp(preferences: preferences));
    await tester.pump();

    expect(find.text('Weather Forecast'), findsOneWidget);
  });
}
