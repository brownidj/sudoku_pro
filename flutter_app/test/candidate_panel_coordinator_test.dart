import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/candidate_panel_coordinator.dart';
import 'package:flutter_app/app/candidate_panel_state.dart';
import 'package:flutter_app/domain/types.dart';

void main() {
  test('CandidatePanelCoordinator manages panel visibility and candidate state', () {
    const coordinator = CandidatePanelCoordinator();
    final board = Board.empty();
    const coord = Coord(1, 2);

    final visible = coordinator.show(board: board, coord: coord);
    expect(visible.visible, isTrue);
    expect(visible.coord, coord);
    expect(visible.digits, containsAll(const [1, 3, 5, 9, 0]));
    expect(visible.selectedNotes, isEmpty);

    final boardWithNotes = board.withCell(
      coord,
      Cell(value: null, given: false, notes: {1, 5}),
    );
    final refreshed = coordinator.refresh(
      board: boardWithNotes,
      current: visible,
    );
    expect(refreshed.visible, isTrue);
    expect(refreshed.coord, coord);
    expect(refreshed.selectedNotes, {1, 5});

    expect(coordinator.hide(), const TypeMatcher<CandidatePanelState>());
    expect(coordinator.hide().visible, isFalse);
    expect(coordinator.hide().coord, isNull);
    expect(coordinator.hide().digits, isEmpty);
  });
}
