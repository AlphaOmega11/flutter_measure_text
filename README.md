This is Flutter package that helps to measure bounds of text on canvas.

## Prerequisites For Use

Sometimes it's needed to get the bounds of the text on canvas without horizontal
and vertical extents provided by ```TextPainter``` because of concrete
font features such as, i.e., vertical distance between top edge of the concrete glyph
and the top edge of the tallest glyph (look at the picture below, where distance between the 
top edge of the concrete glyph "a" and the top edge of the taller glyph "b" marked "delta" affects the text painter size), etc.
So pure concrete text bounds can be got by using this package instead of retrieving
```TextPainter``` bounds.

![glyphs difference example](https://github.com/AlphaOmega11/flutter_measure_text/blob/main/LettersForFlutter.jpg?raw=true)

## Getting started

To install this package add the corresponding dependency to your ```pubspec.yaml``` file
manually or by running the following command: 
```console
flutter pub add measure_text
```

## Usage

Simple example of usage is:

```dart
//Loading font
final fontData = File('Roboto-Regular.ttf')
    .readAsBytes()
    .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer));
final fontLoader = FontLoader('Roboto')..addFont(fontData);
await fontLoader.load();

//Creating necessary TextPainter and prepare it for painting
const textColor = Color.fromARGB(255, 255, 255, 255);
const text = TextSpan(
    text: "1",
    style: TextStyle(fontSize: 14, color: textColor, fontFamily: "Roboto"));
final measurePainter =
TextPainter(text: text, textDirection: TextDirection.ltr);
measurePainter.layout();

//Calculating text bounds
final textBounds = await TextMeasurer.measureText(measurePainter);
```

## Additional information

This package is licensed under MIT license.
