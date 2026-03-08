import 'package:flutter_app/app/preferences_store.dart';
import 'package:flutter_app/app/settings_state.dart';

class SettingsController {
  final PreferencesStore _prefs;
  final void Function() _onChange;

  SettingsState _state = const SettingsState(
    notesMode: false,
    difficulty: 'easy',
    canChangeDifficulty: true,
    canChangePuzzleMode: true,
    styleName: 'Modern',
    contentMode: 'animals',
    animalStyle: 'cute',
    puzzleMode: 'multi',
  );

  SettingsController(this._prefs, this._onChange);

  SettingsState get state => _state;

  Future<void> load() async {
    final prefs = await _prefs.load();
    var next = _state;
    if (prefs.animalStyle == 'cute' || prefs.animalStyle == 'simple') {
      next = next.copyWith(animalStyle: prefs.animalStyle);
    }
    if (prefs.contentMode == 'animals' ||
        prefs.contentMode == 'butterflies' ||
        prefs.contentMode == 'numbers') {
      next = next.copyWith(contentMode: prefs.contentMode);
    }
    if (prefs.styleName != null && prefs.styleName!.isNotEmpty) {
      next = next.copyWith(styleName: prefs.styleName);
    }
    if (prefs.difficulty != null &&
        ['easy', 'medium', 'hard'].contains(prefs.difficulty)) {
      next = next.copyWith(difficulty: prefs.difficulty);
    }
    if (prefs.puzzleMode == 'unique' || prefs.puzzleMode == 'multi') {
      next = next.copyWith(puzzleMode: prefs.puzzleMode);
    } else {
      next = next.copyWith(
        puzzleMode: _defaultPuzzleModeForDifficulty(next.difficulty),
      );
    }
    if (next.difficulty == 'hard' && next.puzzleMode != 'unique') {
      next = next.copyWith(puzzleMode: 'unique');
    }
    _setState(next);
  }

  void toggleNotesMode() {
    _setState(_state.copyWith(notesMode: !_state.notesMode));
  }

  void setNotesMode(bool enabled) {
    if (_state.notesMode == enabled) {
      return;
    }
    _setState(_state.copyWith(notesMode: enabled));
  }

  bool setDifficulty(String difficulty) {
    if (!_state.canChangeDifficulty) {
      return false;
    }
    _setState(_state.copyWith(difficulty: difficulty));
    _prefs.saveDifficulty(difficulty);
    return true;
  }

  void setDifficultyLocked(bool locked) {
    _setState(_state.copyWith(canChangeDifficulty: !locked));
  }

  void setPuzzleModeLocked(bool locked) {
    _setState(_state.copyWith(canChangePuzzleMode: !locked));
  }

  void setStyleName(String styleName) {
    _setState(_state.copyWith(styleName: styleName));
    _prefs.saveStyleName(styleName);
  }

  void setContentMode(String mode) {
    _setState(_state.copyWith(contentMode: mode));
    _prefs.saveContentMode(mode);
  }

  void setAnimalStyle(String style) {
    _setState(_state.copyWith(animalStyle: style));
    _prefs.saveAnimalStyle(style);
  }

  void setPuzzleMode(String mode) {
    _setState(_state.copyWith(puzzleMode: mode));
    _prefs.savePuzzleMode(mode);
  }

  void _setState(SettingsState next) {
    _state = next;
    _onChange();
  }

  String _defaultPuzzleModeForDifficulty(String difficulty) {
    if (difficulty == 'easy') {
      return 'multi';
    }
    return 'unique';
  }
}
