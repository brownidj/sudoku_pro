part of 'sudoku_controller.dart';

extension SudokuControllerSettingsCommands on SudokuController {
  void onSetDifficulty(String difficulty) {
    final d = difficulty.trim().toLowerCase();
    if (!['easy', 'medium', 'hard'].contains(d)) {
      _render('Unknown difficulty: $difficulty');
      return;
    }
    if (!_settings.state.canChangeDifficulty) {
      _render('Finish or start a new game before changing difficulty');
      return;
    }
    if (!_settings.setDifficulty(d)) {
      return;
    }
    _settings.setPuzzleMode(_defaultPuzzleModeForDifficulty(d));
    _startPuzzle();
  }

  void onStyleChanged(String styleName) {
    _settings.setStyleName(styleName);
    _render('Style: $styleName');
  }

  void onContentModeChanged(String mode) {
    final next = switch (mode) {
      'animals' => 'animals',
      'butterflies' => 'butterflies',
      'ocean' => 'ocean',
      'japanese' => 'japanese',
      'numbers' => 'numbers',
      _ => _settings.state.contentMode,
    };
    _settings.setContentMode(next);
    _saveGameSession();
    _render(
      'Mode: ${switch (next) {
        'animals' => 'Animals',
        'butterflies' => 'Butterflies',
        'ocean' => 'Ocean',
        'japanese' => 'Japanese',
        'numbers' => 'Numbers',
        _ => next,
      }}',
    );
  }

  void onAnimalStyleChanged(String style) {
    final next = style == 'cute' ? 'cute' : 'simple';
    _settings.setAnimalStyle(next);
    _render('Animal style: $next');
  }

  void onPuzzleModeChanged(String mode) {
    if (!_settings.state.canChangePuzzleMode) {
      _render('Finish or check the game before changing puzzle mode');
      return;
    }
    if (_settings.state.difficulty == 'hard') {
      _settings.setPuzzleMode('unique');
      _render('Puzzle mode: unique');
      return;
    }
    final next = mode == 'unique' ? 'unique' : 'multi';
    _settings.setPuzzleMode(next);
    _startPuzzle();
  }

  String _defaultPuzzleModeForDifficulty(String difficulty) {
    if (difficulty == 'easy') {
      return 'multi';
    }
    return 'unique';
  }

  void _applyRestoredSettings(SettingsState settings) {
    _settings.setDifficultyLocked(false);
    _settings.setPuzzleModeLocked(false);
    _settings.setStyleName(settings.styleName);
    _settings.setContentMode(settings.contentMode);
    _settings.setAnimalStyle(settings.animalStyle);
    _settings.setNotesMode(settings.notesMode);
    _settings.setDifficulty(settings.difficulty);
    _settings.setPuzzleMode(settings.puzzleMode);
    _settings.setDifficultyLocked(!settings.canChangeDifficulty);
    _settings.setPuzzleModeLocked(!settings.canChangePuzzleMode);
  }
}
