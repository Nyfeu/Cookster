import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  static const String routeName = '/auth';

  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Controla se a visão de Login está ativa. false = visão de Criar Conta
  bool _isLoginViewVisible = false;

  void _toggleView() {
    setState(() {
      _isLoginViewVisible = !_isLoginViewVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Container para o formulário de Cadastro (metade de cima)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: size.height,
              width: size.width,
              // MUDANÇA: Cor de fundo similar à da web
              color: const Color(0xFFf6f5f7),
              child: _buildFormContainer(
                height: size.height / 2,
                isVisible: _isLoginViewVisible,
                child: _buildSignUpForm(),
              ),
            ),
          ),
          // Container para o formulário de Login (metade de baixo)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height / 2,
              width: size.width,
              // MUDANÇA: Cor de fundo similar à da web
              color: const Color(0xFFf6f5f7),
              child: _buildFormContainer(
                height: size.height / 2,
                isVisible: !_isLoginViewVisible,
                child: _buildSignInForm(),
              ),
            ),
          ),
          // Painel animado que desliza verticalmente
          _buildAnimatedOverlay(
            containerHeight: size.height,
          ),
        ],
      ),
    );
  }

  // Container para os formulários
  Widget _buildFormContainer({
    required double height,
    required bool isVisible,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: isVisible ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: !isVisible,
          child: SingleChildScrollView(
            child: SizedBox(
              height: height,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  // Painel animado com bordas que deslizam de fora da tela
  AnimatedPositioned _buildAnimatedOverlay({
    required double containerHeight,
  }) {
    // MUDANÇA: Raio da borda aumentado
    const double panelBorderRadius = 50.0;
    const double panelOffset = panelBorderRadius;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.fastOutSlowIn,
      top: _isLoginViewVisible ? (containerHeight / 2) : -panelOffset,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
        height: (containerHeight / 2) + panelOffset,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(panelBorderRadius)),
          gradient: LinearGradient(
            colors: [AppTheme.secondaryColor, Color(0xFFE68A41)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Conteúdo para a visão de "Criar Conta"
            AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: _isLoginViewVisible ? 1.0 : 0.0,
              child: _buildOverlayContent(
                imagePath: 'assets/images/reg.png',
                title: 'Não tem uma conta?',
                text: 'Crie uma agora e comece a cozinhar!',
                buttonText: 'Criar Conta',
                onPressed: _toggleView,
              ),
            ),
            // Conteúdo para a visão de "Entrar"
            AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: _isLoginViewVisible ? 0.0 : 1.0,
              child: _buildOverlayContent(
                imagePath: 'assets/images/log.png',
                title: 'Já é um de nós?',
                text: 'Faça o login para ver suas receitas favoritas.',
                buttonText: 'Entrar',
                onPressed: _toggleView,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Conteúdo do painel animado
  Widget _buildOverlayContent({
    required String imagePath,
    required String title,
    required String text,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 180),
          const SizedBox(height: 15),
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 10),
          Text(text,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 14, color: Colors.white.withOpacity(0.9))),
          const SizedBox(height: 15),
          OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: Text(buttonText,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Formulário de Login
  Widget _buildSignInForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Login',
            style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor)),
        const SizedBox(height: 15),
        _buildSocialIcons(),
        const SizedBox(height: 15),
        Text('ou use sua conta',
            style: GoogleFonts.poppins(color: Colors.grey[600])),
        const SizedBox(height: 15),
        _buildTextField(Icons.email_outlined, 'Email'),
        const SizedBox(height: 10),
        _buildTextField(Icons.lock_outline, 'Senha', isPassword: true),
        // MUDANÇA: Espaçamento aumentado para consistência
        const SizedBox(height: 20),
        _buildGradientButton('Entrar'),
      ],
    );
  }

  // Formulário de Cadastro
  Widget _buildSignUpForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        Text('Criar Conta',
            style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor)),
        const SizedBox(height: 15),
        _buildSocialIcons(),
        const SizedBox(height: 15),
        Text('ou use seu email para registrar',
            style: GoogleFonts.poppins(color: Colors.grey[600])),
        const SizedBox(height: 15),
        _buildTextField(Icons.person_outline, 'Nome'),
        const SizedBox(height: 10),
        _buildTextField(Icons.email_outlined, 'Email'),
        const SizedBox(height: 10),
        _buildTextField(Icons.lock_outline, 'Senha', isPassword: true),
        const SizedBox(height: 20),
        _buildGradientButton('Criar'),
        const Spacer(),
      ],
    );
  }

  Widget _buildGradientButton(String text) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [AppTheme.secondaryColor, Color(0xFFE68A41)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
        ),
        child: Text(text,
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSocialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(FontAwesomeIcons.facebookF),
        const SizedBox(width: 15),
        _buildSocialButton(FontAwesomeIcons.google),
        const SizedBox(width: 15),
        _buildSocialButton(FontAwesomeIcons.linkedinIn),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon) {
    return CircleAvatar(
      radius: 20,
      // MUDANÇA: Fundo branco para contrastar com o novo background
      backgroundColor: Colors.white,
      child: FaIcon(icon, size: 18, color: AppTheme.primaryColor),
    );
  }

  Widget _buildTextField(IconData icon, String hintText,
      {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
        filled: true,
        // MUDANÇA: Fundo branco para contrastar
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.secondaryColor),
        ),
      ),
    );
  }
}

