import 'package:flutter_test/flutter_test.dart';
import 'package:polaris/main.dart';

void main() {
  testWidgets('Polaris starts at authentication screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const Polaris());

    expect(find.text('Welcome to Polaris'), findsOneWidget);
    expect(find.text('Email or username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
