import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/sudoku_controller.dart';

import 'support/sudoku_controller_test_support.dart';

void main() {
  test('board and candidate actions still notify listeners', () async {
    final controller = SudokuController(preferencesStore: FakePreferencesStore());
    await controller.ready;
    controller.onContentModeChanged('numbers');

    final coord = firstEditableCoord(controller.state)!;
    var listenerCalls = 0;
    controller.addListener(() {
      listenerCalls += 1;
    });

    controller.onBoardCellTapped(coord);
    expect(listenerCalls, greaterThan(0));

    final afterSelection = listenerCalls;
    controller.onCandidateDigitPressed(1);
    expect(listenerCalls, greaterThan(afterSelection));
  });
}
