import 'package:flutter_app/app/game_session_models.dart';
import 'package:flutter_app/app/game_session_service.dart';
import 'package:flutter_app/app/settings_controller.dart';

class ControllerStartupResult {
  final RestoredGameSession? restoredSession;
  final bool shouldResumeSession;

  const ControllerStartupResult({
    required this.restoredSession,
    required this.shouldResumeSession,
  });
}

class ControllerStartupCoordinator {
  final SettingsController _settingsController;
  final GameSessionService _sessionService;

  const ControllerStartupCoordinator(
    this._settingsController,
    this._sessionService,
  );

  Future<ControllerStartupResult> initialize() async {
    await _settingsController.load();
    final restoredSession = await _sessionService.restore(
      _settingsController.state,
    );
    return ControllerStartupResult(
      restoredSession: restoredSession,
      shouldResumeSession: restoredSession != null && !restoredSession.gameOver,
    );
  }
}
