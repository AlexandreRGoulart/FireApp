import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth.dart';

// COMPONENTES DO DESIGN SYSTEM
import '../components/app_input.dart';
import '../components/app_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/navigation/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool lembrarMe = false;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // 🔥 fundo vermelho
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// LOGO
                Image.asset('assets/logo.png', width: 120),

                const SizedBox(height: 40),

                /// EMAIL
                AppInput(
                  label: "E-mail",
                  hint: "Digite seu E-mail",
                  controller: _controllerEmail,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                /// SENHA
                AppInput(
                  label: "Senha",
                  hint: "Digite sua senha",
                  controller: _controllerPassword,
                  obscure: true,
                ),

                const SizedBox(height: 10),

                /// LEMBRAR-ME + ESQUECEU SENHA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: lembrarMe,
                          checkColor: Colors.black,
                          activeColor: AppColors.white,
                          onChanged: (value) {
                            setState(() => lembrarMe = value!);
                          },
                        ),
                        Text("Lembrar-me", style: AppTextStyles.body),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.telaRecuperarSenha,
                        );
                      },
                      child: Text(
                        "Esqueceu sua senha?",
                        style: AppTextStyles.bodyBold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// BOTÃO ENTRAR
                AppButton(
                  text: "Entrar",
                  onPressed: signInWithEmailAndPassword,
                ),

                const SizedBox(height: 20),

                /// DIVISOR "OU"
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.white70)),
                    const SizedBox(width: 10),
                    Text("ou", style: AppTextStyles.body),
                    const SizedBox(width: 10),
                    Expanded(child: Divider(color: AppColors.white70)),
                  ],
                ),

                const SizedBox(height: 20),

                /// BOTÃO GOOGLE (igual ao Figma)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: const Color(0xFFDDDDDD), // cinza Figma
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/google.png", width: 22),
                        const SizedBox(width: 12),
                        const Text(
                          "Entrar com o google",
                          style: TextStyle(
                            fontFamily: 'Poppins',
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

                /// RODAPÉ — Cadastro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Ainda não possui conta ?", style: AppTextStyles.body),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.telaCadastro);
                      },
                      child: Text(
                        "Cadastre-se",
                        style: AppTextStyles.bodyBold.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
