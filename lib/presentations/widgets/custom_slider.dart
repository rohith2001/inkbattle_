import 'package:flutter/material.dart';

/// ------------------------------------------------------------
/// Responsive Scale Helper
/// ------------------------------------------------------------
double _sliderScale() {
  final width =
      MediaQueryData.fromWindow(WidgetsBinding.instance.window)
          .size
          .width;
  return width > 600 ? 1.25 : 1.0;
}

/// ------------------------------------------------------------
/// 1. Custom Thumb Shape
/// ------------------------------------------------------------
class RoundSliderWithBorderThumb extends SliderComponentShape {
  final double thumbRadius;
  final Color outerColor;
  final Color internalBorderColor;
  final Color innerColor;

  final double? internalBorderWidth;
  final double? innerCircleRadius;
  final double? borderWidth;

  const RoundSliderWithBorderThumb({
    required this.thumbRadius,
    this.outerColor = Colors.white,
    this.internalBorderColor = Colors.white,
    this.innerColor = Colors.black,
    this.internalBorderWidth = 2.0,
    this.borderWidth = 2.0,
    this.innerCircleRadius = 3.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    final scale = _sliderScale();
    final safeBorderWidth = (borderWidth ?? 2.0) * scale;
    return Size.fromRadius((thumbRadius * scale) + safeBorderWidth);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required Size sizeWithOverflow,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double textScaleFactor,
    required double value,
  }) {
    final Canvas canvas = context.canvas;
    final scale = _sliderScale();

    final safeBorderWidth = (borderWidth ?? 2.0) * scale;
    final safeInternalBorderWidth =
        (internalBorderWidth ?? 2.0) * scale;
    final safeInnerCircleRadius =
        (innerCircleRadius ?? 3.0);

    final scaledRadius = thumbRadius * scale;

    final Color thumbFillColor =
        sliderTheme.thumbColor ?? Colors.black;

    /// OUTER RING
    final outerPaint = Paint()
      ..color = outerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = safeBorderWidth;

    canvas.drawCircle(
        center, scaledRadius + safeBorderWidth / 2, outerPaint);

    /// INNER FILL
    final innerFillPaint = Paint()
      ..color = thumbFillColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, scaledRadius, innerFillPaint);

    /// INTERNAL BORDER
    final internalBorderPaint = Paint()
      ..color = internalBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = safeInternalBorderWidth;

    canvas.drawCircle(
      center,
      scaledRadius - safeInternalBorderWidth,
      internalBorderPaint,
    );

    /// CENTER DOT
    final centerPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.fill;

    final centerRadius =
        scaledRadius / (safeInnerCircleRadius > 0
            ? safeInnerCircleRadius
            : 1.0);

    canvas.drawCircle(center, centerRadius, centerPaint);
  }
}

/// ------------------------------------------------------------
/// 2. End Icon Shape
/// ------------------------------------------------------------
class EndIconShape extends SliderComponentShape {
  final double radius;
  final Color color;

  const EndIconShape({
    required this.radius,
    required this.color,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    final scale = _sliderScale();
    return Size.fromRadius(radius * scale);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required Size sizeWithOverflow,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double textScaleFactor,
    required double value,
  }) {
    final scale = _sliderScale();

    final paint = Paint()..color = color;
    context.canvas.drawCircle(center, radius * scale, paint);
  }
}

/// ------------------------------------------------------------
/// 3. Custom Track with End Caps
/// ------------------------------------------------------------
class CustomTrackWithEndCaps extends RectangularSliderTrackShape {
  final SliderComponentShape? leftCap;
  final SliderComponentShape? rightCap;

  const CustomTrackWithEndCaps({
    this.leftCap,
    this.rightCap,
  });

  @override
  Rect getPreferredRect({
    bool isDiscrete = false,
    bool isEnabled = false,
    Offset offset = Offset.zero,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 4.0;
    final scale = _sliderScale();

    final capPadding = 20.0 * scale;

    final trackLeft = offset.dx + capPadding;
    final trackRight =
        offset.dx + parentBox.size.width - capPadding;

    final trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;

    return Rect.fromLTRB(
      trackLeft,
      trackTop,
      trackRight,
      trackTop + trackHeight,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
    );

    final scale = _sliderScale();

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
      offset: offset,
    );

    final capSpacing = 10.0 * scale;

    final leftCenter =
        Offset(trackRect.left - capSpacing, trackRect.center.dy);

    final rightCenter =
        Offset(trackRect.right + capSpacing, trackRect.center.dy);

    const dummySize = Size.zero;

    leftCap?.paint(
      context,
      leftCenter,
      activationAnimation: enableAnimation,
      enableAnimation: enableAnimation,
      isDiscrete: isDiscrete,
      labelPainter: TextPainter(),
      parentBox: parentBox,
      sizeWithOverflow: dummySize,
      sliderTheme: sliderTheme,
      textDirection: textDirection,
      textScaleFactor: 1,
      value: 0,
    );

    rightCap?.paint(
      context,
      rightCenter,
      activationAnimation: enableAnimation,
      enableAnimation: enableAnimation,
      isDiscrete: isDiscrete,
      labelPainter: TextPainter(),
      parentBox: parentBox,
      sizeWithOverflow: dummySize,
      sliderTheme: sliderTheme,
      textDirection: textDirection,
      textScaleFactor: 1,
      value: 1,
    );
  }
}
