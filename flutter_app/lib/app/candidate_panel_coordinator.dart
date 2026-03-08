import 'package:flutter_app/app/candidate_panel_state.dart';
import 'package:flutter_app/domain/types.dart';

class CandidatePanelCoordinator {
  const CandidatePanelCoordinator();

  CandidatePanelState show({
    required Board board,
    required Coord coord,
  }) {
    return CandidatePanelState(
      visible: true,
      coord: coord,
      digits: [..._possibleDigits(board, coord), 0],
      selectedNotes: board.cellAtCoord(coord).notes,
    );
  }

  CandidatePanelState refresh({
    required Board board,
    required CandidatePanelState current,
  }) {
    final coord = current.coord;
    if (!current.visible || coord == null) {
      return const CandidatePanelState.hidden();
    }
    return current.copyWith(
      digits: [..._possibleDigits(board, coord), 0],
      selectedNotes: board.cellAtCoord(coord).notes,
    );
  }

  CandidatePanelState hide() {
    return const CandidatePanelState.hidden();
  }

  List<int> _possibleDigits(Board board, Coord coord) {
    final used = <int>{};
    final boxRow = (coord.row ~/ 3) * 3;
    final boxCol = (coord.col ~/ 3) * 3;
    for (var r = boxRow; r < boxRow + 3; r += 1) {
      for (var c = boxCol; c < boxCol + 3; c += 1) {
        final value = board.cellAt(r, c).value;
        if (value != null) {
          used.add(value);
        }
      }
    }

    final candidates = <int>[];
    for (var d = 1; d <= 9; d += 1) {
      if (!used.contains(d)) {
        candidates.add(d);
      }
    }
    return candidates;
  }
}
