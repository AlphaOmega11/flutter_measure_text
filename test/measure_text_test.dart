import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:measure_text/measure_text.dart';

late TextPainter _measurePainter;

void main() {
  setUp(() async {
    //Loading font
    final fontData = File('Roboto-Regular.ttf')
        .readAsBytes()
        .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer));
    final fontLoader = FontLoader('Roboto')..addFont(fontData);
    await fontLoader.load();

    //Creating necessary TextPainter
    _measurePainter = TextPainter(textDirection: TextDirection.ltr);
  });
  test('measuring single line text', () async {
    //Fill the TextPainter with appropriate TextSpan and prepare it for
    //painting
    const textColor = Color.fromARGB(255, 255, 255, 255);
    const text = TextSpan(
        text: "1",
        style: TextStyle(fontSize: 14, color: textColor, fontFamily: "Roboto"));
    _measurePainter.text = text;
    _measurePainter.layout();

    //Calculating text bounds and checking the result
    final textBounds = await TextMeasurer.measureText(_measurePainter);
    expect(_areRectsEqual(textBounds, const Rect.fromLTRB(1.2, 3.0, 5.0, 13.0)),
        true);
  });

  test('measuring multi line text', () async {
    //Fill the TextPainter with appropriate TextSpan and prepare it for
    //painting
    const textColor = Color.fromARGB(255, 255, 255, 255);
    const text = TextSpan(
        text: "1\n2",
        style: TextStyle(fontSize: 14, color: textColor, fontFamily: "Roboto"));
    _measurePainter.text = text;
    _measurePainter.layout();

    //Calculating text bounds and checking the result
    final textBounds = await TextMeasurer.measureText(_measurePainter);
    expect(_areRectsEqual(textBounds, const Rect.fromLTRB(0.6, 3.0, 7.3, 29.0)),
        true);
  });
}

//Comparing rectangles
bool _areRectsEqual(Rect rect1, Rect rect2) {
  const compareThreshold = 0.1;
  return (rect1.left - rect2.left).abs() < compareThreshold &&
      (rect1.top - rect2.top).abs() < compareThreshold &&
      (rect1.right - rect2.right).abs() < compareThreshold &&
      (rect1.bottom - rect2.bottom).abs() < compareThreshold;
}
