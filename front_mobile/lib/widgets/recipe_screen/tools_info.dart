// lib/widgets/recipe_screen/tools_info.dart
import 'package:flutter/material.dart';
import '../../widgets/recipe_screen/single_utensil.dart';
import '../../widgets/recipe_screen/styled_card.dart';

class ToolsInfo extends StatelessWidget {
  final List<String> utensils;
  const ToolsInfo({super.key, required this.utensils});

  @override
  Widget build(BuildContext context) {
    // .second-column > div
    return StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // <h4>
          Text(
            'Utensílios',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16), // 1rem

          // .tool-list
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: utensils.map((utensil) {
              return SingleUtensil(utensil: utensil);
            }).toList(),
          ),
        ],
      ),
    );
  }
}