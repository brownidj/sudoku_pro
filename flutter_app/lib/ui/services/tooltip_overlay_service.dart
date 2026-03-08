import 'package:flutter/material.dart';

class TooltipOverlayService {
  OverlayEntry? _entry;

  void show({
    required BuildContext context,
    required Offset globalPosition,
    required String text,
  }) {
    _entry?.remove();

    final overlay = Overlay.of(context);

    final size = MediaQuery.of(context).size;
    const tooltipPadding = EdgeInsets.symmetric(horizontal: 10, vertical: 6);
    const tooltipMargin = 8.0;
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final tooltipSize = Size(
      textPainter.width + tooltipPadding.horizontal,
      textPainter.height + tooltipPadding.vertical,
    );

    var left = globalPosition.dx - tooltipSize.width / 2;
    var top = globalPosition.dy - tooltipSize.height - 14;
    left = left.clamp(
      tooltipMargin,
      size.width - tooltipSize.width - tooltipMargin,
    );
    top = top.clamp(
      tooltipMargin,
      size.height - tooltipSize.height - tooltipMargin,
    );

    _entry = OverlayEntry(
      builder: (context) => Positioned(
        left: left,
        top: top,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: tooltipPadding,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_entry!);
    Future<void>.delayed(const Duration(seconds: 2), () {
      _entry?.remove();
      _entry = null;
    });
  }

  void dispose() {
    _entry?.remove();
    _entry = null;
  }
}
