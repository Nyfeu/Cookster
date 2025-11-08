import 'package:flutter/material.dart';                             // Flutter padrão
import 'package:google_fonts/google_fonts.dart';                    // Fonte personalizada
import 'package:font_awesome_flutter/font_awesome_flutter.dart';    // Ícones do FontAwesome
import '../../../core/theme/app_theme.dart';                        // Tema da aplicação
import 'package:provider/provider.dart';                            // Gerenciamento de estado
import '../../providers/auth_provider.dart';                        // Provider de autenticação
import '../home_screen.dart';                                       // Tela inicial após login

// Tela de autenticação (login e registro)
// Implementa animações e transições suaves entre as views de login e registro
// Utiliza Provider para gerenciar o estado de autenticação
// e exibir mensagens de erro via SnackBar.
// Inclui validação básica de formulários e feedback visual ao usuário.

class AuthScreen extends StatefulWidget {

  // Rota nomeada para navegação
  static const String routeName = '/auth';

  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();

}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {

  // Controla se está na view de registro (sign up) ou login (sign in)
  bool _isSignUpView = true;

  // Controlador de animação para a imagem do painel
  // De acordo com: https://docs.flutter.dev/ui/animations/tutorial

  late AnimationController _imageController;

  // Controladores de texto para os campos do formulário

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Indica se uma operação de autenticação está em andamento

  bool _isLoading = false;

  // Estado inicial

  @override
  void initState() {
    super.initState();
    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    if (_isSignUpView) _imageController.forward();
  }

  // Limpeza dos controladores

  @override
  void dispose() {
    _imageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Alterna entre as views de login e registro

  void _toggleView() {
    setState(() {
      _isSignUpView = !_isSignUpView;
      _isLoading = false;
    });
    
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    
    _imageController.reset();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _imageController.forward();
    });
  }

  // Exibe uma SnackBar de erro personalizada
  // Conforme: https://docs.flutter.dev/cookbook/design/snackbars

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(
        message,
        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      backgroundColor: Colors.red[600],
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      action: SnackBarAction(
        label: 'X',
        textColor: Colors.white,
        onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      ),
      duration: const Duration(seconds: 5),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Handle Sign Up (Registro)
  // Valida os campos e chama o provider de autenticação
  
  Future<void> _handleSignUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false).register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário cadastrado com sucesso! Faça o login.'),
          backgroundColor: Colors.green,
        ),
      );
      
      _toggleView();

    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      
      if (errorMessage.isNotEmpty) {
          _showErrorSnackBar(errorMessage);
      } else {
          _showErrorSnackBar("Ocorreu um erro desconhecido durante o registro.");
      }
      
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle Sign In (Login)
  // Valida os campos e chama o provider de autenticação

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(
        HomeScreen.routeName, 
      );

    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      _showErrorSnackBar(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Construção da UI da tela de autenticação

  @override
  Widget build(BuildContext context) {

    // Tamanho da tela para cálculos de layout responsivo
    final size = MediaQuery.of(context).size;
    final double panelHeight = _isSignUpView ? size.height * 0.4 : size.height * 0.48;
    
    // Scaffold principal da tela de autenticação
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [

            // Animação de opacidade para o formulário de REGISTRO (fade-in/out)
            AnimatedOpacity(

              // Duração da animação
              duration: const Duration(milliseconds: 300),
              opacity: _isSignUpView ? 1.0 : 0.0,

              // Ignora interações quando não está visível
              child: IgnorePointer(
                ignoring: !_isSignUpView,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: size.height * 0.1,
                      bottom: 160,
                    ),
                    child: _buildFormContent(isSignUp: true),
                  ),
                ),
              ),
            ),

            // Animação de opacidade para o formulário de LOGIN (fade-in/out)
            AnimatedOpacity(

              // Duração da animação
              duration: const Duration(milliseconds: 300),
              opacity: _isSignUpView ? 0.0 : 1.0,

              // Ignora interações quando não está visível
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

            // Painel animado com imagem e botões para alternar entre views
            AnimatedPositioned(

              // Move-se verticalmente conforme a view atual
              // Se estiver na view de registro, fica na parte inferior
              // Se estiver na view de login, sobe para revelar o formulário

              duration: const Duration(milliseconds: 700),
              curve: Curves.fastOutSlowIn,
              top: _isSignUpView ? size.height - panelHeight + 60 : -60,
              child: AnimatedContainer(

                // Permite a animação do container vide: 
                // https://api.flutter.dev/flutter/widgets/AnimatedContainer-class.html

                duration: const Duration(milliseconds: 700),
                curve: Curves.fastOutSlowIn,
                width: size.width,
                height: panelHeight,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(60),
                ),

                // Conteúdo do painel com imagem e botões
                // Usa Stack para sobrepor os dois painéis (login e registro)
                // Conforme: https://api.flutter.dev/flutter/widgets/Stack-class.html

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
                      onPressed: _isLoading ? null : _toggleView, // Desabilita no load
                      isPanelAtBottom: true,
                    ),
                    _buildPanelContent(
                      isVisible: !_isSignUpView,
                      title: 'Novo por aqui?',
                      text: 'Crie uma conta agora mesmo e aproveite as vantagens.',
                      buttonText: 'Registre-se',
                      imagePath: 'assets/images/log.png',
                      onPressed: _isLoading ? null : _toggleView, // Desabilita no load
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

  // Constrói o conteúdo do formulário de autenticação
  // Inclui campos de texto e botões de ação

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
              _buildTextField(
                controller: _nameController,
                icon: Icons.person_outline, 
                hintText: 'Nome',
              ),
              const SizedBox(height: 10),
            ],
            _buildTextField(
              controller: _emailController,
              icon: Icons.email_outlined, 
              hintText: 'Email',
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _passwordController,
              icon: Icons.lock_outline, 
              hintText: 'Senha', 
              isPassword: true,
            ),
            const SizedBox(height: 30),
            
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
    required VoidCallback? onPressed,
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
                    onPressed: onPressed, // Conectado
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
      onPressed: _isLoading 
          ? null 
          : (_isSignUpView ? _handleSignUp : _handleSignIn),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
      ),
      child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
    );
  }

  // Ícones Sociais (sem alterações)
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

  Widget _buildTextField(
    {required TextEditingController controller,
    required IconData icon, 
    required String hintText, 
    bool isPassword = false}) {
    return TextField(
      controller: controller,
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