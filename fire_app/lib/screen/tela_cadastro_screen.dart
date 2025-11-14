import 'package:flutter/material.dart';

import '../components/app_input.dart';
import '../components/app_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/navigation/app_routes.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  // Controllers
  final TextEditingController _nome = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _dataNasc = TextEditingController();
  final TextEditingController _cpf = TextEditingController();
  final TextEditingController _senha = TextEditingController();
  final TextEditingController _confirmarSenha = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // vermelho FireApp
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// LOGO
                Image.asset(
                  "assets/logo.png",
                  width: 120,
                ),

                const SizedBox(height: 40),

                /// NOME COMPLETO
                AppInput(
                  label: "Nome Completo",
                  hint: "Digite seu nome completo",
                  controller: _nome,
                ),

                const SizedBox(height: 18),

                /// EMAIL
                AppInput(
                  label: "E-mail",
                  hint: "Digite seu e-mail",
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 18),

                /// DATA DE NASCIMENTO
                AppInput(
                  label: "Data de Nascimento",
                  hint: "Digite sua data de nascimento",
                  controller: _dataNasc,
                  keyboardType: TextInputType.datetime,
                ),

                const SizedBox(height: 18),

                /// CPF
                AppInput(
                  label: "CPF",
                  hint: "Digite aqui seu CPF",
                  controller: _cpf,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 18),

                /// SENHA
                AppInput(
                  label: "Senha",
                  hint: "Digite sua senha",
                  controller: _senha,
                  obscure: true,
                ),

                const SizedBox(height: 18),

                /// CONFIRMAR SENHA
                AppInput(
                  label: "Confirme a senha",
                  hint: "Confirme sua senha",
                  controller: _confirmarSenha,
                  obscure: true,
                ),

                const SizedBox(height: 24),

                /// BOTÃO CADASTRAR (PRIMARY)
                AppButton(
                  text: "Cadastrar",
                  onPressed: () {
                    // TODO: lógica de cadastro Firebase
                  },
                ),

                const SizedBox(height: 24),

                /// TEXTO "OU"
                Text(
                  "OU",
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 24),

                /// BOTÃO GOOGLE (OUTLINED + ÍCONE)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: const Color(0xFFDDDDDD), // igual ao Figma
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/google.png", width: 22, height: 22),
                        const SizedBox(width: 12),
                        const Text(
                          "Entrar com o google",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                /// JÁ POSSUI CONTA?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Já possui uma conta ?",
                        style: AppTextStyles.body),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.loginRegister);
                      },
                      child: Text(
                        "Faça o login",
                        style: AppTextStyles.bodyBold.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                /// TERMOS E PRIVACIDADE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Text(
                        "Ao confirmar, estou de acordo com os",
                        style: AppTextStyles.small,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          "Termos de Uso e com o\nAviso de Privacidade do FireApp",
                          style: AppTextStyles.small.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
