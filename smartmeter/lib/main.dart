import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'config/theme.dart';
import 'services/energy_repo.dart';
import 'controllers/provider.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();

  final EnergyRepository repository = FirestoreRepository();

  final authProvider = AuthProvider(repository);
  final applianceProvider = ApplianceProvider(repository);

  final router = AppRouter.create(authProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: applianceProvider),
      ],
      child: EnergyApp(router: router),
    ),
  );
}

class EnergyApp extends StatelessWidget {
  final dynamic router;
  const EnergyApp({required this.router, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartMeter',
      theme: AppTheme.universityDark(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}