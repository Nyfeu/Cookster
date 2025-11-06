// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:front_mobile/theme/app_theme.dart';
import 'package:front_mobile/utils/bottom_nav_bar.dart';
import 'package:front_mobile/screens/feed/feed_screen.dart'; // Importar
import 'package:front_mobile/screens/pantry/pantry_screen.dart'; // Importar

// Páginas de exemplo para cada aba da navegação
// const Center pageFeed = Center(child: Text('Página de Início (Feed)')); // Antigo
const Center pageSearch = Center(child: Text('Página de Busca'));
const Center pageAddRecipe = Center(child: Text('Página para Adicionar Receita'));
// const Center pagePantry = Center(child: Text('Página da Despensa')); // Antigo
const Center pageProfile = Center(child: Text('Página de Perfil'));

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Atualiza a lista de páginas para usar os novos widgets
  static const List<Widget> _pages = <Widget>[
    FeedScreen(),    // Novo
    pageSearch,
    pageAddRecipe,
    PantryScreen(),  // Novo
    pageProfile,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definir o título com base na aba selecionada
    String appBarTitle;
    switch (_selectedIndex) {
      case 0:
        appBarTitle = 'Cookster';
        break;
      case 1:
        appBarTitle = 'Buscar';
        break;
      case 2:
        appBarTitle = 'Postar Receita';
        break;
      case 3:
        appBarTitle = 'Sua Despensa'; // Título da nova tela
        break;
      case 4:
        appBarTitle = 'Perfil';
        break;
      default:
        appBarTitle = 'Cookster';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          appBarTitle, // Título dinâmico
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
      ), // Usar IndexedStack para preservar o estado das telas
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}