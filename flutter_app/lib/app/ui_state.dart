import 'package:flutter_app/domain/types.dart';

class CellVm {
  final Coord coord;
  final Digit? value;
  final bool given;
  final List<Digit> notes;
  final bool selected;
  final bool conflicted;
  final bool incorrect;
  final bool solutionAdded;
  final bool correct;

  const CellVm({
    required this.coord,
    required this.value,
    required this.given,
    required this.notes,
    required this.selected,
    required this.conflicted,
    required this.incorrect,
    required this.solutionAdded,
    required this.correct,
  });
}

class BoardVm {
  final List<List<CellVm>> cells;

  const BoardVm({required this.cells});
}

class UiState {
  final BoardVm board;
  final bool notesMode;
  final String difficulty;
  final bool canChangeDifficulty;
  final bool canChangePuzzleMode;
  final String styleName;
  final String contentMode;
  final String animalStyle;
  final String puzzleMode;
  final Coord? selected;
  final bool gameOver;
  final bool candidateVisible;
  final List<int> candidateDigits;
  final Set<int> candidateSelectedNotes;

  const UiState({
    required this.board,
    required this.notesMode,
    required this.difficulty,
    required this.canChangeDifficulty,
    required this.canChangePuzzleMode,
    required this.styleName,
    required this.contentMode,
    required this.animalStyle,
    required this.puzzleMode,
    required this.selected,
    required this.gameOver,
    required this.candidateVisible,
    required this.candidateDigits,
    required this.candidateSelectedNotes,
  });
}
