import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Para AuthProvider
import '../../services/profile_service.dart'; // [MUDANÇA] Importa o serviço
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
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

  // [MUDANÇA] Instância do serviço
  final ProfileService _profileService = ProfileService();

  String? token = '';

  late Future<UserProfile> _profileFuture;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    token = Provider.of<AuthProvider>(context, listen: false).token;

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

  // [MUDANÇA] Nova função que chama o serviço e preenche os controladores
  Future<UserProfile> _loadProfile() async {
    setState(() {
      _error = null;
    });
    try {
      // Chama o serviço
      final profileData = await _profileService.fetchUserProfile(widget.userId, token!);

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

  // [MUDANÇA] Atualizado para usar o serviço
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
      // [MUDANÇA] Relança a exceção para ser tratada no onPressed
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
      // [MUDANÇA] FutureBuilder agora espera Map<String, dynamic>
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

          // Sucesso (constrói o formulário, pois os controladores já foram preenchidos)
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
                                child: const Text('Upload new photo'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                style: defaultButtonStyle,
                                onPressed: () {},
                                child: const Text('Reset'),
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
                            // [CORREÇÃO] Obter dependências do context ANTES do async gap
                            final navigator = Navigator.of(context);
                            final scaffoldMessenger =
                                ScaffoldMessenger.of(context);

                            // 1. Ações ANTES de salvar
                            print("Botão pressionado, validando dados...");
                            FocusScope.of(context)
                                .unfocus(); // OK antes do gap

                            bool success = false;
                            String? errorMessage;

                            try {
                              // 2. Chamar a função principal e esperar o resultado
                              success = await _handleSaveChanges();
                            } catch (e) {
                              success = false;
                              errorMessage = e
                                  .toString()
                                  .replaceFirst("Exception: ", "");
                            }

                            // 3. Ações DEPOIS de salvar, baseadas no sucesso
                            // [CORREÇÃO] Usar 'mounted' (do State) para guardar o código
                            if (!mounted)
                              return; // Parar se o widget foi desmontado

                            if (success) {
                              // [CORREÇÃO] Usar a variável local 'scaffoldMessenger'
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Perfil atualizado com sucesso!"),
                                    backgroundColor: Colors.green),
                              );

                              // [CORREÇÃO] Usar a variável local 'navigator'
                              navigator.pushNamedAndRemoveUntil(
                                ProfileScreen.routeName,
                                (route) =>
                                    false, // Remove todas as rotas anteriores
                                arguments: widget.userId,
                              );
                            } else if (errorMessage != null) {
                              // [CORREÇÃO] Usar a variável local 'scaffoldMessenger'
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

  // Helper (sem alteração)
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

