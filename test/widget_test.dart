// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stock_app_frontend/main.dart';
import 'package:stock_app_frontend/core/providers/theme_provider.dart';

void main() {
  testWidgets('AlphaWave app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: AlphaWaveApp(),
      ),
    );

    // Verify that the landing screen loads
    expect(find.text('AlphaWave'), findsOneWidget);
  });
}
