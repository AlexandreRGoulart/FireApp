import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/navigation/app_router.dart';
import 'core/navigation/app_routes.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,

      initialRoute: AppRoutes.telaInicial,

      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
