import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MeusAlertasScreen extends StatelessWidget {
  const MeusAlertasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // fundo vermelho FireApp
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// BOTÃO VOLTAR
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(height: 25),

              /// TÍTULO
              Text("Meus Alertas", style: AppTextStyles.titleMedium),

              const SizedBox(height: 20),

              /// LISTA DE ALERTAS
              Expanded(
                child: ListView.separated(
                  itemCount: 4, // temporário — depois vem do Firestore
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, index) {
                    return _AlertaCard(
                      titulo: "Incêndio ${index + 1}",
                      data: "12/11/2025 - 14:3$index",
                      status: index % 2 == 0 ? "Pendente" : "Analisado",
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Detalhes em desenvolvimento"),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertaCard extends StatelessWidget {
  final String titulo;
  final String data;
  final String status;
  final VoidCallback onTap;

  const _AlertaCard({
    super.key,
    required this.titulo,
    required this.data,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            /// ÍCONE DE ALERTA
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.local_fire_department,
                color: Colors.red,
                size: 30,
              ),
            ),

            const SizedBox(width: 14),

            /// TEXTO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: AppTextStyles.bodyBold.copyWith(
                      color: AppColors.darkText,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data,
                    style: AppTextStyles.small.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: AppTextStyles.small.copyWith(
                      color: status == "Pendente"
                          ? Colors.orange
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Colors.black45, size: 28),
          ],
        ),
      ),
    );
  }
}
