import 'package:fire_app/screen/show_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:fire_app/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fire_app/database/database_service.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../components/app_button.dart';

class HomePageScreen extends StatelessWidget {
  HomePageScreen({super.key});

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().SignOut();
  }

  Widget _userUid() {
    return Text(
      user?.email ?? 'Sem e-mail',
      style: AppTextStyles.bodyBold.copyWith(fontSize: 16),
    );
  }

  Widget _criarDados() {
    return AppButton(
      text: "Criar dados (teste)",
      onPressed: () async {
        await DatabaseService().create(
          path: 'data1',
          data: "{'name':'Flutter pro'}",
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOPO — Saudação
              Text("Olá 👋", style: AppTextStyles.titleSmall),
              const SizedBox(height: 4),

              _userUid(),
              const SizedBox(height: 20),

              Text("O que deseja fazer hoje?", style: AppTextStyles.subtitle),

              const SizedBox(height: 30),

              // CARDS DE AÇÃO
              Expanded(
                child: ListView(
                  children: [
                    // Abrir Mapa (já existia)
                    _HomeActionCard(
                      icon: Icons.map_outlined,
                      title: "Abrir Mapa",
                      description: "Visualize a sua localização atual no mapa.",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShowLocationScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Criar dados (já existia)
                    _HomeActionCard(
                      icon: Icons.add_chart_outlined,
                      title: "Criar dados (teste)",
                      description: "Envia dados de teste ao Firestore.",
                      onTap: () async {
                        await DatabaseService().create(
                          path: 'data1',
                          data: "{'name':'Flutter pro'}",
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // SignOut (já existia)
                    _HomeActionCard(
                      icon: Icons.logout,
                      title: "Sair",
                      description: "Finalizar sessão e voltar ao login.",
                      onTap: () async {
                        await signOut();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // BOTÃO PRINCIPAL
              AppButton(
                text: "Reportar incêndio agora",
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Tela de cadastro de incêndio ainda não criada",
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _HomeActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyBold.copyWith(
                      color: AppColors.darkText,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.small.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}
