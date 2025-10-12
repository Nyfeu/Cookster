import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../../theme/app_theme.dart'; 

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pageDecoration = PageDecoration(
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        color: AppTheme.textColor,
      ),
      bodyTextStyle: GoogleFonts.poppins(
        fontSize: 19.0,
        color: AppTheme.primaryColor,
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
      // Lista de páginas do onboarding
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
      // Ação ao finalizar
      onDone: () {
        print("Onboarding finalizado!");
        // Aqui navegaremos para a próxima tela, como a de login
        // Navigator.of(context).pushReplacement(...);
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
      // Estilo dos indicadores de página (bolinhas)
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: AppTheme.transitionColor,
        activeColor: AppTheme.secondaryColor,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: AppTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }

  // Widget para centralizar e ajustar o tamanho das imagens
  Widget _buildImage(String assetName) {
    return Center(
      child: Image.asset(assetName, width: 250),
    );
  }
}

