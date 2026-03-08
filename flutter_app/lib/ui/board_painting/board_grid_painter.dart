import 'package:flutter/material.dart';
import 'package:flutter_app/ui/board_layout.dart';
import 'package:flutter_app/ui/board_painting/board_paint_constants.dart';
import 'package:flutter_app/ui/styles.dart';

class BoardGridPainter {
  final BoardStyle style;

  const BoardGridPainter({required this.style});

  void paint(Canvas canvas, BoardLayout layout) {
    final thinPaint = Paint()
      ..color = style.gridThin
      ..strokeWidth = thinGridWidth;
    final thickPaint = Paint()
      ..color = style.gridThick
      ..strokeWidth = thickGridWidth;

    for (var index = 1; index < boardGridDimension; index += 1) {
      _drawGridLine(canvas, layout, index, thinPaint);
    }

    for (
      var index = 0;
      index <= boardGridDimension;
      index += boardBoxDimension
    ) {
      _drawGridLine(canvas, layout, index, thickPaint);
    }
  }

  void _drawGridLine(
    Canvas canvas,
    BoardLayout layout,
    int index,
    Paint paint,
  ) {
    final x = layout.originX + index * layout.cellSize;
    final y = layout.originY + index * layout.cellSize;
    canvas.drawLine(
      Offset(layout.originX, y),
      Offset(layout.originX + layout.boardSize, y),
      paint,
    );
    canvas.drawLine(
      Offset(x, layout.originY),
      Offset(x, layout.originY + layout.boardSize),
      paint,
    );
  }
}
