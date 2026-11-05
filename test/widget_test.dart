import 'package:flutter_test/flutter_test.dart';
import 'package:smart_village_health/main.dart';

void main() {
  testWidgets('Smart Village Health dapat ditampilkan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SmartVillageApp());

    expect(find.text('Smart Village Health'), findsOneWidget);
  });
}
