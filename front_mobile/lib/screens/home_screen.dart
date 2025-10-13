import 'package:flutter/material.dart';
import 'package:front_mobile/theme/app_theme.dart';
import 'package:front_mobile/utils/bottom_nav_bar.dart'; 

// Páginas de exemplo para cada aba da navegação
const Center pageFeed = Center(child: Text('Página de Início (Feed)'));
const Center pageSearch = Center(child: Text('Página de Busca'));
const Center pageAddRecipe = Center(child: Text('Página para Adicionar Receita'));
const Center pagePantry = Center(child: Text('Página da Despensa'));
const Center pageProfile = Center(child: Text('Página de Perfil'));

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    pageFeed,
    pageSearch,
    pageAddRecipe,
    pagePantry,
    pageProfile,
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
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

