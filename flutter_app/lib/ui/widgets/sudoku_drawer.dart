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
    final sections = [
      _DrawerRadioSection(
        heading: 'Puzzle Mode',
        groupValue: state.puzzleMode,
        onChanged: _handleModeChanged,
        options: [
          _DrawerRadioOption(
            title: 'Unique',
            value: 'unique',
            enabled: canEditPuzzleMode,
          ),
          _DrawerRadioOption(
            title: 'Multi',
            value: 'multi',
            enabled: canEditPuzzleMode,
          ),
        ],
      ),
      _DrawerRadioSection(
        heading: 'Difficulty',
        groupValue: state.difficulty,
        onChanged: _handleDifficultyChanged,
        options: [
          _DrawerRadioOption(
            title: 'Easy',
            value: 'easy',
            enabled: state.canChangeDifficulty,
          ),
          _DrawerRadioOption(
            title: 'Medium',
            value: 'medium',
            enabled: state.canChangeDifficulty,
          ),
          _DrawerRadioOption(
            title: 'Hard',
            value: 'hard',
            enabled: state.canChangeDifficulty,
          ),
        ],
      ),
      _DrawerRadioSection(
        heading: 'Animals',
        groupValue: state.animalStyle,
        onChanged: _handleAnimalStyleChanged,
        options: const [
          _DrawerRadioOption(title: 'Cute', value: 'cute'),
          _DrawerRadioOption(title: 'Simple', value: 'simple'),
        ],
      ),
      _DrawerRadioSection(
        heading: 'Puzzle Style',
        groupValue: state.styleName,
        onChanged: _handleStyleChanged,
        options: const [
          _DrawerRadioOption(title: 'Modern', value: 'Modern'),
          _DrawerRadioOption(title: 'Classic', value: 'Classic'),
          _DrawerRadioOption(
            title: 'High Contrast',
            value: 'High Contrast',
          ),
        ],
      ),
    ];

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
            for (var i = 0; i < sections.length; i += 1) ...[
              _DrawerSectionWidget(section: sections[i]),
              if (i != sections.length - 1) const Divider(height: 16),
            ],
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

class _DrawerRadioOption {
  final String title;
  final String value;
  final bool enabled;

  const _DrawerRadioOption({
    required this.title,
    required this.value,
    this.enabled = true,
  });
}

class _DrawerRadioSection {
  final String heading;
  final String groupValue;
  final ValueChanged<String?> onChanged;
  final List<_DrawerRadioOption> options;

  const _DrawerRadioSection({
    required this.heading,
    required this.groupValue,
    required this.onChanged,
    required this.options,
  });
}

class _DrawerSectionWidget extends StatelessWidget {
  final _DrawerRadioSection section;

  const _DrawerSectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              section.heading,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        RadioGroup<String>(
          groupValue: section.groupValue,
          onChanged: section.onChanged,
          child: Column(
            children: [
              for (final option in section.options)
                RadioListTile<String>(
                  title: Text(option.title),
                  value: option.value,
                  enabled: option.enabled,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
