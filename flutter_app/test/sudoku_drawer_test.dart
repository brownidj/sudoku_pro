import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/widgets/sudoku_drawer.dart';

UiState _state({
  required bool canChangeDifficulty,
  required bool canChangePuzzleMode,
  required String difficulty,
}) {
  final cells = List<List<CellVm>>.generate(
    9,
    (r) => List<CellVm>.generate(
      9,
      (c) => CellVm(
        coord: Coord(r, c),
        value: null,
        given: false,
        notes: const [],
        selected: false,
        conflicted: false,
        incorrect: false,
        solutionAdded: false,
        correct: false,
      ),
      growable: false,
    ),
    growable: false,
  );

  return UiState(
    board: BoardVm(cells: cells),
    notesMode: false,
    difficulty: difficulty,
    canChangeDifficulty: canChangeDifficulty,
    canChangePuzzleMode: canChangePuzzleMode,
    styleName: 'Modern',
    contentMode: 'numbers',
    animalStyle: 'simple',
    puzzleMode: 'multi',
    selected: null,
    gameOver: false,
    candidateVisible: false,
    candidateDigits: const [],
    candidateSelectedNotes: const {},
  );
}

void main() {
  testWidgets('locked puzzle mode and difficulty radios are disabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SudokuDrawer(
          state: _state(
            canChangeDifficulty: false,
            canChangePuzzleMode: false,
            difficulty: 'medium',
          ),
          onPuzzleModeChanged: (_) {},
          onSetDifficulty: (_) {},
          onAnimalStyleChanged: (_) {},
          onStyleChanged: (_) {},
        ),
      ),
    );

    final uniqueRadio = tester.widget<RadioListTile<String>>(
      find.widgetWithText(RadioListTile<String>, 'Unique'),
    );
    final multiRadio = tester.widget<RadioListTile<String>>(
      find.widgetWithText(RadioListTile<String>, 'Multi'),
    );
    final easyRadio = tester.widget<RadioListTile<String>>(
      find.widgetWithText(RadioListTile<String>, 'Easy'),
    );
    final mediumRadio = tester.widget<RadioListTile<String>>(
      find.widgetWithText(RadioListTile<String>, 'Medium'),
    );
    final hardRadio = tester.widget<RadioListTile<String>>(
      find.widgetWithText(RadioListTile<String>, 'Hard'),
    );

    expect(uniqueRadio.enabled, isFalse);
    expect(multiRadio.enabled, isFalse);
    expect(easyRadio.enabled, isFalse);
    expect(mediumRadio.enabled, isFalse);
    expect(hardRadio.enabled, isFalse);
  });

  testWidgets('hard difficulty disables puzzle mode radios', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SudokuDrawer(
          state: _state(
            canChangeDifficulty: true,
            canChangePuzzleMode: true,
            difficulty: 'hard',
          ),
          onPuzzleModeChanged: (_) {},
          onSetDifficulty: (_) {},
          onAnimalStyleChanged: (_) {},
          onStyleChanged: (_) {},
        ),
      ),
    );

    final uniqueRadio = tester.widget<RadioListTile<String>>(
      find.widgetWithText(RadioListTile<String>, 'Unique'),
    );
    final multiRadio = tester.widget<RadioListTile<String>>(
      find.widgetWithText(RadioListTile<String>, 'Multi'),
    );
    final easyRadio = tester.widget<RadioListTile<String>>(
      find.widgetWithText(RadioListTile<String>, 'Easy'),
    );

    expect(uniqueRadio.enabled, isFalse);
    expect(multiRadio.enabled, isFalse);
    expect(easyRadio.enabled, isTrue);
  });
}
