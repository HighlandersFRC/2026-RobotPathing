import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:pathing_tool/models/point_node.dart';
import 'package:pathing_tool/models/robot_profile.dart';
import 'package:pathing_tool/ui/styles.dart';

class GridCanvas extends StatefulWidget {
  final RobotProfile robotProfile;
  final List<PointNode> points;
  final Function(Offset) onPointAdded;
  final Function(int) onPointSelected;
  final int? selectedPointIndex;
  final bool showConnections;

  const GridCanvas({
    super.key,
    required this.robotProfile,
    required this.points,
    required this.onPointAdded,
    required this.onPointSelected,
    this.selectedPointIndex,
    this.showConnections = false,
  });

  @override
  State<GridCanvas> createState() => _GridCanvasState();
}

class _GridCanvasState extends State<GridCanvas> {
  Offset? _hoverPosition;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppStyles.gridBackgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          
          return GestureDetector(
            onTapDown: (details) => _handleTap(details.localPosition, size),
            child: MouseRegion(
              onHover: (event) {
                setState(() {
                  _hoverPosition = event.localPosition;
                });
              },
              onExit: (_) {
                setState(() {
                  _hoverPosition = null;
                });
              },
              child: CustomPaint(
                size: size,
                painter: GridPainter(
                  robotProfile: widget.robotProfile,
                  points: widget.points,
                  selectedPointIndex: widget.selectedPointIndex,
                  showConnections: widget.showConnections,
                  hoverPosition: _hoverPosition,
                  onPointTapped: widget.onPointSelected,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleTap(Offset position, Size canvasSize) {
    // Convert screen coordinates to field coordinates
    final fieldPos = _screenToField(position, canvasSize);
    
    // Check if we're clicking on an existing point
    for (int i = 0; i < widget.points.length; i++) {
      final point = widget.points[i];
      final screenPos = _fieldToScreen(Offset(point.x, point.y), canvasSize);
      final distance = (screenPos - position).distance;
      
      if (distance < 20) { // 20 pixel hit radius
        widget.onPointSelected(i);
        return;
      }
    }
    
    // Otherwise add a new point
    widget.onPointAdded(fieldPos);
  }

  Offset _screenToField(Offset screenPos, Size canvasSize) {
    final x = (screenPos.dx / canvasSize.width) * widget.robotProfile.fieldWidth;
    final y = widget.robotProfile.fieldHeight - 
        (screenPos.dy / canvasSize.height) * widget.robotProfile.fieldHeight;
    return Offset(x, y);
  }

  Offset _fieldToScreen(Offset fieldPos, Size canvasSize) {
    final x = (fieldPos.dx / widget.robotProfile.fieldWidth) * canvasSize.width;
    final y = canvasSize.height - 
        (fieldPos.dy / widget.robotProfile.fieldHeight) * canvasSize.height;
    return Offset(x, y);
  }
}

class GridPainter extends CustomPainter {
  final RobotProfile robotProfile;
  final List<PointNode> points;
  final int? selectedPointIndex;
  final bool showConnections;
  final Offset? hoverPosition;
  final Function(int)? onPointTapped;

  GridPainter({
    required this.robotProfile,
    required this.points,
    this.selectedPointIndex,
    required this.showConnections,
    this.hoverPosition,
    this.onPointTapped,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    
    if (showConnections) {
      _drawConnections(canvas, size);
    }
    
    _drawPoints(canvas, size);
    
    if (hoverPosition != null) {
      _drawHoverIndicator(canvas, size);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final minorPaint = Paint()
      ..color = AppStyles.gridLineColor
      ..strokeWidth = AppStyles.gridLineWidth;

    final majorPaint = Paint()
      ..color = AppStyles.gridMajorLineColor
      ..strokeWidth = AppStyles.gridMajorLineWidth;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Draw vertical lines
    for (double x = 0; x <= robotProfile.fieldWidth; x += AppStyles.gridMinorSpacing) {
      final screenX = (x / robotProfile.fieldWidth) * size.width;
      final isMajor = (x % AppStyles.gridMajorSpacing) == 0;
      
      canvas.drawLine(
        Offset(screenX, 0),
        Offset(screenX, size.height),
        isMajor ? majorPaint : minorPaint,
      );

      // Draw labels for major lines
      if (isMajor) {
        textPainter.text = TextSpan(
          text: '${x.toStringAsFixed(0)}m',
          style: AppStyles.captionStyle,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(screenX - textPainter.width / 2, size.height - 20),
        );
      }
    }

    // Draw horizontal lines
    for (double y = 0; y <= robotProfile.fieldHeight; y += AppStyles.gridMinorSpacing) {
      final screenY = size.height - (y / robotProfile.fieldHeight) * size.height;
      final isMajor = (y % AppStyles.gridMajorSpacing) == 0;
      
      canvas.drawLine(
        Offset(0, screenY),
        Offset(size.width, screenY),
        isMajor ? majorPaint : minorPaint,
      );

      // Draw labels for major lines
      if (isMajor) {
        textPainter.text = TextSpan(
          text: '${y.toStringAsFixed(0)}m',
          style: AppStyles.captionStyle,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(5, screenY - textPainter.height / 2),
        );
      }
    }
  }

  void _drawConnections(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = AppStyles.pathLineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      final start = _fieldToScreen(Offset(points[i].x, points[i].y), size);
      final end = _fieldToScreen(Offset(points[i + 1].x, points[i + 1].y), size);
      canvas.drawLine(start, end, paint);
    }
  }

  void _drawPoints(Canvas canvas, Size size) {
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final isSelected = i == selectedPointIndex;
      _drawRobot(canvas, size, point, isSelected);
    }
  }

  void _drawRobot(Canvas canvas, Size size, PointNode point, bool isSelected) {
    final screenPos = _fieldToScreen(Offset(point.x, point.y), size);
    
    // Calculate robot size in screen coordinates
    final robotWidth = (robotProfile.width / robotProfile.fieldWidth) * size.width;
    final robotHeight = (robotProfile.length / robotProfile.fieldHeight) * size.height;

    canvas.save();
    canvas.translate(screenPos.dx, screenPos.dy);
    canvas.rotate(-point.angle); // Negative because screen Y is inverted

    // Draw robot body
    final bodyPaint = Paint()
      ..color = isSelected ? AppStyles.selectedPointColor : AppStyles.robotColor
      ..style = PaintingStyle.fill;

    final bodyRect = Rect.fromCenter(
      center: Offset.zero,
      width: robotWidth,
      height: robotHeight,
    );
    canvas.drawRect(bodyRect, bodyPaint);

    // Draw robot outline
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(bodyRect, outlinePaint);

    // Draw front indicator (circle)
    final frontIndicatorPaint = Paint()
      ..color = AppStyles.robotFrontIndicator
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(0, -robotHeight / 2 + AppStyles.robotIndicatorRadius),
      AppStyles.robotIndicatorRadius,
      frontIndicatorPaint,
    );

    canvas.restore();

    // Draw point index label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${point.index}',
        style: AppStyles.captionStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          backgroundColor: Colors.black54,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        screenPos.dx - textPainter.width / 2,
        screenPos.dy - robotHeight / 2 - textPainter.height - 5,
      ),
    );
  }

  void _drawHoverIndicator(Canvas canvas, Size size) {
    if (hoverPosition == null) return;

    final paint = Paint()
      ..color = AppStyles.pointColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(hoverPosition!, 5, paint);
  }

  Offset _fieldToScreen(Offset fieldPos, Size canvasSize) {
    final x = (fieldPos.dx / robotProfile.fieldWidth) * canvasSize.width;
    final y = canvasSize.height - 
        (fieldPos.dy / robotProfile.fieldHeight) * canvasSize.height;
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.selectedPointIndex != selectedPointIndex ||
        oldDelegate.showConnections != showConnections ||
        oldDelegate.hoverPosition != hoverPosition;
  }
}