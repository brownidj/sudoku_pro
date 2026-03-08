import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/ui/services/animal_asset_service.dart';
import 'package:flutter_app/ui/sudoku_screen.dart';
import 'package:flutter_app/ui/widgets/sudoku_board_area.dart';

import 'support/sudoku_controller_test_support.dart';

class FakeAnimalAssetService extends AnimalAssetService {
  FakeAnimalAssetService(this._loader);

  final Future<AnimalAssetBundle> Function() _loader;

  @override
  Future<AnimalAssetBundle> load() => _loader();
}

void main() {
  testWidgets('shows Please wait until animal assets load', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1080, 1920));
    final completer = Completer<AnimalAssetBundle>();
    final controller = SudokuController(preferencesStore: FakePreferencesStore());
    await controller.ready;

    await tester.pumpWidget(
      MaterialApp(
        home: SudokuScreen(
          controller: controller,
          animalAssetService: FakeAnimalAssetService(() => completer.future),
        ),
      ),
    );

    expect(find.text('Please wait...'), findsOneWidget);

    completer.complete(const AnimalAssetBundle(animalImages: {}, noteImages: {}));
    await tester.pump();

    expect(find.text('Please wait...'), findsNothing);
    expect(find.byType(SudokuBoardArea), findsOneWidget);
  });

  testWidgets('loading screen is dismissed even if asset loading fails', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1080, 1920));
    final controller = SudokuController(preferencesStore: FakePreferencesStore());
    await controller.ready;

    await tester.pumpWidget(
      MaterialApp(
        home: SudokuScreen(
          controller: controller,
          animalAssetService: FakeAnimalAssetService(
            () => Future<AnimalAssetBundle>.error(Exception('asset load failed')),
          ),
        ),
      ),
    );

    expect(find.text('Please wait...'), findsOneWidget);

    await tester.pump();
    await tester.pump();

    expect(find.text('Please wait...'), findsNothing);
    expect(find.byType(SudokuBoardArea), findsOneWidget);
  });
}
