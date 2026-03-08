import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/board_painting/board_paint_constants.dart';

class BoardSelectionInfo {
  final int? row;
  final int? col;
  final int? boxRow;
  final int? boxCol;

  const BoardSelectionInfo({
    required this.row,
    required this.col,
    required this.boxRow,
    required this.boxCol,
  });

  factory BoardSelectionInfo.from(Coord? selected) {
    final row = selected?.row;
    final col = selected?.col;
    return BoardSelectionInfo(
      row: row,
      col: col,
      boxRow: row == null ? null : row ~/ boardBoxDimension,
      boxCol: col == null ? null : col ~/ boardBoxDimension,
    );
  }

  bool isPeerRowOrColumn(int candidateRow, int candidateCol) {
    return row != null &&
        col != null &&
        (candidateRow == row || candidateCol == col);
  }

  bool isPeerBox(int candidateRow, int candidateCol) {
    return boxRow != null &&
        boxCol != null &&
        candidateRow ~/ boardBoxDimension == boxRow &&
        candidateCol ~/ boardBoxDimension == boxCol;
  }
}
