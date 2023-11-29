import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'cdk_theme.dart';

class CDKUtilShaderGrid extends CustomPainter {
  static ui.Image? gridImage;
  bool _isInitializing = false;

  CDKUtilShaderGrid();

  static initGridImage(double size) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas imageCanvas = Canvas(recorder);
    final paint = Paint()..color = CDKTheme.grey50;
    imageCanvas.drawRect(Rect.fromLTWH(0, 0, size, size), paint);
    imageCanvas.drawRect(Rect.fromLTWH(size, size, size, size), paint);
    paint.color = CDKTheme.grey100;
    imageCanvas.drawRect(Rect.fromLTWH(size, 0, size, size), paint);
    imageCanvas.drawRect(Rect.fromLTWH(0, size, size, size), paint);
    int s = (size * 2).toInt();
    gridImage = await recorder.endRecording().toImage(s, s);
  }

  @override
  void paint(Canvas canvas, Size size) async {
    if (gridImage == null && !_isInitializing) {
      _isInitializing = true;
      await initGridImage(5);
      _isInitializing = false;
      return;
    }

    final paint = Paint();
    final shader = ui.ImageShader(
      gridImage!,
      TileMode.repeated,
      TileMode.repeated,
      Float64List.fromList([
        1,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        1,
      ]),
    );

    paint.shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}