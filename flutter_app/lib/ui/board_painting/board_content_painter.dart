import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/board_painting/board_mode_rules.dart';
import 'package:flutter_app/ui/board_painting/board_notes_painter.dart';
import 'package:flutter_app/ui/board_painting/board_paint_constants.dart';
import 'package:flutter_app/ui/services/japanese_kanji_service.dart';
import 'package:flutter_app/ui/styles.dart';

class BoardContentPainter {
  final UiState state;
  final BoardStyle style;
  final Map<int, ui.Image> animalImages;
  final Map<int, Map<int, ui.Image>> noteImagesBySize;
  final Map<int, JapaneseKanjiEntry> japaneseKanjiEntries;
  final double devicePixelRatio;

  const BoardContentPainter({
    required this.state,
    required this.style,
    required this.animalImages,
    required this.noteImagesBySize,
    required this.japaneseKanjiEntries,
    required this.devicePixelRatio,
  });

  void paint(Canvas canvas, Rect rect, CellVm cell, double cellSize) {
    final value = cell.value;
    if (value != null) {
      _paintValue(canvas, rect, value, cell.given, cellSize);
      return;
    }

    if (cell.notes.isEmpty) {
      return;
    }

    BoardNotesPainter(
      state: state,
      style: style,
      noteImagesBySize: noteImagesBySize,
      japaneseKanjiEntries: japaneseKanjiEntries,
      devicePixelRatio: devicePixelRatio,
    ).paint(canvas, rect, cell.notes);
  }

  void _paintValue(
    Canvas canvas,
    Rect rect,
    int value,
    bool given,
    double cellSize,
  ) {
    if (usesNumericContent(state.contentMode)) {
      _drawCenteredText(
        canvas,
        rect,
        _displayValue(value),
        given: given,
        fontSize: cellSize * _fontScaleFor(state.contentMode),
        fontWeight: state.contentMode == 'japanese'
            ? FontWeight.w700
            : (given ? FontWeight.bold : FontWeight.normal),
      );
      return;
    }

    final image = animalImages[value];
    if (image != null) {
      _drawImage(canvas, rect, image, cellSize);
    }
  }

  String _displayValue(int value) {
    if (state.contentMode == 'japanese') {
      return japaneseKanjiEntries[value]?.kanji ?? value.toString();
    }
    return value.toString();
  }

  double _fontScaleFor(String contentMode) {
    return contentMode == 'japanese' ? japaneseValueScale : numberValueScale;
  }

  void _drawCenteredText(
    Canvas canvas,
    Rect rect,
    String text, {
    required bool given,
    required double fontSize,
    required FontWeight fontWeight,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: given ? style.givenColor : style.valueColor,
          fontWeight: fontWeight,
          fontSize: fontSize,
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

  void _drawImage(Canvas canvas, Rect rect, ui.Image image, double cellSize) {
    final scale = usesLargeImageScale(state.contentMode)
        ? imageScaleLarge
        : imageScaleStandard;
    final targetSize = cellSize * scale;
    final target = Rect.fromLTWH(
      rect.left + (rect.width - targetSize) / 2,
      rect.top + (rect.height - targetSize) / 2,
      targetSize,
      targetSize,
    );
    paintImage(canvas: canvas, rect: target, image: image, fit: BoxFit.contain);
  }
}
