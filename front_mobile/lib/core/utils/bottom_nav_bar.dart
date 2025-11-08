import 'package:flutter/material.dart';                  // Pacote padrão do Flutter
import 'package:front_mobile/core/theme/app_theme.dart'; // Tema personalizado da aplicação

// Widget CustomBottomNavBar é um componente reutilizável que encapsula a configuração
// de uma BottomNavigationBar (https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html) 
// estilizada conforme o tema da aplicação.

// Recebe o índice atual selecionado e uma função de callback para tratar toques nos itens.

class CustomBottomNavBar extends StatelessWidget {

  /*
    É definido como StatelessWidget porque não mantém estado interno. O estado do índice selecionado
    é gerenciado externamente e passado via parâmetro 'currentIndex'.
  */

  final int currentIndex;      // Índice do item atualmente selecionado
  final Function(int) onTap;   // Callback para tratar toques nos itens (retorna o índice do item tocado)

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(

        currentIndex: currentIndex,               // Índice do item selecionado
        onTap: onTap,                             // Callback ao tocar em um item que chama a função passada
        type: BottomNavigationBarType.fixed,      // Navbar fixa na parte inferior

        backgroundColor: AppTheme.primaryColor,
        selectedItemColor: AppTheme.accentColor,
        unselectedItemColor: AppTheme.backgroundColor.withOpacity(0.7),

        // Definição dos itens da barra de navegação.
        // Cada item tem um ícone padrão, um ícone ativo e um rótulo,
        // que serão selecionados conforme a interação do usuário.

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Buscar',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen_outlined),
            activeIcon: Icon(Icons.kitchen),
            label: 'Despensa',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),

        ],
      ),

    );
  }
}
