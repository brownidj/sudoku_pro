import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/sudoku_controller.dart';

import 'support/sudoku_controller_test_support.dart';

void main() {
  test('Puzzle mode defaults, locking, and new game flow', () async {
    final fakeGameService = FakeGameService();
    final fakePrefs = FakePreferencesStore();
    final fakeSettings = FakeSettingsController(
      const SettingsState(
        notesMode: false,
        difficulty: 'easy',
        canChangeDifficulty: true,
        canChangePuzzleMode: true,
        styleName: 'Modern',
        contentMode: 'numbers',
        animalStyle: 'simple',
        puzzleMode: 'multi',
      ),
    );

    final controller = SudokuController(
      preferencesStore: fakePrefs,
      gameService: fakeGameService,
      settingsController: fakeSettings,
    );
    await controller.ready;

    expect(fakeGameService.newGameCalls, 1);
    expect(controller.hadSavedSessionAtLaunch, isFalse);

    controller.onSetDifficulty('medium');
    expect(fakeSettings.state.puzzleMode, 'unique');
    expect(fakeGameService.newGameCalls, 2);

    controller.onPuzzleModeChanged('multi');
    expect(fakeSettings.state.puzzleMode, 'multi');
    expect(fakeGameService.newGameCalls, 3);

    final editable = firstEditableCoord(controller.state);
    expect(editable, isNotNull);
    controller.onCellTapped(editable!);
    controller.onDigitPressed(1);
    expect(fakeSettings.state.canChangePuzzleMode, false);

    controller.onPuzzleModeChanged('unique');
    expect(fakeSettings.state.puzzleMode, 'multi');
    expect(fakeGameService.newGameCalls, 3);

    controller.onCheckSolution();
    expect(fakeSettings.state.canChangePuzzleMode, true);

    controller.onPuzzleModeChanged('unique');
    expect(fakeSettings.state.puzzleMode, 'unique');
    expect(fakeGameService.newGameCalls, 4);

    controller.onSetDifficulty('hard');
    expect(fakeSettings.state.puzzleMode, 'unique');

    controller.onContentModeChanged('butterflies');
    expect(fakeSettings.state.contentMode, 'butterflies');

    controller.onContentModeChanged('numbers');
    expect(fakeSettings.state.contentMode, 'numbers');
  });
}
