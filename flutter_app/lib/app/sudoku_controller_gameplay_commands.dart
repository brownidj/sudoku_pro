part of 'sudoku_controller.dart';

extension SudokuControllerGameplayCommands on SudokuController {
  UiState get state => _buildState();

  void start() {
    _startPuzzle();
  }

  void onNewGame() {
    _candidatePanel = const CandidatePanelState.hidden();
    _startPuzzle();
  }

  void onCheckSolution() {
    if (_session.gameOver) {
      return;
    }
    _candidatePanel = const CandidatePanelState.hidden();
    final flowResult = _gameFlowCoordinator.checkSolution(session: _session);
    _applyGameFlowResult(flowResult);
  }

  void onShowSolution() {
    if (!_session.gameOver) {
      onCheckSolution();
    }
    if (!_session.gameOver) {
      return;
    }
    _candidatePanel = const CandidatePanelState.hidden();
    final flowResult = _gameFlowCoordinator.showSolution(session: _session);
    _applyGameFlowResult(flowResult);
  }

  UiState _buildState() {
    return _uiStateMapper.map(
      UiStateMapperInput(
        board: _session.history.present.board,
        settings: _settings.state,
        selected: _session.selected,
        conflicts: _session.conflicts,
        incorrectCells: _session.incorrectCells,
        correctCells: _session.correctCells,
        solutionAddedCells: _session.solutionAddedCells,
        solutionGrid: _session.solutionGrid,
        gameOver: _session.gameOver,
        candidatePanel: _candidatePanel,
      ),
    );
  }

  void _saveGameSession() {
    _sessionService.save(
      history: _session.history,
      selected: _session.selected,
      gameOver: _session.gameOver,
      initialGrid: _session.initialGrid,
      settings: _settings.state,
    );
  }

  void _startPuzzle() {
    _candidatePanel = const CandidatePanelState.hidden();
    final flowResult = _gameFlowCoordinator.startNewPuzzle(
      session: _session,
      settings: _settings.state,
    );
    _applyGameFlowResult(flowResult);
  }

  void _applyGameFlowResult(GameFlowResult result) {
    _session = result.session;
    if (result.unlockDifficulty) {
      _settings.setDifficultyLocked(false);
    }
    if (result.unlockPuzzleMode) {
      _settings.setPuzzleModeLocked(false);
    }
    _saveGameSession();
    _render(result.statusMessage);
  }
}
