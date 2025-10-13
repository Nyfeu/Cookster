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

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  bool _isSignUpView = true;

  late AnimationController _imageController;

  @override
  void initState() {
    super.initState();
    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    // Inicia a animação já na posição correta para o painel inicial
    if (_isSignUpView) _imageController.forward();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  void _toggleView() {
    setState(() {
      _isSignUpView = !_isSignUpView;
    });
    // Reinicia a animação do pop-up quando o painel muda
    _imageController.reset();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _imageController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double panelHeight = _isSignUpView ? size.height * 0.4 : size.height * 0.48;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            // Formulário de CADASTRO
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isSignUpView ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !_isSignUpView,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: size.height * 0.1,
                      bottom: 160, // Espaço extra para a imagem do painel
                    ),
                    child: _buildFormContent(isSignUp: true),
                  ),
                ),
              ),
            ),

            // Formulário de LOGIN
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isSignUpView ? 0.0 : 1.0,
              child: IgnorePointer(
                ignoring: _isSignUpView,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: size.height * 0.1),
                    child: _buildFormContent(isSignUp: false),
                  ),
                ),
              ),
            ),

            // Painel animado
            AnimatedPositioned(
              duration: const Duration(milliseconds: 700),
              curve: Curves.fastOutSlowIn,
              top: _isSignUpView ? size.height - panelHeight + 60 : -60,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                curve: Curves.fastOutSlowIn,
                width: size.width,
                height: panelHeight,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildPanelContent(
                      isVisible: _isSignUpView,
                      title: 'Já é um de nós?',
                      text:
                          'Faça login e desfrute das vantagens da nossa comunidade.',
                      buttonText: 'Acesse',
                      imagePath: 'assets/images/reg.png',
                      onPressed: _toggleView,
                      isPanelAtBottom: true,
                    ),
                    _buildPanelContent(
                      isVisible: !_isSignUpView,
                      title: 'Novo por aqui?',
                      text: 'Crie uma conta agora mesmo e aproveite as vantagens.',
                      buttonText: 'Registre-se',
                      imagePath: 'assets/images/log.png',
                      onPressed: _toggleView,
                      isPanelAtBottom: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent({required bool isSignUp}) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isSignUp ? 'Criar Conta' : 'Acesse',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 15),
            _buildSocialIcons(),
            const SizedBox(height: 15),
            Text(
              isSignUp
                  ? 'ou use seu email para registrar'
                  : 'ou acesse com sua conta',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            const SizedBox(height: 15),
            if (isSignUp) ...[
              _buildTextField(Icons.person_outline, 'Nome'),
              const SizedBox(height: 10),
            ],
            _buildTextField(Icons.email_outlined, 'Email'),
            const SizedBox(height: 10),
            _buildTextField(Icons.lock_outline, 'Senha', isPassword: true),
            const SizedBox(height: 20),
            _buildActionButton(isSignUp ? 'Criar' : 'Acessar'),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelContent({
    required bool isVisible,
    required String title,
    required String text,
    required String buttonText,
    required String imagePath,
    required VoidCallback onPressed,
    required bool isPanelAtBottom,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: isVisible ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !isVisible,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // --- IMAGEM COM ANIMAÇÃO POP-UP --- //
            Positioned(
              top: isPanelAtBottom ? -90 : null,
              bottom: !isPanelAtBottom ? -70 : null,
              left: 0,
              right: 0,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _imageController,
                  curve: Curves.easeOutBack,
                ),
                child: Image.asset(
                  imagePath,
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // --- CONTEÚDO DO PAINEL --- //
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    text,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  OutlinedButton(
                    onPressed: onPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: Text(
                      buttonText,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSocialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(FontAwesomeIcons.facebookF),
        const SizedBox(width: 20),
        _buildSocialButton(FontAwesomeIcons.google),
        const SizedBox(width: 20),
        _buildSocialButton(FontAwesomeIcons.linkedinIn),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white,
      child: FaIcon(icon, size: 20, color: AppTheme.textColor),
    );
  }

  Widget _buildTextField(IconData icon, String hintText, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        prefixIcon: Icon(icon, color: AppTheme.transitionColor, size: 22),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppTheme.secondaryColor),
        ),
      ),
    );
  }
}
