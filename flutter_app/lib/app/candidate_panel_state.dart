import 'package:flutter_app/domain/types.dart';

class CandidatePanelState {
  final bool visible;
  final Coord? coord;
  final List<int> digits;
  final Set<int> selectedNotes;

  const CandidatePanelState({
    required this.visible,
    required this.coord,
    required this.digits,
    required this.selectedNotes,
  });

  const CandidatePanelState.hidden()
    : visible = false,
      coord = null,
      digits = const [],
      selectedNotes = const {};

  CandidatePanelState copyWith({
    bool? visible,
    Coord? coord,
    bool clearCoord = false,
    List<int>? digits,
    Set<int>? selectedNotes,
  }) {
    return CandidatePanelState(
      visible: visible ?? this.visible,
      coord: clearCoord ? null : (coord ?? this.coord),
      digits: List<int>.unmodifiable(digits ?? this.digits),
      selectedNotes: Set<int>.unmodifiable(selectedNotes ?? this.selectedNotes),
    );
  }
}
