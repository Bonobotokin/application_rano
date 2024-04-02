import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:application_rano/ui/views/splash_screen.dart';
import 'package:application_rano/ui/views/login_page.dart';
import 'package:application_rano/ui/routing/routes.dart';

void main() {
  testWidgets('Navigation from SplashScreen to LoginPage', (WidgetTester tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: AppRoutes.logo,
      getPages: getAppRoutes(),
    ));

    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pumpAndSettle(); // Attend que toutes les animations soient terminées

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
