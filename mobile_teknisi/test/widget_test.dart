import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_teknisi/main.dart';

void main() {
  testWidgets('App basic smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Login Page'), findsOneWidget);
  });
}
