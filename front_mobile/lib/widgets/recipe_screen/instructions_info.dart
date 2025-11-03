// lib/widgets/instructions_info.dart
import 'package:flutter/material.dart';
import '../../widgets/recipe_screen/single_instruction.dart';

class InstructionsInfo extends StatelessWidget {
  final List<String> steps;
  const InstructionsInfo({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // <h4> (implícito)
        // O .asMap().entries.map é como pegamos o 'index'
        ...steps.asMap().entries.map((entry) {
          int index = entry.key;
          String stepText = entry.value;

          // <SingleInstruction ... />
          return SingleInstruction(
            index: index,
            stepText: stepText,
          );
        }).toList(),
      ],
    );
  }
}