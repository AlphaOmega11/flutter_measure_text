library measure_text;

import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Class that encapsulates measuring text functionality.
class TextMeasurer {
  /// Zoom factor for the measuring canvas for increasing of the measuring
  /// accuracy
  static const _textMeasuringScaleFactor = 100.0;

  /// Returns text bounds as [Rect] taking [TextPainter] as argument
  /// with calling [TextPainter.layout] on it before.
  /// Be careful, no transparent text can be measured!
  static Future<Rect> measureText(TextPainter measurePainter) async {
    //Recording the text to measuring canvas zooming for higher accuracy
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    canvas.scale(_textMeasuringScaleFactor);
    canvas.drawColor(const Color.fromARGB(0, 0, 0, 0), BlendMode.color);
    measurePainter.paint(canvas, Offset.zero);
    final picture = pictureRecorder.endRecording();
    final image = picture.toImageSync(
        (measurePainter.width * _textMeasuringScaleFactor).toInt(),
        (measurePainter.height * _textMeasuringScaleFactor).toInt());
    final byteData = await image.toByteData();

    //Text painter size is used for default text bounds which are returned
    //if problem with canvas image processing occurs
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
          left / _textMeasuringScaleFactor,
          top / _textMeasuringScaleFactor,
          right / _textMeasuringScaleFactor,
          bottom / _textMeasuringScaleFactor);
    }
    return textBounds;
  }
}
