import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smartmeter/main.dart';
import 'package:smartmeter/services/energy_repo.dart';
import 'package:smartmeter/controllers/provider.dart';
import 'package:smartmeter/routes/app_router.dart';

void main() {
  testWidgets('Login flow smoke test', (WidgetTester tester) async {
    // Setup dependencies
    final repo = FirestoreRepository();
    final authProvider = AuthProvider(repo);
    final applianceProvider = ApplianceProvider(repo);
    
    final router = AppRouter.create(authProvider);

    // Pump app
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<ApplianceProvider>.value(value: applianceProvider),
        ],
        child: EnergyApp(router: router),
      ),
    );

    // Verify Login Screen elements (Matches "University Dark" theme)
    expect(find.text('Smart Campus'), findsOneWidget);
    expect(find.text('Energy Management System'), findsOneWidget);
    expect(find.text('SECURE LOGIN'), findsOneWidget);

    // Verify inputs exist
    expect(find.byType(TextField), findsNWidgets(2));

    // Attempt to login
    await tester.enterText(find.widgetWithText(TextField, 'University Email'), 'test@uni.edu');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password');
    await tester.tap(find.text('SECURE LOGIN'));
    
    await tester.pump(); 
  });
}