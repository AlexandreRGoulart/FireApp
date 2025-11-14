import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';

// COMPONENTES DO DESIGN SYSTEM
import '../components/app_input.dart';
import '../components/app_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;
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

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
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
      backgroundColor: AppColors.primary, // vermelho oficial

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// LOGO
              Image.asset('assets/logo.png', width: 120),

              const SizedBox(height: 40),

              /// INPUT EMAIL (AppInput)
              AppInput(
                label: "E-mail",
                hint: "Digite seu e-mail",
                controller: _controllerEmail,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              /// INPUT SENHA (AppInput)
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
                        onChanged: (v) => setState(() => lembrarMe = v!),
                      ),
                      Text("Lembrar-me", style: AppTextStyles.body),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      "Esqueceu a senha?",
                      style: AppTextStyles.bodyBold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// BOTÃO ENTRAR (AppButton)
              AppButton(
                text: isLogin ? "Entrar" : "Cadastrar",
                onPressed: isLogin
                    ? signInWithEmailAndPassword
                    : createUserWithEmailAndPassword,
              ),

              const SizedBox(height: 20),

              /// DIVISOR "ou"
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.white70)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("ou", style: AppTextStyles.body),
                  ),
                  Expanded(child: Divider(color: AppColors.white70)),
                ],
              ),

              const SizedBox(height: 20),

              // BOTÃO GOOGLE
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  onPressed: () {
                    // TODO: implementar login com Google
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/google.png", width: 22, height: 22),
                      const SizedBox(width: 12),
                      Text(
                        "Entrar com Google",
                        style: AppTextStyles.buttonSecondary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 26),

              /// RODAPÉ: Criar conta
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Ainda não possui conta?", style: AppTextStyles.body),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => isLogin = !isLogin),
                    child: Text("Cadastre-se", style: AppTextStyles.bodyBold),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
