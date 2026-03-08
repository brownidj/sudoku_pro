import 'package:flutter_app/app/candidate_panel_state.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';

class UiStateMapperInput {
  final Board board;
  final SettingsState settings;
  final Coord? selected;
  final Set<Coord> conflicts;
  final Set<Coord> incorrectCells;
  final Set<Coord> correctCells;
  final Set<Coord> solutionAddedCells;
  final Grid? solutionGrid;
  final bool gameOver;
  final CandidatePanelState candidatePanel;

  const UiStateMapperInput({
    required this.board,
    required this.settings,
    required this.selected,
    required this.conflicts,
    required this.incorrectCells,
    required this.correctCells,
    required this.solutionAddedCells,
    required this.solutionGrid,
    required this.gameOver,
    required this.candidatePanel,
  });
}

class UiStateMapper {
  const UiStateMapper();

  UiState map(UiStateMapperInput input) {
    final cells = <List<CellVm>>[];
    final solution = input.solutionGrid;

    for (var r = 0; r < 9; r += 1) {
      final row = <CellVm>[];
      for (var c = 0; c < 9; c += 1) {
        final coord = Coord(r, c);
        final cell = input.board.cellAt(r, c);
        final notes = cell.notes.toList()..sort();
        final solutionValue = solution != null ? solution[r][c] : null;
        final solutionAdded = input.solutionAddedCells.contains(coord);
        final displayValue = solutionAdded && solutionValue != null
            ? solutionValue
            : (cell.value ?? solutionValue);

        row.add(
          CellVm(
            coord: coord,
            value: displayValue,
            given: cell.given && !solutionAdded,
            notes: notes,
            selected: coord == input.selected,
            conflicted: input.conflicts.contains(coord),
            incorrect: input.incorrectCells.contains(coord),
            solutionAdded: solutionAdded,
            correct: input.correctCells.contains(coord),
          ),
        );
      }
      cells.add(row);
    }

    return UiState(
      board: BoardVm(cells: cells),
      notesMode: input.settings.notesMode,
      difficulty: input.settings.difficulty,
      canChangeDifficulty: input.settings.canChangeDifficulty,
      canChangePuzzleMode: input.settings.canChangePuzzleMode,
      styleName: input.settings.styleName,
      contentMode: input.settings.contentMode,
      animalStyle: input.settings.animalStyle,
      puzzleMode: input.settings.puzzleMode,
      selected: input.selected,
      gameOver: input.gameOver,
      candidateVisible: input.candidatePanel.visible && !input.gameOver,
      candidateDigits: input.candidatePanel.digits,
      candidateSelectedNotes: input.candidatePanel.selectedNotes,
    );
  }
}
