import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../components/app_input.dart';
import '../components/app_button.dart';
import '../core/navigation/app_routes.dart';

class CadastroIncendioScreen extends StatefulWidget {
  const CadastroIncendioScreen({super.key});

  @override
  State<CadastroIncendioScreen> createState() => _CadastroIncendioScreenState();
}

class _CadastroIncendioScreenState extends State<CadastroIncendioScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
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
              Text("Cadastrar Incêndio", style: AppTextStyles.titleMedium),

              const SizedBox(height: 25),

              /// INPUTS
              AppInput(
                label: "Nome",
                hint: "Nome do incêndio",
                controller: nomeController,
              ),

              const SizedBox(height: 20),

              AppInput(
                label: "Latitude",
                hint: "Digite a latitude",
                keyboardType: TextInputType.number,
                controller: latController,
              ),

              const SizedBox(height: 20),

              AppInput(
                label: "Longitude",
                hint: "Digite a longitude",
                keyboardType: TextInputType.number,
                controller: lonController,
              ),

              const SizedBox(height: 30),

              /// BOTÃO — abrir mapa
              AppButton(
                text: "Adicionar no mapa",
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.adicionarMapa);
                },
                outlined: true,
              ),

              const SizedBox(height: 20),

              /// BOTÃO SALVAR
              AppButton(
                text: "Salvar",
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Salvando incêndio... (em desenvolvimento)",
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
