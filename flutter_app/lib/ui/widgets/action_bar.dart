import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';

class ActionBar extends StatelessWidget {
  static const String solutionTooltip =
      'First press stops the game and shows you what you got '
      'correct/incorrect. Second press shows you the complete solution.';

  final UiState state;
  final VoidCallback onToggleNotesMode;
  final VoidCallback onClear;
  final VoidCallback onCheckOrSolution;

  const ActionBar({
    super.key,
    required this.state,
    required this.onToggleNotesMode,
    required this.onClear,
    required this.onCheckOrSolution,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          SizedBox(
            height: 40,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: state.notesMode
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.15)
                    : null,
                side: BorderSide(
                  color: state.notesMode
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
              onPressed: onToggleNotesMode,
              child: Text(
                'Notes',
                style: TextStyle(
                  fontWeight: state.notesMode
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: onClear,
              child: const Text('Clear'),
            ),
          ),
          SizedBox(
            height: 40,
            child: Tooltip(
              message: solutionTooltip,
              child: OutlinedButton(
                onPressed: onCheckOrSolution,
                child: const Text('Solution'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
