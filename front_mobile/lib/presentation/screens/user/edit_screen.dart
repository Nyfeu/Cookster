import 'package:flutter/material.dart';                 // Padrão do Flutter
import 'package:provider/provider.dart';                // Pacote Provider
import '../../../data/services/profile_service.dart';   // Serviço de Perfil
import '../../providers/auth_provider.dart';            // Provider da Autenticação
import '../../../data/models/user_profile.dart';        // Modelo do Usuário
import '../../../data/services/auth_service.dart';      // Serviço de Autenticação
import '../auth/auth_screen.dart';                      // Tela de autenticação

// Tela de Edição do Perfil
// Permite fazer as alterações nos dados do usuário autenticado
// Utitliza AuthProvider e AuthService para manipular os dados do usuário

class EditProfileScreen extends StatefulWidget {

  // Rota da página de edição de perfil
  static const String routeName = '/settings';

  final String userId;
  const EditProfileScreen({super.key, required this.userId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  // Controladores de texto para os campos do formulário

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _descricaoController = TextEditingController();

  // Serviço para manipular os dados de perfil

  final ProfileService _profileService = ProfileService();

  // Serviço para verificar autenticação

  final AuthService _authService = AuthService(); 

  String? token = '';

  // O perfil a ser buscado é processado assíncronamente
  // então, utiliza-se Future para sua definição.

  late Future<UserProfile> _profileFuture;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
  
    // Recupera o token de autenticação via AuthProvider
    token = Provider.of<AuthProvider>(context, listen: false).token;

    if (token != null) {
      _profileFuture = _loadProfile();
    } else {
      _profileFuture = Future.error('Usuário não autenticado. Token nulo.');
    }
  }

  // Remove os controladores dos campos do formulário

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  // Carrega os dados do perfil nos campos do formulário

  Future<UserProfile> _loadProfile() async {
    try {
      final profileData = await _profileService.fetchUserProfile(
        widget.userId,
        token!,
      );
      _usernameController.text = profileData.name;
      _emailController.text = profileData.email;
      _bioController.text = profileData.bio;
      _descricaoController.text = profileData.descricao;
      return profileData;
    } catch (err) {
      throw Exception('Erro ao carregar o perfil: ${err.toString()}');
    }
  }

  // Faz o update dos dados através da camada de dados (serviço)

  Future<bool> _handleSaveChanges() async {
    setState(() {
      _isSaving = true;
    });

    final Map<String, dynamic> formData = {
      'name': _usernameController.text,
      'email': _emailController.text,
      'bio': _bioController.text,
      'descricao': _descricaoController.text,
    };

    try {
      await _profileService.updateProfileData(widget.userId, formData, token!);
      return true;
    } catch (e) {
      rethrow;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Volta para a página anterior

  void _cancel() {
    Navigator.of(context).pop();
  }

  // Lida com a lógica de logout - voltando para a tela de autenticação

  Future<void> _handleLogout() async {
    try {

      await _authService.logout();
      Provider.of<AuthProvider>(context, listen: false).logout();

      if (!mounted) return;

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AuthScreen.routeName, (route) => false);
    
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao sair: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final primaryButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.onSecondary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
    final defaultButtonStyle = OutlinedButton.styleFrom(
      foregroundColor: theme.textTheme.bodyLarge?.color,
      side: BorderSide(color: Colors.grey[400]!),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Account settings")),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {

          // 'snapshot' serve para monitorar o estado do Future
          // e atualizar a UI conforme necessário

          // Mostra indicador de carregamento enquanto espera

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Mostra mensagem de erro se ocorrer um problema

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Erro: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            color: Colors.white,
                            child: Column(
                              children: [
                                const CircleAvatar(
                                  radius: 40,
                                  backgroundImage: AssetImage(
                                    'assets/images/default-profile.jpeg',
                                  ),
                                  backgroundColor: Colors.grey,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      style: primaryButtonStyle,
                                      onPressed: () {},
                                      child: const Text('Trocar imagem!'),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      style: defaultButtonStyle,
                                      onPressed: () {},
                                      child: const Text('Formatar'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),

                          // --- Formulário ---
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildTextFormField(
                                  controller: _usernameController,
                                  label: 'Username',
                                  enabled: false,
                                ),
                                const SizedBox(height: 16),
                                _buildTextFormField(
                                  controller: _bioController,
                                  label: 'Bio',
                                ),
                                const SizedBox(height: 16),
                                _buildTextFormField(
                                  controller: _emailController,
                                  label: 'E-mail',
                                  enabled: false,
                                ),
                                const SizedBox(height: 16),
                                _buildTextFormField(
                                  controller: _descricaoController,
                                  label: 'Descricao',
                                  maxLines: 4,
                                ),
                              ],
                            ),
                          ),

                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  style: defaultButtonStyle,
                                  onPressed: _isSaving ? null : _cancel,
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: primaryButtonStyle,
                                  onPressed:
                                      _isSaving
                                          ? null
                                          : () async {

                                            final scaffoldMessenger =
                                                ScaffoldMessenger.of(context);
                                            FocusScope.of(context).unfocus();
                                            bool success = false;
                                            String? errorMessage;
                                            try {
                                              success =
                                                  await _handleSaveChanges();
                                            } catch (e) {
                                              success = false;
                                              errorMessage = e
                                                  .toString()
                                                  .replaceFirst(
                                                    "Exception: ",
                                                    "",
                                                  );
                                            }
                                            if (!mounted) return;
                                            if (success) {
                                              scaffoldMessenger.showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Perfil atualizado com sucesso!",
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                              Navigator.of(context).pop(true);
                                            } else if (errorMessage != null) {
                                              scaffoldMessenger.showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "Falha ao atualizar: $errorMessage",
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                  child:
                                      _isSaving
                                          ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : const Text('Salvar Alterações'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SafeArea(
                  top: false,
                  child: ElevatedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Sair da Conta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    int? maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final bool isInputDisabled = !enabled;
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: isInputDisabled ? Colors.grey[200] : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          decoration: inputDecoration,
        ),
      ],
    );
  }
}
