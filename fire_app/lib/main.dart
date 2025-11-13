import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fire_app/screen/tela_inicial_screen.dart';
import 'package:fire_app/screen/widget_tree.dart';
import 'theme/app_theme.dart'; // ⬅️ importa o tema global

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

      home: const TelaInicialScreen(),

      routes: {
        '/widget_tree': (context) => const WidgetTree(),
      },
    );
  }
}
