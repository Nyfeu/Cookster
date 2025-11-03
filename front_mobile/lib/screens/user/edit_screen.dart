import 'package:flutter/material.dart';
// [MUDANÇA] Imports do Provider removidos
// import 'package:provider/provider.dart'; 
import '../../services/profile_service.dart';
// [MUDANÇA] Import do BLoC global
import '../../providers/auth_bloc.dart';
import '../../models/user_profile.dart'; // Ajuste caminhos
import '../../screens/user/profile_screen.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/settings';
  final String userId;
  const EditProfileScreen({super.key, required this.userId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _descricaoController = TextEditingController();

  final ProfileService _profileService = ProfileService();

  String? token = ''; // Esta variável local continua útil

  late Future<UserProfile> _profileFuture;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    // [MUDANÇA] O token agora vem do 'authBloc' global
    // Em vez de: Provider.of<AuthProvider>(context, listen: false).token;
    token = authBloc.currentToken;

    if (token != null) {
      // Passa o token para o serviço
      _profileFuture = _loadProfile();
    } else {
      // Se não há token, o Future já retorna um erro.
      _profileFuture = Future.error('Usuário não autenticado. Token nulo.');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  // [SEM MUDANÇAS]
  // Esta função já depende da variável 'token' do 'State',
  // que preenchemos corretamente no initState.
  Future<UserProfile> _loadProfile() async {
    setState(() {
      _error = null;
    });
    try {
      // Chama o serviço
      final profileData =
          await _profileService.fetchUserProfile(widget.userId, token!);

      // Preenche os controladores
      _usernameController.text = profileData.name;
      _emailController.text = profileData.email;
      _bioController.text = profileData.bio;
      _descricaoController.text = profileData.descricao;

      return profileData; // Retorna os dados para o FutureBuilder
    } catch (err) {
      throw Exception('Erro ao carregar o perfil: ${err.toString()}');
    }
  }

  // [SEM MUDANÇAS]
  // Esta função também já depende da variável 'token' do 'State'.
  Future<bool> _handleSaveChanges() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    final Map<String, dynamic> formData = {
      'name': _usernameController.text,
      'email': _emailController.text,
      'bio': _bioController.text,
      'descricao': _descricaoController.text,
    };

    try {
      await _profileService.updateProfileData(
          widget.userId, formData, token!);

      // 5. Sucesso
      return true; // Retorna sucesso
    } catch (e) {
      // 6. Erro
      rethrow;
    } finally {
      // 7. Parar loading
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // [SEM MUDANÇAS]
    // O seu método build e todos os seus helpers (FutureBuilder, _buildTextFormField, etc.)
    // já estão perfeitamente configurados para usar o estado local (_isSaving)
    // e o _profileFuture. Nada aqui precisa ser alterado.
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Estilos (sem alteração)
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
      appBar: AppBar(
        title: const Text("Account settings"),
      ),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          // Estado de Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Estado de Erro
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

          // Sucesso (constrói o formulário)
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Secção Média (Avatar) ---
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.white,
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                AssetImage('assets/images/default-profile.jpeg'),
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

                    // --- Secção Formulário ---
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

                    // --- Botões de Ação ---
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
                                onPressed: _isSaving
                            ? null
                            : () async {
                              final navigator = Navigator.of(context);
                              final scaffoldMessenger =
                                  ScaffoldMessenger.of(context);

                              print("Botão pressionado, validando dados...");
                              FocusScope.of(context)
                                  .unfocus(); 

                              bool success = false;
                              String? errorMessage;

                              try {
                                success = await _handleSaveChanges();
                              } catch (e) {
                                success = false;
                                errorMessage = e
                                    .toString()
                                    .replaceFirst("Exception: ", "");
                              }

                              if (!mounted)
                                return; 

                              if (success) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Perfil atualizado com sucesso!"),
                                      backgroundColor: Colors.green),
                                );
                                
                                navigator.pushNamedAndRemoveUntil(
                                  ProfileScreen.routeName,
                                  (route) =>
                                      false, 
                                  arguments: widget.userId,
                                );
                              } else if (errorMessage != null) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Falha ao atualizar: $errorMessage"),
                                      backgroundColor: Colors.red),
                                );
                              }

                              print("Processo de salvar concluído no clique.");
                            },
                            child: _isSaving
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
          );
        },
      ),
    );
  }

  // --- Helper _buildTextFormField (sem alteração) ---
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
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 2.0,
        ),
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