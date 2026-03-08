import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/services/animal_asset_service.dart';
import 'package:flutter_app/ui/sudoku_screen.dart';
import 'package:flutter_app/ui/widgets/sudoku_board.dart';

import 'support/sudoku_controller_test_support.dart';

Coord _firstFilledCoord(SudokuController controller) {
  final state = controller.state;
  for (var r = 0; r < 9; r += 1) {
    for (var c = 0; c < 9; c += 1) {
      if (state.board.cells[r][c].value != null) {
        return Coord(r, c);
      }
    }
  }
  return const Coord(0, 0);
}

class FakeAnimalAssetService extends AnimalAssetService {
  const FakeAnimalAssetService();

  @override
  Future<AnimalAssetBundle> load() async {
    return const AnimalAssetBundle(
      animalImages: {'butterflies': {}},
      noteImages: {},
      butterflyDescriptions: {
        1: 'The Monarch butterfly test description found in North America.',
        2: 'The Swallowtail butterfly test description found in Europe and Asia.',
        3: 'The Blue Morpho butterfly test description found in South America.',
        4: 'The Glasswing butterfly test description found in Central America.',
        5: 'The Peacock butterfly test description found in Europe.',
        6: 'The Zebra Longwing butterfly test description found in the Americas.',
        7: 'The Sulphur butterfly test description found across the Americas.',
        8: 'The Leaf butterfly test description found in Asia.',
        9: 'The Metalmark butterfly test description found in the Americas.',
      },
    );
  }
}

Future<void> _longPressCell(
  WidgetTester tester,
  Coord coord,
) async {
  final boardRect = tester.getRect(find.byType(SudokuBoard));
  final cell = boardRect.width / 9.0;
  final target = Offset(
    boardRect.left + (coord.col + 0.5) * cell,
    boardRect.top + (coord.row + 0.5) * cell,
  );
  await tester.longPressAt(target);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('long-press behavior differs between numbers and butterflies modes', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1080, 1920));

    final controller = SudokuController(preferencesStore: FakePreferencesStore());
    await controller.ready;

    await tester.pumpWidget(
      MaterialApp(
        home: SudokuScreen(
          controller: controller,
          animalAssetService: const FakeAnimalAssetService(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final coord = _firstFilledCoord(controller);

    controller.onContentModeChanged('numbers');
    await tester.pumpAndSettle();
    await _longPressCell(tester, coord);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.textContaining('butterfly'), findsNothing);

    controller.onContentModeChanged('butterflies');
    await tester.pump();
    await tester.pump();
    await _longPressCell(tester, coord);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('butterfly'), findsOneWidget);
  });
}
