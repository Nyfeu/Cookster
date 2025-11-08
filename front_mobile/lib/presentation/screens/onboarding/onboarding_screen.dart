import 'package:flutter/material.dart';                          // Padrão do Flutter
import 'package:google_fonts/google_fonts.dart';                 // Fontes do Google
import 'package:introduction_screen/introduction_screen.dart';   // Pacote para telas de onboarding
import '../../../core/theme/app_theme.dart';                     // Tema da aplicação
import '../auth/auth_screen.dart';                               // Tela de autenticação

// Tela de onboarding com introdução ao app
// Utiliza o pacote 'introduction_screen' (https://pub.dev/packages/introduction_screen) para criar uma experiência
// de onboarding interativa e personalizável com múltiplas páginas, navegação, botões e indicadores.
// Cada página apresenta um recurso chave do app com título, descrição e imagem ilustrativa.

class OnboardingScreen extends StatelessWidget {

  // Rota nomeada para navegação
  static const String routeName = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // Configuração padrão para cada página do onboarding
    // Conforme a documentação do pacote 'introduction_screen'

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

    // Constrói o widget IntroductionScreen com as páginas definidas
    // e configurações de navegação, botões e indicadores

    return IntroductionScreen(
      globalBackgroundColor: AppTheme.backgroundColor,
      pages: [
        PageViewModel(
          title: "Despensa Inteligente",
          body:
              "Adicione os ingredientes que você tem em casa e nunca mais se pergunte o que eu fazer para o jantar!",
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

      // Callback para quando o onboarding é concluído (botão "Começar")
      // Navega para a tela de autenticação (AuthScreen) usando rota nomeada

      onDone: () {
        Navigator.pushReplacementNamed(context, AuthScreen.routeName);
      },

      // Callback para quando o usuário pula o onboarding (botão "Pular")
      // Navega para a tela de autenticação (AuthScreen) usando rota nomeada

      onSkip: () {
        Navigator.pushReplacementNamed(context, AuthScreen.routeName);
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

  Widget _buildImage(String assetName) {
    return Center(
      child: Image.asset(assetName, width: 250),
    );
  }
}

