// lib/widgets/single_instruction.dart
import 'package:flutter/material.dart';
import '../../widgets/recipe_screen/styled_card.dart';

class SingleInstruction extends StatelessWidget {
  final String stepText;
  final int index;

  const SingleInstruction(
      {super.key, required this.stepText, required this.index});

  @override
  Widget build(BuildContext context) {
    // .single-instruction (usando nosso widget reutilizável)
    return StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // <header>
          Row(
            children: [
              // <p>
              Text(
                'Passo ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              // <div> (linha divisória)
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 8), // 0.5rem
          // <p> (texto)
          Text(stepText),
        ],
      ),
    );
  }
}