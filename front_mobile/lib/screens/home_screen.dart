import 'package:flutter/material.dart';
import 'package:front_mobile/theme/app_theme.dart';
import 'package:front_mobile/utils/bottom_nav_bar.dart';
import 'package:provider/provider.dart'; 
import 'package:front_mobile/providers/auth_provider.dart'; 
import 'package:front_mobile/screens/feed/feed_screen.dart';
import 'package:front_mobile/screens/search/search_screen.dart';
import 'package:front_mobile/screens/user/profile_screen.dart';
import 'package:front_mobile/screens/pantry/pantry_screen.dart';

// Páginas de exemplo para cada aba da navegação
const Center pageAddRecipe =
    Center(child: Text('Página para Adicionar Receita'));

class MyProfileTab extends StatelessWidget {
  const MyProfileTab({super.key});

  @override
  Widget build(BuildContext context) {

    final userId = Provider.of<AuthProvider>(context, listen: false).userId;

    if (userId == null) {
      return const Center(child: Text('Erro: ID do usuário não encontrado.'));
    }

    return ProfileScreen(
      userId: userId,
      showScaffold: false, 
    );
  }
}

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    FeedScreen(),
    SearchScreen(),
    pageAddRecipe,
    PantryScreen(),
    MyProfileTab(), 
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          'Cookster',
          style: TextStyle(
            color: AppTheme.backgroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}