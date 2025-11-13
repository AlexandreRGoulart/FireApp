import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fire_app/screen/widget_tree.dart';

class TelaInicialScreen extends StatefulWidget {
  const TelaInicialScreen({super.key});

  @override
  State<TelaInicialScreen> createState() => _TelaInicialScreenState();
}

class _TelaInicialScreenState extends State<TelaInicialScreen> {
  @override
  void initState() {
    super.initState();

    // Timer de 5 segundos antes de redirecionar para o fluxo normal do app
    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WidgetTree()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB11008), // 🔥 Fundo vermelho do Figma
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO CENTRAL
            Image.asset(
              'assets/logo.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 24),

            // NOME DO APP (cor #010207 do Figma)
            const Text(
              'FireApp',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF010207), 
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
