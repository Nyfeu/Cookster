import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart'; 
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart'; 
import '../../screens/home_screen.dart';


class AuthScreen extends StatefulWidget {
  static const String routeName = '/auth';

  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  bool _isSignUpView = true;

  late AnimationController _imageController;

  // --- 2. Variáveis de Estado e Controladores --- //
  final AuthService _authService = AuthService();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  // --------------------------------------------- //

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

  @override
  void dispose() {
    _imageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleView() {
    setState(() {
      _isSignUpView = !_isSignUpView;
      _errorMessage = ''; // Limpa erros ao trocar
      _isLoading = false; // Cancela loading
    });
    
    // Limpa campos de texto
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    
    _imageController.reset();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _imageController.forward();
    });
  }

  // --- ADICIONE ESTA NOVA FUNÇÃO --- //
  void _showErrorSnackBar(String message) {
    // Esconde qualquer SnackBar que já esteja visível
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Cria o SnackBar customizado
    final snackBar = SnackBar(
      // Conteúdo principal: o texto do erro
      content: Text(
        message,
        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      // Cor de fundo vermelha
      backgroundColor: Colors.red[600],
      // Faz o SnackBar "flutuar" acima do conteúdo
      behavior: SnackBarBehavior.floating,
      // Margens para o efeito flutuante
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      // Bordas arredondadas
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      // O seu botão "X"
      action: SnackBarAction(
        label: 'X',
        textColor: Colors.white,
        onPressed: () {
          // Ação para fechar o SnackBar
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
      // Duração
      duration: const Duration(seconds: 5),
    );

    // Mostra o SnackBar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  // ---------------------------------- //
  
// --- 3. Lógica de API (Handle Sign Up) --- //
  Future<void> _handleSignUp() async {
    print('[DEBUG] Botão REGISTRAR pressionado!');
    setState(() {
      _isLoading = true;
      _errorMessage = '';
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
      
      _toggleView(); // Troca para a tela de login

    } catch (e) {
      print('[DEBUG] ERRO NO REGISTRO: $e');
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      _showErrorSnackBar(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- 4. Lógica de API (Handle Sign In) --- //
  Future<void> _handleSignIn() async {
    print('[DEBUG] Botão ACESSAR pressionado!');
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {

          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.login(
            _emailController.text,
            _passwordController.text,
          );

      final loggedInUserId = authProvider.userId;

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(
        HomeScreen.routeName, 
      );

    } catch (e) {
      print('[DEBUG] ERRO NO LOGIN: $e');
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      _showErrorSnackBar(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  // ------------------------------------------ //


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double panelHeight = _isSignUpView ? size.height * 0.4 : size.height * 0.48;
    
    print('[DEBUG] O WIDGET AUTH_SCREEN FOI (RE)CONSTRUÍDO');

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
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
                      bottom: 160,
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

            // Painel animado (sem alterações)
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
            
            // --- 5. Conectar campos aos controladores --- //
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

  // Painel _buildPanelContent (sem alterações)
  Widget _buildPanelContent({
    required bool isVisible,
    required String title,
    required String text,
    required String buttonText,
    required String imagePath,
    required VoidCallback? onPressed, // Alterado para aceitar null
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

  // --- 7. Atualizar o Botão de Ação --- //
  Widget _buildActionButton(String text) {
    return ElevatedButton(
      // Conecta a ação correta (Login ou Registro)
      // Desabilita o botão se _isLoading for true
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

  // Ícones Sociais (sem alterações)
  Widget _buildSocialButton(IconData icon) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white,
      child: FaIcon(icon, size: 20, color: AppTheme.textColor),
    );
  }

  // --- 8. Atualizar o _buildTextField --- //
  Widget _buildTextField(
    {required TextEditingController controller,
    required IconData icon, 
    required String hintText, 
    bool isPassword = false}) {
    return TextField(
      controller: controller, // Conecta o controlador
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