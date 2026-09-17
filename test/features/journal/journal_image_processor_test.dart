import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:partner_in_trade_web/features/journal/application/journal_image_processor.dart';

void main() {
  test('resizes long edge and produces a thumbnail', () {
    final source = img.Image(width: 3200, height: 1800);
    img.fill(source, color: img.ColorRgb8(10, 20, 30));
    final png = Uint8List.fromList(img.encodePng(source));
    final processed = JournalImageProcessor().process(png, fileName: 'chart.png');
    expect(processed.width, 2560);
    expect(processed.thumbnail.length, greaterThan(0));
    expect(processed.size, greaterThan(0));
  });
}
