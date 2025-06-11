library measure_text;

import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Class that encapsulates measuring text functionality.
class TextMeasurer {
  /// Threshold of measuring image size
  static const _measuringImageSizeThreshold = 4096.0;

  /// Returns text bounds as [Rect] taking [TextPainter] and texture size as arguments
  /// with calling [TextPainter.layout] on it before.
  /// The bigger texture size means bigger measuring accuracy, but it cannot
  /// be larger than maximal GPU texture size (platform and device specific).
  /// So if no [measureTextureSize] parameter is passed,
  /// the default value of 4096 is used (good for most platforms and devices).
  /// Also [measureTextureSize] is better to be power of 2 for performance tuning
  /// if it is passed as argument.
  /// Be careful, no transparent text can be measured!
  static Future<Rect> measureText(TextPainter measurePainter,
      {int? measureTextureSize}) async {
    // Recording the text to measuring canvas zooming for higher accuracy
    final maxMeasurePainterDimension =
        max(measurePainter.width, measurePainter.height);
    if (maxMeasurePainterDimension > 0.0) {
      // Calculate measuring scale factor accordingly to fact that
      // maximal possible image size can't be bigger than maximal GPU texture size
      // (platform and device specific)
      final textMeasuringScaleFactor =
          ((measureTextureSize ?? _measuringImageSizeThreshold) /
                  maxMeasurePainterDimension)
              .floorToDouble();
      final pictureRecorder = PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      canvas.scale(textMeasuringScaleFactor);
      canvas.drawColor(const Color.fromARGB(0, 0, 0, 0), BlendMode.color);
      measurePainter.paint(canvas, Offset.zero);
      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(
          (measurePainter.width * textMeasuringScaleFactor).toInt(),
          (measurePainter.height * textMeasuringScaleFactor).toInt());
      final byteData = await image.toByteData();

      // Text painter size is used for default text bounds which are returned
      // if problem with canvas image processing occurs
      var textBounds =
          Rect.fromLTRB(0.0, 0.0, measurePainter.width, measurePainter.height);
      if (byteData != null) {
        final pixelData = byteData.buffer.asUint8List();
        var left = image.width;
        var top = image.height;
        var right = 0;
        var bottom = 0;
        for (int x = 0; x < image.width; x++) {
          for (int y = 0; y < image.height; y++) {
            final pixelIndex = (y * image.width + x) * 4;
            final pixelAlpha = pixelData[pixelIndex + 3];
            if (pixelAlpha != 0) {
              left = min(left, x);
              top = min(top, y);
              right = max(right, x);
              bottom = max(bottom, y);
            }
          }
        }
        textBounds = Rect.fromLTRB(
            left / textMeasuringScaleFactor,
            top / textMeasuringScaleFactor,
            right / textMeasuringScaleFactor,
            bottom / textMeasuringScaleFactor);
      }
      return textBounds;
    } else {
      return Rect.fromLTRB(
          0.0, 0.0, measurePainter.width, measurePainter.height);
    }
  }
}
