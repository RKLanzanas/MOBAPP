import 'package:flutter_test/flutter_test.dart';
import 'package:scentiments/main.dart';

void main() {
  testWidgets('Scentiments app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ScentimentsApp());
    expect(find.byType(ScentimentsApp), findsOneWidget);
  });
}

