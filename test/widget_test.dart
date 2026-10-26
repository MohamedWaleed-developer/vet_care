import 'package:flutter_test/flutter_test.dart';
import 'package:vet_care/main.dart';

void main() {
  testWidgets('Vet Care app can be created', (WidgetTester tester) async {
    await tester.pumpWidget(const VetCareApp());

    expect(find.byType(VetCareApp), findsOneWidget);
  });
}