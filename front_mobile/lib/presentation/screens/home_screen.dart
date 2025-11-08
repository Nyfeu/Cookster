import 'package:flutter/material.dart';                                          // Padrão Flutter
import 'package:front_mobile/core/theme/app_theme.dart';                         // Tema da aplicação

// Utilitários do sistema (core)

import 'package:front_mobile/core/utils/bottom_nav_bar.dart';                    // Barra de navegação inferior personalizada (utilitários)

// Gerenciamento de estado usando Provider

import 'package:provider/provider.dart';                                         // Gerenciamento de estado com Provider
import 'package:front_mobile/presentation/providers/auth_provider.dart';         // Provider de autenticação

// Telas que são usadas como abas na HomeScreen - a partir do body do Scaffold (indexadas pela navbar)

import 'package:front_mobile/presentation/screens/feed/feed_screen.dart';        // Tela de feed de receitas
import 'package:front_mobile/presentation/screens/search/search_screen.dart';    // Tela de busca de receitas
import 'package:front_mobile/presentation/screens/user/profile_screen.dart';     // Tela de perfil do usuário
import 'package:front_mobile/presentation/screens/pantry/pantry_screen.dart';    // Tela de despensa

// Tela principal (home) com navegação entre abas 
// É a primeira tela após o login bem-sucedido
// Usa Scaffold com AppBar e BottomNavigationBar personalizada
// Cada aba é uma tela diferente (Feed, Busca, Despensa, Perfil)

class HomeScreen extends StatefulWidget {

  // Rota nomeada para navegação
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {

  // Índice da aba atualmente selecionada (inicialmente 0 - Feed)
  // Conforme definido em 'core/utils/bottom_nav_bar.dart'

  int _selectedIndex = 0;

  // Lista de widgets que representam cada aba da HomeScreen
  // Servem de referência para o index da navbar

  static const List<Widget> _pages = <Widget>[
    FeedScreen(),
    SearchScreen(),
    PantryScreen(),
    MyProfileTab(), 
  ];

  // Atualiza o índice da aba selecionada na navbar
  // Motivo pelo qual navbar é stateless: o estado é gerenciado aqui!!!

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Construção do widget HomeScreen com Scaffold

  @override
  Widget build(BuildContext context) {

    // Scaffold fornece a estrutura básica da tela: appBar, body e bottomNavigationBar
    // Ele fornece uma estrutura básica e que abrange toda a tela (https://flutterparainiciantes.com.br/scaffold/)

    return Scaffold(

      // AppBar personalizada com tema da aplicação - comum em todas as telas principais

      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          'Cookster',
          style: TextStyle(
            color: AppTheme.backgroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,  // Remove o botão de voltar padrão
      ),

      // Corpo da tela usa IndexedStack para trocar de aba (https://api.flutter.dev/flutter/widgets/IndexedStack-class.html)
      // Ele mantém o estado das abas não visíveis, diferente do uso de apenas trocar o body
      // Cada aba é um widget na lista _pages, indexado por _selectedIndex

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // Barra de navegação inferior personalizada 
      // Fornece navegação entre as abas da HomeScreen
      // O estado da aba selecionada é gerenciado aqui via _onItemTapped

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),

    );

  }

}

// Wrapper (encapsula) para a lógica da aba de perfil do usuário atual
// que obtém o ID do usuário a partir do AuthProvider e passa 
// para a instanciação do ProfileScreen - conforme ModalRoute usado em 'main.dart'

class MyProfileTab extends StatelessWidget {

  const MyProfileTab({super.key});

  @override
  Widget build(BuildContext context) {

    // Obtém o ID do usuário autenticado a partir do AuthProvider

    final userId = Provider.of<AuthProvider>(context, listen: false).userId;

    if (userId == null) {
      return const Center(child: Text('Erro: ID do usuário não encontrado.'));
    }

    // Retorna o ProfileScreen com o ID do usuário atual

    return ProfileScreen(
      userId: userId,
      showScaffold: false, 
    );

  }

}