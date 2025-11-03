// lib/widgets/single_utensil.dart
import 'package:flutter/material.dart';
import '../../theme/recipe_theme.dart';

class SingleUtensil extends StatelessWidget {
  final String utensil;
  const SingleUtensil({super.key, required this.utensil});

  @override
  Widget build(BuildContext context) {
    // <li> e .single-tool
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ::marker
          const Padding(
            padding: EdgeInsets.only(top: 6.0, right: 8.0),
            child: Icon(Icons.circle, size: 8, color: AppTheme.secondary),
          ),
          // <p>
          Expanded(
            child: Text(utensil, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}