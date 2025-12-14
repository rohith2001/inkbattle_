import 'package:flutter/material.dart';
// Needed for DiagnosticableTreeMixin

// 1. Custom Thumb Shape: White ring with a black center dot

// NOTE: Assuming CustomTrackWithEndCaps and EndIconShape are defined elsewhere.

class RoundSliderWithBorderThumb extends SliderComponentShape {
  final double thumbRadius;
  final Color outerColor;
  final Color internalBorderColor;
  final Color innerColor;

  // CHANGED: Make these double fields nullable (double?)
  final double? internalBorderWidth;
  final double? innerCircleRadius;
  final double? borderWidth;

  const RoundSliderWithBorderThumb(
      {required this.thumbRadius,
      this.outerColor = Colors.white,
      this.internalBorderColor = Colors.white,
      this.innerColor = Colors.black,
      // Note: We don't need default values here, but keeping them for consistency
      // is harmless if the fields are nullable.
      this.internalBorderWidth = 2.0,
      this.borderWidth = 2.0,
      this.innerCircleRadius = 3.0});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    // Use null-aware operator to safely access borderWidth
    final double safeBorderWidth = borderWidth ?? 2.0;
    return Size.fromRadius(thumbRadius + safeBorderWidth);
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

    // Use null-aware operators to provide fallback values for safety
    final double safeBorderWidth = borderWidth ?? 2.0;
    final double safeInternalBorderWidth = internalBorderWidth ?? 2.0;
    final double safeInnerCircleRadius = innerCircleRadius ?? 3.0;

    final Color thumbFillColor = sliderTheme.thumbColor ?? Colors.black;

    // 1. Draw the OUTER border/ring (White in your SVG)
    final Paint outerPaint = Paint()
      ..color = outerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = safeBorderWidth; // Use safe value

    canvas.drawCircle(
        center, thumbRadius + (safeBorderWidth / 2.0), outerPaint);

    // 2. Draw the PRIMARY INNER FILL
    final Paint innerFillPaint = Paint()
      ..color = thumbFillColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius, innerFillPaint);

    // 3. Draw the SECONDARY INTERNAL BORDER
    final Paint internalBorderPaint = Paint()
      ..color = internalBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = safeInternalBorderWidth; // Use safe value

    canvas.drawCircle(
      center,
      thumbRadius - safeInternalBorderWidth,
      internalBorderPaint,
    );

    // 4. Draw the CENTER DOT (Innermost fill)
    final Paint centerPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.fill;

    // Use safe value for division
    final double centerRadius =
        thumbRadius / (safeInnerCircleRadius > 0 ? safeInnerCircleRadius : 1.0);
    canvas.drawCircle(center, centerRadius, centerPaint);
  }
}

// 2. Custom End Icon for the track (Large solid circle or small dot)
class EndIconShape extends SliderComponentShape {
  final double radius;
  final Color color;

  const EndIconShape({required this.radius, required this.color});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(radius);

  // CORRECTED SIGNATURE for SliderComponentShape.paint (Removing 'required Thumb thumb')
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
    // Removed: required Thumb thumb, // Removed to fix latest Dart/Flutter override error
  }) {
    final Paint paint = Paint()..color = color;
    context.canvas.drawCircle(center, radius, paint);
  }
}

// 3. Custom Track Shape to draw Icons outside the slider bounds
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
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;

    // IMPORTANT: Reserve space for caps inside the container
    const double capPadding = 20.0;

    final double trackLeft = offset.dx + capPadding;
    final double trackRight = offset.dx + parentBox.size.width - capPadding;

    final double trackTop =
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
    // draw track
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

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
      offset: offset,
    );

    /// spacing BETWEEN the track and caps
    const double capSpacing = 10.0;

    final Offset leftCenter =
        Offset(trackRect.left - capSpacing, trackRect.center.dy);

    final Offset rightCenter =
        Offset(trackRect.right + capSpacing, trackRect.center.dy);

    const Size dummySize = Size.zero;

    // paint left
    if (leftCap != null) {
      leftCap!.paint(
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
        textScaleFactor: 1.0,
        value: 0.0,
      );
    }

    // paint right
    if (rightCap != null) {
      rightCap!.paint(
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
        textScaleFactor: 1.0,
        value: 1.0,
      );
    }
  }
}
