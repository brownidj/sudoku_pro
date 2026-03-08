import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';

class SudokuDrawer extends StatelessWidget {
  final UiState state;
  final ValueChanged<String> onPuzzleModeChanged;
  final ValueChanged<String> onSetDifficulty;
  final ValueChanged<String> onAnimalStyleChanged;
  final ValueChanged<String> onStyleChanged;

  const SudokuDrawer({
    super.key,
    required this.state,
    required this.onPuzzleModeChanged,
    required this.onSetDifficulty,
    required this.onAnimalStyleChanged,
    required this.onStyleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final canEditPuzzleMode =
        state.canChangePuzzleMode && state.difficulty != 'hard';

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ZuDoKu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Puzzle Mode',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            RadioListTile<String>(
              title: const Text('Unique'),
              value: 'unique',
              groupValue: state.puzzleMode,
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: canEditPuzzleMode ? _handleModeChanged : null,
            ),
            RadioListTile<String>(
              title: const Text('Multi'),
              value: 'multi',
              groupValue: state.puzzleMode,
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: canEditPuzzleMode ? _handleModeChanged : null,
            ),
            const Divider(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Difficulty',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            RadioListTile<String>(
              title: const Text('Easy'),
              value: 'easy',
              groupValue: state.difficulty,
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: state.canChangeDifficulty
                  ? _handleDifficultyChanged
                  : null,
            ),
            RadioListTile<String>(
              title: const Text('Medium'),
              value: 'medium',
              groupValue: state.difficulty,
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: state.canChangeDifficulty
                  ? _handleDifficultyChanged
                  : null,
            ),
            RadioListTile<String>(
              title: const Text('Hard'),
              value: 'hard',
              groupValue: state.difficulty,
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: state.canChangeDifficulty
                  ? _handleDifficultyChanged
                  : null,
            ),
            const Divider(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Animals',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            RadioListTile<String>(
              title: const Text('Cute'),
              value: 'cute',
              groupValue: state.animalStyle,
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: _handleAnimalStyleChanged,
            ),
            RadioListTile<String>(
              title: const Text('Simple'),
              value: 'simple',
              groupValue: state.animalStyle,
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: _handleAnimalStyleChanged,
            ),
            const Divider(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Puzzle Style',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            RadioListTile<String>(
              title: const Text('Modern'),
              value: 'Modern',
              groupValue: state.styleName,
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: _handleStyleChanged,
            ),
            RadioListTile<String>(
              title: const Text('Classic'),
              value: 'Classic',
              groupValue: state.styleName,
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: _handleStyleChanged,
            ),
            RadioListTile<String>(
              title: const Text('High Contrast'),
              value: 'High Contrast',
              groupValue: state.styleName,
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: _handleStyleChanged,
            ),
          ],
        ),
      ),
    );
  }

  void _handleModeChanged(String? value) {
    if (value == null) {
      return;
    }
    onPuzzleModeChanged(value);
  }

  void _handleDifficultyChanged(String? value) {
    if (value == null) {
      return;
    }
    onSetDifficulty(value);
  }

  void _handleAnimalStyleChanged(String? value) {
    if (value == null) {
      return;
    }
    onAnimalStyleChanged(value);
  }

  void _handleStyleChanged(String? value) {
    if (value == null) {
      return;
    }
    onStyleChanged(value);
  }
}
