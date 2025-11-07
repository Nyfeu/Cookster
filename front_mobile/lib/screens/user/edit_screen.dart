import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/profile_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../screens/auth/auth_screen.dart';

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
  final AuthService _authService = AuthService(); 

  String? token = '';
  late Future<UserProfile> _profileFuture;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    token = Provider.of<AuthProvider>(context, listen: false).token;

    if (token != null) {
      _profileFuture = _loadProfile();
    } else {
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

  void _cancel() {
    Navigator.of(context).pop();
  }

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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
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
                                              Navigator.pop(context);
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
