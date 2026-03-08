import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/board_edit_coordinator.dart';
import 'package:flutter_app/app/controller_startup_coordinator.dart';
import 'package:flutter_app/app/game_session_service.dart';
import 'package:flutter_app/application/game_service.dart';
import 'package:flutter_app/application/puzzles.dart' as puzzles;
import 'package:flutter_app/application/results.dart';
import 'package:flutter_app/app/check_service.dart';
import 'package:flutter_app/app/grid_utils.dart';
import 'package:flutter_app/app/settings_controller.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/solution_check_coordinator.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/app/ui_state_mapper.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/app/preferences_store.dart';

class SudokuController extends ChangeNotifier {
  final GameService _service;
  late SettingsController _settings;
  late final GameSessionService _sessionService;
  late final SolutionCheckCoordinator _solutionCoordinator;
  late final UiStateMapper _uiStateMapper;
  late final BoardEditCoordinator _boardEditCoordinator;
  late final ControllerStartupCoordinator _startupCoordinator;
  late History _history;
  Coord? _selected;
  Set<Coord> _lastConflicts = {};
  // Settings are managed by SettingsController.
  bool _gameOver = false;
  Set<Coord> _incorrectCells = {};
  Set<Coord> _solutionAddedCells = {};
  Set<Coord> _correctCells = {};
  Grid? _solutionGrid;
  Grid? _initialGrid;
  bool _hadSavedSessionAtLaunch = false;

  SudokuController({
    PreferencesStore? preferencesStore,
    GameService? gameService,
    CheckService? checkService,
    GridUtils? gridUtils,
    SettingsController? settingsController,
    GameSessionService? gameSessionService,
    SolutionCheckCoordinator? solutionCheckCoordinator,
    UiStateMapper? uiStateMapper,
    BoardEditCoordinator? boardEditCoordinator,
    ControllerStartupCoordinator? startupCoordinator,
  }) : _service = gameService ?? GameService() {
    final prefs = preferencesStore ?? PreferencesStore();
    final resolvedGridUtils = gridUtils ?? GridUtils();
    final resolvedCheckService = checkService ?? CheckService();
    _settings =
        settingsController ?? SettingsController(prefs, notifyListeners);
    _sessionService =
        gameSessionService ?? GameSessionService(prefs, resolvedGridUtils);
    _solutionCoordinator =
        solutionCheckCoordinator ??
        SolutionCheckCoordinator(resolvedCheckService, resolvedGridUtils);
    _uiStateMapper = uiStateMapper ?? const UiStateMapper();
    _boardEditCoordinator =
        boardEditCoordinator ?? BoardEditCoordinator(_service);
    _startupCoordinator =
        startupCoordinator ??
        ControllerStartupCoordinator(_settings, _sessionService);
    _history = _service.initialHistory();
    ready = _initialize();
  }

  late final Future<void> ready;
  bool get hadSavedSessionAtLaunch => _hadSavedSessionAtLaunch;

  Future<void> _initialize() async {
    final startup = await _startupCoordinator.initialize();
    final restoredSession = startup.restoredSession;
    _hadSavedSessionAtLaunch = startup.shouldResumeSession;
    if (startup.shouldResumeSession && restoredSession != null) {
      _history = restoredSession.history;
      _lastConflicts = {};
      _incorrectCells = {};
      _correctCells = {};
      _solutionAddedCells = {};
      _solutionGrid = null;
      _selected = restoredSession.selected;
      _gameOver = restoredSession.gameOver;
      _initialGrid = restoredSession.initialGrid;
      _applyRestoredSettings(restoredSession.settings);
      notifyListeners();
      return;
    }
    if (restoredSession != null) {
      _applyRestoredSettings(restoredSession.settings);
    }
    start();
  }

  UiState get state => _buildState();

  void start() {
    _startPuzzle();
  }

  void onCellTapped(Coord coord) {
    if (_gameOver) {
      return;
    }
    final cell = _history.present.board.cellAtCoord(coord);
    if (cell.given) {
      return;
    }
    _selected = coord;
    _render('Cell selected');
  }

  void onDigitPressed(Digit digit) {
    _applyBoardEditOutcome(
      _boardEditCoordinator.onDigitPressed(
        gameOver: _gameOver,
        selected: _selected,
        notesMode: _settings.state.notesMode,
        history: _history,
        digit: digit,
        canChangeDifficulty: _settings.state.canChangeDifficulty,
        canChangePuzzleMode: _settings.state.canChangePuzzleMode,
      ),
    );
  }

  void onPlaceDigit(Digit digit) {
    _applyBoardEditOutcome(
      _boardEditCoordinator.onPlaceDigit(
        gameOver: _gameOver,
        selected: _selected,
        history: _history,
        digit: digit,
        canChangeDifficulty: _settings.state.canChangeDifficulty,
        canChangePuzzleMode: _settings.state.canChangePuzzleMode,
      ),
    );
  }

  void onClearPressed() {
    _applyBoardEditOutcome(
      _boardEditCoordinator.onClearPressed(
        gameOver: _gameOver,
        selected: _selected,
        notesMode: _settings.state.notesMode,
        history: _history,
        canChangeDifficulty: _settings.state.canChangeDifficulty,
        canChangePuzzleMode: _settings.state.canChangePuzzleMode,
      ),
    );
  }

  void onToggleNotesMode() {
    if (_gameOver) {
      return;
    }
    _settings.toggleNotesMode();
    _render(_settings.state.notesMode ? 'Notes mode on' : 'Notes mode off');
  }

  void setNotesMode(bool enabled) {
    if (_gameOver) {
      return;
    }
    _settings.setNotesMode(enabled);
    _render(_settings.state.notesMode ? 'Notes mode on' : 'Notes mode off');
  }

  void onNewGame() {
    _startPuzzle();
  }

  void onSetDifficulty(String difficulty) {
    final d = difficulty.trim().toLowerCase();
    if (!['easy', 'medium', 'hard'].contains(d)) {
      _render('Unknown difficulty: $difficulty');
      return;
    }
    if (!_settings.state.canChangeDifficulty) {
      _render('Finish or start a new game before changing difficulty');
      return;
    }
    if (!_settings.setDifficulty(d)) {
      return;
    }
    _settings.setPuzzleMode(_defaultPuzzleModeForDifficulty(d));
    _startPuzzle();
  }

  void onStyleChanged(String styleName) {
    _settings.setStyleName(styleName);
    _render('Style: $styleName');
  }

  void onContentModeChanged(String mode) {
    final next = switch (mode) {
      'animals' => 'animals',
      'butterflies' => 'butterflies',
      _ => 'numbers',
    };
    _settings.setContentMode(next);
    _render(
      'Mode: ${switch (next) {
        'animals' => 'Animals',
        'butterflies' => 'Butterflies',
        _ => 'Numbers',
      }}',
    );
  }

  void onAnimalStyleChanged(String style) {
    final next = style == 'cute' ? 'cute' : 'simple';
    _settings.setAnimalStyle(next);
    _render('Animal style: $next');
  }

  void onPuzzleModeChanged(String mode) {
    if (!_settings.state.canChangePuzzleMode) {
      _render('Finish or check the game before changing puzzle mode');
      return;
    }
    if (_settings.state.difficulty == 'hard') {
      _settings.setPuzzleMode('unique');
      _render('Puzzle mode: unique');
      return;
    }
    final next = mode == 'unique' ? 'unique' : 'multi';
    _settings.setPuzzleMode(next);
    _startPuzzle();
  }

  void onCheckSolution() {
    if (_gameOver) {
      return;
    }
    final result = _solutionCoordinator.check(
      history: _history,
      initialGrid: _initialGrid,
      givens: _givenCoords(),
    );
    _incorrectCells = result.incorrect;
    _correctCells = result.correct;
    _solutionGrid = null;
    _solutionAddedCells = {};
    _selected = null;
    _gameOver = true;
    _settings.setPuzzleModeLocked(false);
    _saveGameSession();
    _render('Check complete');
  }

  void onShowSolution() {
    if (!_gameOver) {
      onCheckSolution();
    }
    if (!_gameOver) {
      return;
    }
    final result = _solutionCoordinator.showSolution(
      history: _history,
      initialGrid: _initialGrid,
      givens: _givenCoords(),
    );
    _incorrectCells = result.incorrect;
    _correctCells = result.correct;
    _solutionGrid = result.solutionGrid;
    _solutionAddedCells = result.solutionAdded;
    _selected = null;
    _settings.setPuzzleModeLocked(false);
    _saveGameSession();
    _render('Solution');
  }

  void _applyBoardEditOutcome(BoardEditOutcome outcome) {
    if (outcome.statusMessage != null) {
      _render(outcome.statusMessage!);
      return;
    }
    if (outcome.result == null) {
      return;
    }

    _applyResult(outcome.result!);
    if (outcome.lockDifficulty) {
      _settings.setDifficultyLocked(true);
    }
    if (outcome.lockPuzzleMode) {
      _settings.setPuzzleModeLocked(true);
    }
  }

  void _applyResult(MoveResult res, {String? statusOverride}) {
    _history = res.history;
    _lastConflicts = res.conflicts;
    _saveGameSession();
    _render(statusOverride ?? res.message);
  }

  void _render(String status) {
    notifyListeners();
  }

  UiState _buildState() {
    return _uiStateMapper.map(
      UiStateMapperInput(
        board: _history.present.board,
        settings: _settings.state,
        selected: _selected,
        conflicts: _lastConflicts,
        incorrectCells: _incorrectCells,
        correctCells: _correctCells,
        solutionAddedCells: _solutionAddedCells,
        solutionGrid: _solutionGrid,
        gameOver: _gameOver,
      ),
    );
  }

  String _defaultPuzzleModeForDifficulty(String difficulty) {
    if (difficulty == 'easy') {
      return 'multi';
    }
    return 'unique';
  }

  Set<Coord> _givenCoords() {
    final givens = <Coord>{};
    final board = _history.present.board;
    for (var r = 0; r < 9; r += 1) {
      for (var c = 0; c < 9; c += 1) {
        if (board.cellAt(r, c).given) {
          givens.add(Coord(r, c));
        }
      }
    }
    return givens;
  }

  void _saveGameSession() {
    _sessionService.save(
      history: _history,
      selected: _selected,
      gameOver: _gameOver,
      initialGrid: _initialGrid,
      settings: _settings.state,
    );
  }

  void _startPuzzle() {
    final puzzle = puzzles.generatePuzzle(
      _settings.state.difficulty,
      mode: _settings.state.puzzleMode,
    );
    final res = _service.newGameFromGrid(puzzle.grid);
    _resetBoardFlags();
    _initialGrid = List<List<Digit?>>.generate(9, (r) {
      return List<Digit?>.generate(
        9,
        (c) => puzzle.grid[r][c],
        growable: false,
      );
    }, growable: false);
    _applyResult(
      res,
      statusOverride: 'New game (${puzzle.difficulty}): ${puzzle.puzzleId}',
    );
  }

  void _resetBoardFlags() {
    _selected = null;
    _lastConflicts = {};
    _settings.setDifficultyLocked(false);
    _settings.setPuzzleModeLocked(false);
    _gameOver = false;
    _incorrectCells = {};
    _solutionAddedCells = {};
    _correctCells = {};
    _solutionGrid = null;
  }

  void _applyRestoredSettings(SettingsState settings) {
    _settings.setDifficultyLocked(false);
    _settings.setPuzzleModeLocked(false);
    _settings.setStyleName(settings.styleName);
    _settings.setContentMode(settings.contentMode);
    _settings.setAnimalStyle(settings.animalStyle);
    _settings.setNotesMode(settings.notesMode);
    _settings.setDifficulty(settings.difficulty);
    _settings.setPuzzleMode(settings.puzzleMode);
    _settings.setDifficultyLocked(!settings.canChangeDifficulty);
    _settings.setPuzzleModeLocked(!settings.canChangePuzzleMode);
  }
}
