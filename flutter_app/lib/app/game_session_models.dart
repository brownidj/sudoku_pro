import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

class RestoredGameSession {
  final History history;
  final Coord? selected;
  final bool gameOver;
  final Grid initialGrid;
  final SettingsState settings;

  const RestoredGameSession({
    required this.history,
    required this.selected,
    required this.gameOver,
    required this.initialGrid,
    required this.settings,
  });
}
