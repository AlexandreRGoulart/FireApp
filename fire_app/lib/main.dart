import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fire_app/screen/tela_inicial_screen.dart';  // ⬅️ nova tela inicial
import 'package:fire_app/screen/widget_tree.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      
      // ⬅️ Primeira tela ao abrir o app
      home: const TelaInicialScreen(),
      
      // Rotas opcionais nomeadas
      routes: {
        '/widget_tree': (context) => const WidgetTree(),
      },
    );
  }
}
