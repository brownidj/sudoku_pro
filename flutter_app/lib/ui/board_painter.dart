import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/animal_cache.dart';
import 'package:flutter_app/ui/board_layout.dart';
import 'package:flutter_app/ui/board_theme.dart';
import 'package:flutter_app/ui/note_layout.dart';
import 'package:flutter_app/ui/styles.dart';

class SudokuBoardPainter extends CustomPainter {
  final UiState state;
  final BoardStyle style;
  final Map<int, ui.Image> animalImages;
  final Map<int, Map<int, ui.Image>> noteImagesBySize;
  final double devicePixelRatio;

  SudokuBoardPainter({
    required this.state,
    required this.style,
    required this.animalImages,
    required this.noteImagesBySize,
    required this.devicePixelRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final layout = layoutForSize(size);
    final boardRect = Rect.fromLTWH(
      layout.originX,
      layout.originY,
      layout.boardSize,
      layout.boardSize,
    );

    final boardPaint = Paint()..color = style.boardBg;
    canvas.drawRect(boardRect, boardPaint);

    _drawCells(canvas, layout, BoardTheme(style));
    _drawGrid(canvas, layout);
    // Notes badge removed; notes mode is indicated via the UI toggle.
  }

  void _drawCells(Canvas canvas, BoardLayout layout, BoardTheme theme) {
    final selected = state.selected;
    final selRow = selected?.row;
    final selCol = selected?.col;
    final selBoxRow = selRow == null ? null : selRow ~/ 3;
    final selBoxCol = selCol == null ? null : selCol ~/ 3;

    final cellSize = layout.cellSize;
    for (var r = 0; r < 9; r += 1) {
      final row = state.board.cells[r];
      for (var c = 0; c < 9; c += 1) {
        final cell = row[c];
        final x0 = layout.originX + c * cellSize;
        final y0 = layout.originY + r * cellSize;
        final rect = Rect.fromLTWH(x0, y0, cellSize, cellSize);

        final peerRowCol =
            selRow != null && selCol != null && (r == selRow || c == selCol);
        final peerBox =
            selBoxRow != null &&
            selBoxCol != null &&
            (r ~/ 3 == selBoxRow) &&
            (c ~/ 3 == selBoxCol);

        final model = theme.cellModel(
          cell: cell,
          gameOver: state.gameOver,
          peerRowCol: peerRowCol,
          peerBox: peerBox,
        );

        final hasImageValue =
            cell.value != null && animalImages.containsKey(cell.value);
        final cellBackground =
            state.contentMode == 'butterflies' && hasImageValue
            ? Colors.white
            : model.background;
        canvas.drawRect(rect, Paint()..color = cellBackground);

        if (state.gameOver) {
          Color? highlight;
          if (model.showIncorrect) {
            highlight = style.highlightIncorrect;
          } else if (model.showSolution) {
            highlight = style.highlightSolution;
          } else if (model.showGiven) {
            highlight = style.highlightGiven;
          } else if (model.showCorrect) {
            highlight = style.highlightCorrect;
          }
          if (highlight != null) {
            canvas.drawRect(rect, Paint()..color = highlight);
          }
        } else {
          if (model.showSelection) {
            _drawOutline(canvas, rect, style.outlineSelected, 3);
          } else if (model.showConflict) {
            _drawOutline(canvas, rect, style.outlineConflict, 3);
          }
        }

        if (cell.value != null) {
          if (state.contentMode != 'numbers' &&
              animalImages.containsKey(cell.value)) {
            _drawAnimal(canvas, rect, animalImages[cell.value]!, cell.value!);
          } else {
            _drawValue(canvas, rect, cell.value!, cell.given, cellSize);
          }
        } else if (cell.notes.isNotEmpty) {
          _drawNotes(canvas, rect, cell.notes, cellSize);
        }

        // Solution/correct/given outlines handled above.
      }
    }
  }

  void _drawOutline(Canvas canvas, Rect rect, Color color, double width) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    canvas.drawRect(rect, paint);
  }

  void _drawValue(
    Canvas canvas,
    Rect rect,
    int value,
    bool given,
    double cellSize,
  ) {
    final fontSize = cellSize * 0.6;
    final textPainter = TextPainter(
      text: TextSpan(
        text: value.toString(),
        style: TextStyle(
          color: given ? style.givenColor : style.valueColor,
          fontWeight: given ? FontWeight.bold : FontWeight.normal,
          fontSize: fontSize,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: rect.width);

    final offset = Offset(
      rect.left + (rect.width - textPainter.width) / 2,
      rect.top + (rect.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);
  }

  void _drawNotes(Canvas canvas, Rect rect, List<int> notes, double cellSize) {
    final notesSorted = List<int>.from(notes)..sort();
    if (notesSorted.isEmpty) {
      return;
    }
    final gridSize = noteGridSize(notesSorted.length);
    final subCellSize = rect.width / gridSize;
    if (state.contentMode == 'numbers') {
      _drawNumberNotes(canvas, rect, notesSorted, gridSize, subCellSize);
      return;
    }
    final logicalSize = subCellSize * 0.95;
    final targetPx = logicalSize * devicePixelRatio;
    final sizePx = bestNoteSize(targetPx, noteImagesBySize.keys);
    if (sizePx == 0 || !noteImagesBySize.containsKey(sizePx)) {
      _drawNumberNotes(canvas, rect, notesSorted, gridSize, subCellSize);
      return;
    }
    final maxNotes = gridSize * gridSize;
    for (var i = 0; i < notesSorted.length && i < maxNotes; i += 1) {
      final digit = notesSorted[i];
      final row = i ~/ gridSize;
      final col = i % gridSize;
      final cellLeft = rect.left + col * subCellSize;
      final cellTop = rect.top + row * subCellSize;
      final cellRect = Rect.fromLTWH(
        cellLeft,
        cellTop,
        subCellSize,
        subCellSize,
      );
      final image = noteImagesBySize[sizePx]?[digit];
      if (image == null) {
        _drawNoteDigit(canvas, cellRect, digit);
        continue;
      }
      final left = cellLeft + (subCellSize - logicalSize) / 2;
      final top = cellTop + (subCellSize - logicalSize) / 2;
      final target = Rect.fromLTWH(left, top, logicalSize, logicalSize);
      paintImage(
        canvas: canvas,
        rect: target,
        image: image,
        fit: BoxFit.contain,
      );
    }
  }

  void _drawNumberNotes(
    Canvas canvas,
    Rect rect,
    List<int> notesSorted,
    int gridSize,
    double subCellSize,
  ) {
    final maxNotes = gridSize * gridSize;
    for (var i = 0; i < notesSorted.length && i < maxNotes; i += 1) {
      final digit = notesSorted[i];
      final row = i ~/ gridSize;
      final col = i % gridSize;
      final cellLeft = rect.left + col * subCellSize;
      final cellTop = rect.top + row * subCellSize;
      final cellRect = Rect.fromLTWH(
        cellLeft,
        cellTop,
        subCellSize,
        subCellSize,
      );
      _drawNoteDigit(canvas, cellRect, digit);
    }
  }

  void _drawNoteDigit(Canvas canvas, Rect rect, int digit) {
    final fontSize = rect.width * 0.6;
    final textPainter = TextPainter(
      text: TextSpan(
        text: digit.toString(),
        style: TextStyle(
          color: style.valueColor.withOpacity(0.7),
          fontWeight: FontWeight.w500,
          fontSize: fontSize,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: rect.width);

    final offset = Offset(
      rect.left + (rect.width - textPainter.width) / 2,
      rect.top + (rect.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);
  }

  void _drawAnimal(Canvas canvas, Rect rect, ui.Image image, int digit) {
    final targetSize = _animalTargetSize(rect.width, digit);
    final left = rect.left + (rect.width - targetSize) / 2;
    final top = rect.top + (rect.height - targetSize) / 2;
    final target = Rect.fromLTWH(left, top, targetSize, targetSize);
    paintImage(canvas: canvas, rect: target, image: image, fit: BoxFit.contain);
  }

  double _animalTargetSize(double cellSize, int digit) {
    if (state.contentMode == 'butterflies') {
      return cellSize * 0.9;
    }
    return cellSize * 0.7;
  }

  void _drawGrid(Canvas canvas, BoardLayout layout) {
    final thinPaint = Paint()
      ..color = style.gridThin
      ..strokeWidth = 1.0;
    final thickPaint = Paint()
      ..color = style.gridThick
      ..strokeWidth = 3.0;

    for (var i = 1; i < 9; i += 1) {
      final x = layout.originX + i * layout.cellSize;
      final y = layout.originY + i * layout.cellSize;
      canvas.drawLine(
        Offset(layout.originX, y),
        Offset(layout.originX + layout.boardSize, y),
        thinPaint,
      );
      canvas.drawLine(
        Offset(x, layout.originY),
        Offset(x, layout.originY + layout.boardSize),
        thinPaint,
      );
    }

    for (var i = 0; i <= 9; i += 3) {
      final x = layout.originX + i * layout.cellSize;
      final y = layout.originY + i * layout.cellSize;
      canvas.drawLine(
        Offset(layout.originX, y),
        Offset(layout.originX + layout.boardSize, y),
        thickPaint,
      );
      canvas.drawLine(
        Offset(x, layout.originY),
        Offset(x, layout.originY + layout.boardSize),
        thickPaint,
      );
    }
  }

  // Notes badge removed.

  @override
  bool shouldRepaint(covariant SudokuBoardPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.style != style ||
        oldDelegate.animalImages != animalImages ||
        oldDelegate.noteImagesBySize != noteImagesBySize;
  }
}
