import 'package:flutter_test/flutter_test.dart';

import 'package:blood_bank/main.dart';

void main() {
  testWidgets('app renders landing page content', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Blood Donor'), findsWidgets);
    expect(find.text('Find Donor'), findsWidgets);
    expect(find.text('Register as Donor'), findsWidgets);
  });
}
