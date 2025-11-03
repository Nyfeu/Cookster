// lib/widgets/styled_card.dart
import 'package:flutter/material.dart';
import '../../theme/recipe_theme.dart';

class StyledCard extends StatelessWidget {
  final Widget child;
  const StyledCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // .single-instruction, .second-column > div
    return Container(
      width: double.infinity, // Garante que ocupe a largura
      margin: const EdgeInsets.only(bottom: 16), // 1rem
      decoration: BoxDecoration(
        color: theme.colorScheme.background, // var(--background-color)
        borderRadius: BorderRadius.circular(6), // border-radius: 6px
        border: Border(
          left: BorderSide(
            color: AppTheme.accent, // var(--text-color)
            width: 4, // border-left: 4px
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // box-shadow
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16), // padding: 1rem
      child: child,
    );
  }
}