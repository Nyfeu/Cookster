import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
// --- MUDANÇA 1: Importar a nova tela de login ---
import '../auth/auth_screen.dart'; 
import '../../theme/app_theme.dart'; 

class OnboardingScreen extends StatelessWidget {
  // --- MUDANÇA 2: Adicionar o nome da rota ---
  static const String routeName = '/';

  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pageDecoration = PageDecoration(
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        color: AppTheme.primaryColor, // Ajustei para uma cor com melhor contraste
      ),
      bodyTextStyle: GoogleFonts.poppins(
        fontSize: 19.0,
        color: AppTheme.primaryColor.withOpacity(0.8),
      ),
      bodyPadding: const EdgeInsets.symmetric(horizontal: 40.0),
      titlePadding: const EdgeInsets.fromLTRB(40.0, 24.0, 40.0, 24.0),
      pageColor: AppTheme.backgroundColor,
      imagePadding: const EdgeInsets.only(top: 70.0),
      imageFlex: 2,
      bodyFlex: 2,
    );

    return IntroductionScreen(
      globalBackgroundColor: AppTheme.backgroundColor,
      pages: [
        PageViewModel(
          title: "Despensa Inteligente",
          body:
              "Adicione os ingredientes que você tem em casa e nunca mais se pergunte 'o que eu faço para o jantar?'.",
          image: _buildImage('assets/images/cesta.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Receitas Personalizadas",
          body:
              "Receba sugestões de receitas deliciosas que você pode fazer com os ingredientes da sua despensa.",
          image: _buildImage('assets/images/pan.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Comunidade de Chefs",
          body:
              "Compartilhe suas próprias receitas, descubra pratos de outros usuários e salve seus favoritos.",
          image: _buildImage('assets/images/social.png'),
          decoration: pageDecoration,
        ),
      ],

      // --- MUDANÇA 3: Atualizar a navegação para usar rotas nomeadas ---
      onDone: () {
        // Navega para a tela de login, substituindo a tela de onboarding
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      },
      onSkip: () {
        // Também navega ao pular
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      },

      showSkipButton: true,
      skip: Text(
        'Pular',
        style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, color: AppTheme.accentColor),
      ),
      next: const Icon(Icons.arrow_forward, color: AppTheme.secondaryColor),
      done: Text(
        'Começar',
        style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, color: AppTheme.secondaryColor),
      ),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.black26, // Cor mais sutil para os pontos inativos
        activeColor: AppTheme.secondaryColor,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }

  Widget _buildImage(String assetName) {
    return Center(
      child: Image.asset(assetName, width: 250),
    );
  }
}