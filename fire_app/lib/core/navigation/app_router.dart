import 'package:flutter/material.dart';
import 'app_routes.dart';

import '../../screen/login_register_screen.dart';
import '../../screen/home_page_screen.dart';
import '../../screen/tela_inicial_screen.dart';
import '../../screen/show_location_screen.dart';
import '../../screen/tela_cadastro_screen.dart';
import '../../screen/tela_recuperar_senha.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.initial:
      case AppRoutes.loginRegister:
        return MaterialPageRoute(builder: (_) => LoginPage());

      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => HomePageScreen());

      case AppRoutes.telaInicial:
        return MaterialPageRoute(builder: (_) => TelaInicialScreen());

      case AppRoutes.showLocation:
        return MaterialPageRoute(builder: (_) => ShowLocationScreen());

      case AppRoutes.telaCadastro:
        return MaterialPageRoute(builder: (_) => TelaCadastro());

      case AppRoutes.telaRecuperarSenha:
        return MaterialPageRoute(builder: (_) => const TelaRecuperarSenha());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Rota não encontrada: ${settings.name}')),
          ),
        );
    }
  }
}
