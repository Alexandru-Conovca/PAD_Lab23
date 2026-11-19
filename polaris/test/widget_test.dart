import 'package:flutter_test/flutter_test.dart';
import 'package:polaris/data/api/api_client.dart';
import 'package:polaris/data/api/polaris_api.dart';
import 'package:polaris/main.dart';
import 'package:polaris/models/auth_model.dart';
import 'package:polaris/router.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Polaris starts at authentication screen', (
    WidgetTester tester,
  ) async {
    final client = PolarisApiClient(baseUrl: 'http://localhost:8080');
    final api = PolarisApi(client);
    final auth = AuthModel(api, client);

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthModel>.value(
        value: auth,
        child: Polaris(routerConfig: createRouter(auth)),
      ),
    );

    expect(find.text('Welcome to Polaris'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
