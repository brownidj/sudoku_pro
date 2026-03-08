import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/preferences_store.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/application/game_service.dart';
import 'package:flutter_app/application/results.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/launch_screen.dart';

class FakePreferencesStore extends PreferencesStore {
  String? savedSession;

  FakePreferencesStore({this.savedSession});

  @override
  Future<AppPreferences> load() async {
    return const AppPreferences(
      animalStyle: null,
      contentMode: null,
      styleName: null,
      difficulty: null,
      puzzleMode: null,
    );
  }

  @override
  Future<void> saveAnimalStyle(String value) async {}

  @override
  Future<void> saveContentMode(String value) async {}

  @override
  Future<void> saveStyleName(String value) async {}

  @override
  Future<void> saveDifficulty(String value) async {}

  @override
  Future<void> savePuzzleMode(String value) async {}

  @override
  Future<String?> loadGameSession() async => savedSession;

  @override
  Future<void> saveGameSession(String value) async {
    savedSession = value;
  }
}

class SpyGameService extends GameService {
  int newGameCalls = 0;

  @override
  MoveResult newGameFromGrid(Grid grid) {
    newGameCalls += 1;
    return super.newGameFromGrid(grid);
  }
}

Coord? _firstEditableCoord(UiState state) {
  for (var r = 0; r < 9; r += 1) {
    for (var c = 0; c < 9; c += 1) {
      final cell = state.board.cells[r][c];
      if (!cell.given) {
        return Coord(r, c);
      }
    }
  }
  return null;
}

Future<FakePreferencesStore> _buildPrefsWithSavedSession() async {
  final prefs = FakePreferencesStore();
  final seed = SudokuController(preferencesStore: prefs);
  await seed.ready;
  final editable = _firstEditableCoord(seed.state);
  if (editable != null) {
    seed.onCellTapped(editable);
    seed.onDigitPressed(1);
  }
  return prefs;
}

Future<FakePreferencesStore> _buildPrefsWithCompletedSession() async {
  final prefs = FakePreferencesStore();
  final seed = SudokuController(preferencesStore: prefs);
  await seed.ready;
  seed.onShowSolution();
  return prefs;
}

void main() {
  testWidgets('LaunchScreen shows only Play when no saved session existed', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1080, 1920));
    final controller = SudokuController(
      preferencesStore: FakePreferencesStore(),
    );
    await controller.ready;

    await tester.pumpWidget(
      MaterialApp(home: LaunchScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Resume'), findsNothing);
    expect(find.text('New game'), findsNothing);
  });

  testWidgets('LaunchScreen shows Resume and New game when session exists', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1080, 1920));
    final prefs = await _buildPrefsWithSavedSession();
    final service = SpyGameService();
    final controller = SudokuController(
      preferencesStore: prefs,
      gameService: service,
    );
    await controller.ready;

    await tester.pumpWidget(
      MaterialApp(home: LaunchScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Play'), findsNothing);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('New game'), findsOneWidget);
  });

  testWidgets(
    'LaunchScreen shows only Play when saved session is already finished',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      final prefs = await _buildPrefsWithCompletedSession();
      final controller = SudokuController(preferencesStore: prefs);
      await controller.ready;

      await tester.pumpWidget(
        MaterialApp(home: LaunchScreen(controller: controller)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Play'), findsOneWidget);
      expect(find.text('Resume'), findsNothing);
      expect(find.text('New game'), findsNothing);
    },
  );

  testWidgets('Resume does not start a new game', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1080, 1920));
    final prefs = await _buildPrefsWithSavedSession();

    final resumeService = SpyGameService();
    final resumeController = SudokuController(
      preferencesStore: prefs,
      gameService: resumeService,
    );
    await resumeController.ready;
    expect(resumeService.newGameCalls, 0);

    await tester.pumpWidget(
      MaterialApp(home: LaunchScreen(controller: resumeController)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resume'));
    await tester.pump();
    expect(resumeService.newGameCalls, 0);
  });

  testWidgets('New game starts a new game', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1080, 1920));
    final prefs = await _buildPrefsWithSavedSession();
    final newGameService = SpyGameService();
    final newGameController = SudokuController(
      preferencesStore: prefs,
      gameService: newGameService,
    );
    await newGameController.ready;
    expect(newGameService.newGameCalls, 0);

    await tester.pumpWidget(
      MaterialApp(home: LaunchScreen(controller: newGameController)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('New game'));
    await tester.pump();
    expect(newGameService.newGameCalls, 1);
  });
}
