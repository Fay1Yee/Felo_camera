// OPTIONAL: image preprocessing helpers for TFLite
import 'package:image/image.dart' as img;

class ImageUtils {
  static img.Image resizeCenterCrop(img.Image input, int size) {
    final resized = img.copyResize(input, width: size, height: size);
    return resized;
  }

  static List<double> toNormalizedFloatList(img.Image image) {
    final data = <double>[];
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final p = image.getPixel(x, y);
        final r = p.r / 255.0;
        final g = p.g / 255.0;
        final b = p.b / 255.0;
        data..add(r)..add(g)..add(b);
      }
    }
    return data;
  }
}