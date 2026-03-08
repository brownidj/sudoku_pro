import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/board_painting/board_mode_rules.dart';
import 'package:flutter_app/ui/board_painting/board_paint_constants.dart';
import 'package:flutter_app/ui/note_layout.dart';
import 'package:flutter_app/ui/services/japanese_kanji_service.dart';
import 'package:flutter_app/ui/styles.dart';

class BoardNotesPainter {
  final UiState state;
  final BoardStyle style;
  final Map<int, Map<int, ui.Image>> noteImagesBySize;
  final Map<int, JapaneseKanjiEntry> japaneseKanjiEntries;
  final double devicePixelRatio;

  const BoardNotesPainter({
    required this.state,
    required this.style,
    required this.noteImagesBySize,
    required this.japaneseKanjiEntries,
    required this.devicePixelRatio,
  });

  void paint(Canvas canvas, Rect rect, List<int> notes) {
    final notesSorted = List<int>.from(notes)..sort();
    if (notesSorted.isEmpty) {
      return;
    }

    final gridSize = noteGridSize(notesSorted.length);
    final subCellSize = rect.width / gridSize;
    if (usesNumericContent(state.contentMode)) {
      _drawTextNotes(canvas, rect, notesSorted, gridSize, subCellSize);
      return;
    }

    _drawImageNotes(canvas, rect, notesSorted, gridSize, subCellSize);
  }

  void _drawTextNotes(
    Canvas canvas,
    Rect rect,
    List<int> notesSorted,
    int gridSize,
    double subCellSize,
  ) {
    final maxNotes = gridSize * gridSize;
    for (
      var index = 0;
      index < notesSorted.length && index < maxNotes;
      index += 1
    ) {
      final digit = notesSorted[index];
      _drawNoteDigit(
        canvas,
        Rect.fromLTWH(
          rect.left + (index % gridSize) * subCellSize,
          rect.top + (index ~/ gridSize) * subCellSize,
          subCellSize,
          subCellSize,
        ),
        digit,
      );
    }
  }

  void _drawImageNotes(
    Canvas canvas,
    Rect rect,
    List<int> notesSorted,
    int gridSize,
    double subCellSize,
  ) {
    final logicalSize = subCellSize * 0.95;
    final sizePx = bestNoteSize(
      logicalSize * devicePixelRatio,
      noteImagesBySize.keys,
    );
    if (sizePx == 0) {
      return;
    }

    final noteImages = noteImagesBySize[sizePx];
    if (noteImages == null) {
      return;
    }

    final maxNotes = gridSize * gridSize;
    for (
      var index = 0;
      index < notesSorted.length && index < maxNotes;
      index += 1
    ) {
      final digit = notesSorted[index];
      final cellRect = Rect.fromLTWH(
        rect.left + (index % gridSize) * subCellSize,
        rect.top + (index ~/ gridSize) * subCellSize,
        subCellSize,
        subCellSize,
      );
      final image = noteImages[digit];
      if (image == null) {
        _drawNoteDigit(canvas, cellRect, digit);
        continue;
      }

      final target = Rect.fromLTWH(
        cellRect.left + (subCellSize - logicalSize) / 2,
        cellRect.top + (subCellSize - logicalSize) / 2,
        logicalSize,
        logicalSize,
      );
      paintImage(
        canvas: canvas,
        rect: target,
        image: image,
        fit: BoxFit.contain,
      );
    }
  }

  void _drawNoteDigit(Canvas canvas, Rect rect, int digit) {
    final text = state.contentMode == 'japanese'
        ? (japaneseKanjiEntries[digit]?.kanji ?? digit.toString())
        : digit.toString();
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: style.valueColor.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
          fontSize: rect.width * noteValueScale,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: rect.width);

    textPainter.paint(
      canvas,
      Offset(
        rect.left + (rect.width - textPainter.width) / 2,
        rect.top + (rect.height - textPainter.height) / 2,
      ),
    );
  }
}
