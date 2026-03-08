import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/board_edit_coordinator.dart';
import 'package:flutter_app/app/candidate_panel_coordinator.dart';
import 'package:flutter_app/app/candidate_panel_state.dart';
import 'package:flutter_app/app/controller_startup_coordinator.dart';
import 'package:flutter_app/app/game_flow_coordinator.dart';
import 'package:flutter_app/app/game_session_service.dart';
import 'package:flutter_app/app/gameplay_session_state.dart';
import 'package:flutter_app/application/game_service.dart';
import 'package:flutter_app/application/results.dart';
import 'package:flutter_app/app/check_service.dart';
import 'package:flutter_app/app/grid_utils.dart';
import 'package:flutter_app/app/settings_controller.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/solution_check_coordinator.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/app/ui_state_mapper.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/app/preferences_store.dart';

part 'sudoku_controller_board_commands.dart';
part 'sudoku_controller_gameplay_commands.dart';
part 'sudoku_controller_settings_commands.dart';

class SudokuController extends ChangeNotifier {
  late final SettingsController _settings;
  late final GameSessionService _sessionService;
  late final UiStateMapper _uiStateMapper;
  late final BoardEditCoordinator _boardEditCoordinator;
  late final ControllerStartupCoordinator _startupCoordinator;
  late final GameFlowCoordinator _gameFlowCoordinator;
  late final CandidatePanelCoordinator _candidatePanelCoordinator;
  late GameplaySessionState _session;
  CandidatePanelState _candidatePanel = const CandidatePanelState.hidden();

  SudokuController({
    PreferencesStore? preferencesStore,
    GameService? gameService,
    CheckService? checkService,
    GridUtils? gridUtils,
    SettingsController? settingsController,
    GameSessionService? gameSessionService,
    SolutionCheckCoordinator? solutionCheckCoordinator,
    GameFlowCoordinator? gameFlowCoordinator,
    CandidatePanelCoordinator? candidatePanelCoordinator,
    UiStateMapper? uiStateMapper,
    BoardEditCoordinator? boardEditCoordinator,
    ControllerStartupCoordinator? startupCoordinator,
  }) {
    final prefs = preferencesStore ?? PreferencesStore();
    final resolvedGameService = gameService ?? GameService();
    final resolvedGridUtils = gridUtils ?? GridUtils();
    final resolvedCheckService = checkService ?? CheckService();
    _settings =
        settingsController ?? SettingsController(prefs, notifyListeners);
    _sessionService =
        gameSessionService ?? GameSessionService(prefs, resolvedGridUtils);
    final resolvedSolutionCoordinator =
        solutionCheckCoordinator ??
        SolutionCheckCoordinator(resolvedCheckService, resolvedGridUtils);
    _gameFlowCoordinator =
        gameFlowCoordinator ??
        GameFlowCoordinator(resolvedGameService, resolvedSolutionCoordinator);
    _candidatePanelCoordinator =
        candidatePanelCoordinator ?? const CandidatePanelCoordinator();
    _uiStateMapper = uiStateMapper ?? const UiStateMapper();
    _boardEditCoordinator =
        boardEditCoordinator ?? BoardEditCoordinator(resolvedGameService);
    _startupCoordinator =
        startupCoordinator ??
        ControllerStartupCoordinator(_settings, _sessionService);
    _session = GameplaySessionState.initial(resolvedGameService.initialHistory());
    ready = _initialize();
  }

  late final Future<void> ready;
  bool get hadSavedSessionAtLaunch => _session.hadSavedSessionAtLaunch;

  Future<void> _initialize() async {
    final startup = await _startupCoordinator.initialize();
    final restoredSession = startup.restoredSession;
    if (startup.shouldResumeSession && restoredSession != null) {
      _session = _gameFlowCoordinator.restoreSession(
        restoredSession: restoredSession,
        hadSavedSessionAtLaunch: startup.shouldResumeSession,
      );
      _applyRestoredSettings(restoredSession.settings);
      _candidatePanel = const CandidatePanelState.hidden();
      notifyListeners();
      return;
    }
    _session = _session.copyWith(
      hadSavedSessionAtLaunch: startup.shouldResumeSession,
    );
    if (restoredSession != null) {
      _applyRestoredSettings(restoredSession.settings);
    }
    start();
  }

  void _render(String status) {
    notifyListeners();
  }
}
