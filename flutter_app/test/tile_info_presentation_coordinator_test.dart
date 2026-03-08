import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/tile_info_presentation_coordinator.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';

UiState _state({
  required String contentMode,
  int? value,
}) {
  final cells = List<List<CellVm>>.generate(
    9,
    (r) => List<CellVm>.generate(
      9,
      (c) => CellVm(
        coord: Coord(r, c),
        value: r == 0 && c == 0 ? value : null,
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
    difficulty: 'easy',
    canChangeDifficulty: true,
    canChangePuzzleMode: true,
    styleName: 'Modern',
    contentMode: contentMode,
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
  test('returns butterfly dialog presentation in butterflies mode', () {
    const coordinator = TileInfoPresentationCoordinator();
    final presentation = coordinator.forLongPress(
      state: _state(contentMode: 'butterflies', value: 1),
      coord: const Coord(0, 0),
      butterflyDescriptions: const {1: 'The Monarch butterfly test description.'},
    );

    expect(presentation, isA<ButterflyDialogPresentation>());
    final dialog = presentation as ButterflyDialogPresentation;
    expect(dialog.digit, 1);
    expect(dialog.description, contains('Monarch'));
  });

  test('returns tooltip presentation in animal mode', () {
    const coordinator = TileInfoPresentationCoordinator();
    final presentation = coordinator.forLongPress(
      state: _state(contentMode: 'animals', value: 1),
      coord: const Coord(0, 0),
      butterflyDescriptions: const {},
    );

    expect(presentation, isA<TooltipTileInfoPresentation>());
  });

  test('returns no presentation for empty or number cells', () {
    const coordinator = TileInfoPresentationCoordinator();

    expect(
      coordinator.forLongPress(
        state: _state(contentMode: 'numbers', value: 1),
        coord: const Coord(0, 0),
        butterflyDescriptions: const {},
      ),
      isA<NoTileInfoPresentation>(),
    );

    expect(
      coordinator.forLongPress(
        state: _state(contentMode: 'animals', value: null),
        coord: const Coord(0, 0),
        butterflyDescriptions: const {},
      ),
      isA<NoTileInfoPresentation>(),
    );
  });
}
