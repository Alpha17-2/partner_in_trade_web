import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ProcessedJournalImage {
  const ProcessedJournalImage({
    required this.bytes,
    required this.thumbnail,
    required this.mimeType,
    required this.width,
    required this.height,
    required this.size,
  });

  final Uint8List bytes;
  final Uint8List thumbnail;
  final String mimeType;
  final int width;
  final int height;
  final int size;
}

class JournalImageProcessor {
  static const maxLongEdge = 2560;
  static const thumbnailEdge = 360;
  static const jpegQuality = 88;
  static const jpegPreferBytes = 1500 * 1024;

  ProcessedJournalImage process(Uint8List input, {required String fileName}) {
    final decoded = img.decodeImage(input);
    if (decoded == null) {
      throw FormatException('Could not decode image');
    }

    var image = decoded;
    final longEdge = math.max(image.width, image.height);
    if (longEdge > maxLongEdge) {
      image = image.width >= image.height
          ? img.copyResize(image, width: maxLongEdge)
          : img.copyResize(image, height: maxLongEdge);
    }

    final thumb = image.width >= image.height
        ? img.copyResize(image, width: thumbnailEdge)
        : img.copyResize(image, height: thumbnailEdge);
    final thumbBytes = Uint8List.fromList(
      img.encodeJpg(thumb, quality: 80),
    );

    final lower = fileName.toLowerCase();
    final originalJpeg =
        lower.endsWith('.jpg') || lower.endsWith('.jpeg');
    final pngBytes = Uint8List.fromList(img.encodePng(image));
    final jpgBytes = Uint8List.fromList(
      img.encodeJpg(image, quality: jpegQuality),
    );

    late Uint8List out;
    late String mime;
    if (originalJpeg || pngBytes.length > jpegPreferBytes) {
      out = jpgBytes;
      mime = 'image/jpeg';
    } else {
      out = pngBytes;
      mime = 'image/png';
    }

    return ProcessedJournalImage(
      bytes: out,
      thumbnail: thumbBytes,
      mimeType: mime,
      width: image.width,
      height: image.height,
      size: out.length,
    );
  }
}
