import 'dart:ui';

import 'package:flutter/material.dart';

// 1. EDITED: Stores normalized (proportional) coordinates and the original canvas size.
class DrawingPoint {
  // Normalized offset (ratio of width/height)
  final Offset? normalizedOffset;
  final Paint? paint;
  final Size? originalCanvasSize;

  DrawingPoint({this.normalizedOffset, this.paint, this.originalCanvasSize});

  Map<String, dynamic> toJson() {
    return {
      // Send normalized coordinates (0.0 to 1.0)
      'x': normalizedOffset?.dx,
      'y': normalizedOffset?.dy,
      'width_original': originalCanvasSize?.width,
      'height_original': originalCanvasSize?.height,
      'color': paint?.color.value,
      'strokeWidth': paint?.strokeWidth,
    };
  }

  factory DrawingPoint.fromMap(Map<String, dynamic> map) {
    // --- Parse necessary values, handling potential null or dynamic types ---
    final double? x = (map['x'] as num?)?.toDouble();
    final double? y = (map['y'] as num?)?.toDouble();
    final double? originalWidth = (map['width_original'] as num?)?.toDouble();
    final double? originalHeight = (map['height_original'] as num?)?.toDouble();
    final int? colorValue = (map['color'] as num?)?.toInt();
    final double? strokeWidth = (map['strokeWidth'] as num?)?.toDouble();

    // --- Create objects using null-safe checks ---

    // 1. Create normalizedOffset
    final Offset? offset = (x != null && y != null) ? Offset(x, y) : null;

    // 2. Create originalCanvasSize
    final Size? size = (originalWidth != null && originalHeight != null)
        ? Size(originalWidth, originalHeight)
        : null;

    // 3. Create Paint object
    final Paint? drawingPaint = (colorValue != null && strokeWidth != null)
        ? (Paint()
          ..color = Color(colorValue)
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle
              .stroke // It's important to set the style for drawing
          ..strokeCap =
              StrokeCap.round) // Often desirable for drawing applications
        : null;

    return DrawingPoint(
      normalizedOffset: offset,
      paint: drawingPaint,
      originalCanvasSize: size,
    );
  }

  // Helper method to convert normalized coordinates back to absolute pixels
  Offset? toAbsoluteOffset(Size currentCanvasSize) {
    if (normalizedOffset == null) return null;
    return Offset(
      normalizedOffset!.dx * currentCanvasSize.width,
      normalizedOffset!.dy * currentCanvasSize.height,
    );
  }
}

// -----------------------------------------------------------------------------

class DrawingCanvas extends StatefulWidget {
  final List<DrawingPoint> points;
  final Function(DrawingPoint) onPointAdded;
  final Color selectedColor;
  final double strokeWidth;
  final bool isDrawingEnabled;

  const DrawingCanvas({
    Key? key,
    required this.points,
    required this.onPointAdded,
    required this.selectedColor,
    required this.strokeWidth,
    required this.isDrawingEnabled,
  }) : super(key: key);

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final GlobalKey _canvasKey = GlobalKey();

  // CRITICAL: Convert global position to local canvas coordinates and normalize them
  DrawingPoint? _getNormalizedPoint(Offset globalPosition) {
    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      print('⚠️ DrawingCanvas: RenderBox is null');
      return null;
    }

    final localPosition = renderBox.globalToLocal(globalPosition);
    final size = renderBox.size;

    // 1. Validate and clamp local position
    if (localPosition.dx < 0 ||
        localPosition.dx > size.width ||
        localPosition.dy < 0 ||
        localPosition.dy > size.height) {
      // Use clamped position for normalization
      final clampedX = localPosition.dx.clamp(0.0, size.width);
      final clampedY = localPosition.dy.clamp(0.0, size.height);
      final clampedPosition = Offset(clampedX, clampedY);

      // 2. Normalize the clamped position
      final normalizedX = clampedPosition.dx / size.width;
      final normalizedY = clampedPosition.dy / size.height;

      return _createDrawingPoint(Offset(normalizedX, normalizedY), size);
    }

    // 2. Normalize the position
    final normalizedX = localPosition.dx / size.width;
    final normalizedY = localPosition.dy / size.height;

    return _createDrawingPoint(Offset(normalizedX, normalizedY), size);
  }

  DrawingPoint _createDrawingPoint(Offset normalizedOffset, Size originalSize) {
    return DrawingPoint(
      normalizedOffset: normalizedOffset,
      originalCanvasSize: originalSize,
      paint: Paint()
        ..color = widget.selectedColor
        ..strokeWidth = widget.strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  // --- Pan Handlers ---

  void _onPanStart(DragStartDetails details) {
    if (!widget.isDrawingEnabled) return;

    final point = _getNormalizedPoint(details.globalPosition);
    if (point == null) return;

    widget.onPointAdded(point);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isDrawingEnabled) return;

    final point = _getNormalizedPoint(details.globalPosition);
    if (point == null) return;

    widget.onPointAdded(point);
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isDrawingEnabled) return;

    // Add null point to mark end of stroke
    widget.onPointAdded(
      DrawingPoint(
        normalizedOffset: null,
        paint: null,
        originalCanvasSize: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        key: _canvasKey, // Key on the actual canvas container
        color: Colors.transparent,
        child: CustomPaint(
          // 3. EDITED: Pass current canvas Size to the painter for denormalization
          painter: DrawingPainter(points: widget.points),
          child: Container(),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    // Current canvas size (size argument) is used for denormalization
    final currentSize = size;

    for (int i = 0; i < points.length - 1; i++) {
      // Denormalize points for drawing
      final point1 = points[i].toAbsoluteOffset(currentSize);
      final point2 = points[i + 1].toAbsoluteOffset(currentSize);

      if (point1 != null && point2 != null) {
        final paint = points[i].paint ?? Paint();
        // Draw line using absolute (denormalized) offsets
        canvas.drawLine(point1, point2, paint);
      } else if (point1 != null && point2 == null) {
        final paint = points[i].paint ?? Paint();
        // Draw point using absolute (denormalized) offset
        canvas.drawPoints(PointMode.points, [point1], paint);
      }
      // If point1 is null, it marks the end of a previous stroke, so we skip it.
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
