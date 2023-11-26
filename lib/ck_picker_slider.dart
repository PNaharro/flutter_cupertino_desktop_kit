import 'package:flutter/cupertino.dart';
import 'ck_theme_notifier.dart';
import 'ck_theme.dart';

class CKPickerSlider extends StatefulWidget {
  final double value;
  final double size;
  final bool enabled;
  final Function(double)? onChanged;

  const CKPickerSlider({
    Key? key,
    required this.value,
    this.enabled = true,
    this.size = 16,
    required this.onChanged,
  }) : super(key: key);

  @override
  CKPickerSliderState createState() => CKPickerSliderState();
}

class CKPickerSliderState extends State<CKPickerSlider> {

  @override
  void initState() {
    super.initState();
    if (widget.value <0 || widget.value > 1) {
      throw Exception(
          "CKPickerSliderState initState: value must be between 0 and 1");
    }
  }

  void _getValue(Offset globalPosition) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.globalToLocal(globalPosition);

    final double radius = renderBox.size.height / 3;
    final circleRail = renderBox.size.width - radius * 2;

    double newValue = ((position.dx - radius) / circleRail).clamp(0.0, 1.0);

    if (newValue < 0) {
      newValue = 0;
    }
    if (newValue > 1) {
      newValue = 1;
    }

    widget.onChanged?.call(newValue);
  }

  void _onTapDown(TapDownDetails details) {
    _getValue(details.globalPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _getValue(details.globalPosition);
  }

  @override
  Widget build(BuildContext context) {
    CKTheme theme = CKThemeNotifier.of(context)!.changeNotifier;

    return GestureDetector(
      onTapDown: (details) {
        _onTapDown(details);
      },
      onPanUpdate: !widget.enabled ? null : _onPanUpdate,
      child: CustomPaint(
        painter: DSKPicker01Painter(
          colorAccent: theme.accent,
          colorBar: theme.backgroundSecondary1,
          colorCircle: theme.backgroundSecondary0,
          value: widget.value,
          hasAppFocus: theme.isAppFocused, // Border color
        ),
        size: Size(widget.size, widget.size),
      ),
    );
  }
}

class DSKPicker01Painter extends CustomPainter {
  final Color colorAccent;
  final Color colorBar;
  final Color colorCircle;
  final double value;
  final bool hasAppFocus;

  DSKPicker01Painter(
      {required this.colorAccent,
      required this.colorBar,
      required this.colorCircle,
      required this.value,
      this.hasAppFocus = true});

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = colorBar
      ..style = PaintingStyle.fill;

    Paint progressPaint = Paint()
      ..color = hasAppFocus ? colorAccent : CKTheme.grey
      ..style = PaintingStyle.fill;

    // Calcula l'alçada i la posició vertical centrada de la barra
    const double barHeight = 6.0;
    const Radius barHeightHalf = Radius.circular(barHeight / 2);
    final double verticalOffset = (size.height - barHeight) / 2;

    // Crea rectangles amb els costats arrodonits
    RRect backgroundRRect = RRect.fromLTRBR(
      0,
      verticalOffset,
      size.width,
      verticalOffset + barHeight,
      const Radius.circular(barHeight /
          2), // El radi és la meitat de l'alçada per fer-ho completament arrodonit
    );

    double progressWidth = size.width * value;

    RRect progressRRect = RRect.fromLTRBR(
      0,
      verticalOffset,
      progressWidth,
      verticalOffset + barHeight,
      barHeightHalf,
    );

    // Dibuixa el fons i el progrés
    canvas.drawRRect(backgroundRRect, backgroundPaint);
    canvas.drawRRect(progressRRect, progressPaint);

    // Dibuixar la sombra
    final double radius = size.height / 3;
    final circleRail = size.width - radius * 2;
    final circleProgress = (progressWidth * circleRail) / size.width;
    final Offset center = Offset(radius + circleProgress, size.height / 2);
    final shadowPaint = Paint()
      ..color = CKTheme.grey50
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);
    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.drawShadow(circlePath, shadowPaint.color, 1, false);

    // Dibuixar el cercle principal
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = colorCircle;
    canvas.drawCircle(center, radius, paint);

    final paintBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..color = CKTheme.grey100;
    canvas.drawCircle(center, radius, paintBorder);
  }

  @override
  bool shouldRepaint(covariant DSKPicker01Painter oldDelegate) {
    return oldDelegate.colorAccent != colorAccent ||
        oldDelegate.colorBar != colorBar ||
        oldDelegate.colorCircle != colorCircle ||
        oldDelegate.value != value ||
        oldDelegate.hasAppFocus != hasAppFocus;
  }
}