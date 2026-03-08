import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_app/app/tile_info_presentation_coordinator.dart';
import 'package:flutter_app/ui/services/tooltip_overlay_service.dart';

class TileInfoPresentationService {
  final TooltipOverlayService _tooltipService;

  TileInfoPresentationService({
    TooltipOverlayService? tooltipService,
  }) : _tooltipService = tooltipService ?? TooltipOverlayService();

  void dispose() {
    _tooltipService.dispose();
  }

  void present({
    required BuildContext context,
    required Offset globalPosition,
    required TileInfoPresentation presentation,
    required Map<int, ui.Image> butterflyImages,
  }) {
    if (presentation is ButterflyDialogPresentation) {
      final image = butterflyImages[presentation.digit];
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 240,
                  height: 240,
                  child: image == null
                      ? const SizedBox.shrink()
                      : FittedBox(
                          fit: BoxFit.contain,
                          child: RawImage(image: image),
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  presentation.description,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    if (presentation is TooltipTileInfoPresentation) {
      _tooltipService.show(
        context: context,
        globalPosition: globalPosition,
        text: presentation.text,
      );
    }
  }
}
