import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

// Renomear a tela para algo mais genérico como AuthScreen pode ser uma boa ideia no futuro,
// mas por enquanto vamos manter LoginScreen para manter a consistência com suas rotas.
class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // --- MUDANÇA 1: Estado para controlar a visão (Login vs. Registro) ---
  bool _isLoginView = true;

  // AnimationControllers para gerenciar as animações de entrada
  late AnimationController _entryAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Controller para o botão de ação principal (Acessar/Registrar)
  late AnimationController _buttonScaleController;
  late Animation<double> _buttonScaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _entryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryAnimationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryAnimationController,
        curve: Curves.easeIn,
      ),
    );

    _buttonScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 400),
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonScaleController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _entryAnimationController.dispose();
    _buttonScaleController.dispose();
    super.dispose();
  }
  
  // --- MUDANÇA 2: Função para alternar a visão ---
  void _toggleView() {
    setState(() {
      _isLoginView = !_isLoginView;
    });
  }

  // Função para simular o login/registro
  Future<void> _handleAuthAction() async {
    setState(() => _isLoading = true);
    await _buttonScaleController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    await _buttonScaleController.reverse();
    setState(() => _isLoading = false);
    // Se a autenticação for bem-sucedida:
    // Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    // Usamos um LayoutBuilder para adaptar a tela para diferentes tamanhos (web/mobile)
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Em telas menores (mobile), empilhar verticalmente
          if (constraints.maxWidth < 800) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildWelcomePanel(isVertical: true),
                  _buildFormPanel(isVertical: true),
                ],
              ),
            );
          }
          // Em telas maiores (desktop/tablet), usar a divisão horizontal
          return Row(
            children: [
              Expanded(flex: 1, child: _buildWelcomePanel()),
              Expanded(flex: 1, child: _buildFormPanel()),
            ],
          );
        },
      ),
    );
  }

  // --- MUDANÇA 3: Painel de Boas-Vindas agora é dinâmico ---
  Widget _buildWelcomePanel({bool isVertical = false}) {
    return Container(
      height: isVertical ? 400 : double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.secondaryColor.withOpacity(0.8),
            AppTheme.secondaryColor,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Usamos AnimatedSwitcher para animar a troca de texto
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Column(
                key: ValueKey<bool>(_isLoginView), // A chave que dispara a animação
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLoginView ? 'Bem-vindo(a) de volta!' : 'Crie sua conta',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLoginView
                        ? 'Para se manter conectado, faça o login com suas informações.'
                        : 'É rápido e fácil. Preencha seus dados para começar a cozinhar.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _toggleView, // Ação do botão é sempre alternar
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  _isLoginView ? 'Registrar' : 'Acessar com minha conta',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MUDANÇA 4: Painel de Formulário agora é dinâmico ---
  Widget _buildFormPanel({bool isVertical = false}) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isLoginView ? 'Acesse' : 'Registro',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 40),

          // AnimatedSwitcher para a troca de formulários
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _isLoginView
                ? _buildLoginForm()
                : _buildRegisterForm(),
          ),
        ],
      ),
    );
  }

  // Widget para o formulário de Login
  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('loginForm'),
      children: [
        _buildTextField(icon: Icons.email, hintText: 'Email'),
        const SizedBox(height: 20),
        _buildTextField(icon: Icons.lock, hintText: 'Senha', obscureText: true),
        const SizedBox(height: 40),
        _buildAuthButton(label: 'Acessar'),
      ],
    );
  }

  // Widget para o formulário de Registro
  Widget _buildRegisterForm() {
    return Column(
      key: const ValueKey('registerForm'),
      children: [
        _buildTextField(icon: Icons.person, hintText: 'Nome completo'),
        const SizedBox(height: 20),
        _buildTextField(icon: Icons.email, hintText: 'Email'),
        const SizedBox(height: 20),
        _buildTextField(icon: Icons.lock, hintText: 'Senha', obscureText: true),
        const SizedBox(height: 40),
        _buildAuthButton(label: 'Registrar'),
      ],
    );
  }
  
  // Widget reutilizável para os campos de texto
  Widget _buildTextField({required IconData icon, required String hintText, bool obscureText = false}) {
    return TextFormField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppTheme.secondaryColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }
  
  // Widget reutilizável para o botão principal
  Widget _buildAuthButton({required String label}) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleAuthAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.secondaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
              : Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}