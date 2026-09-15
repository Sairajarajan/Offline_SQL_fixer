import 'package:flutter_test/flutter_test.dart';
import 'package:offline_sql_fixer/main.dart';

void main() {
  testWidgets('Offline SQL Fixer launches', (WidgetTester tester) async {
    await tester.pumpWidget(const OfflineSqlFixerApp());
    await tester.pumpAndSettle();
    expect(find.text('Offline SQL Fixer'), findsOneWidget);
    expect(find.text('Fix Error'), findsOneWidget);
  });
}
