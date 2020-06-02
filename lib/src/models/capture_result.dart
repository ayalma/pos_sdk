import 'dart:typed_data';
import 'package:image/image.dart';

class CaptureResult {
  final Image image;
  final Uint8List data;
  final int width;
  final int height;

  const CaptureResult(this.data, this.width, this.height,this.image);
}
