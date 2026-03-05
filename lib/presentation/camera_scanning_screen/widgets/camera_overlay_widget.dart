import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CameraOverlayWidget extends StatelessWidget {
  final Offset? focusPoint;
  final bool showFocusIndicator;

  const CameraOverlayWidget({
    super.key,
    this.focusPoint,
    this.showFocusIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Grid overlay
        CustomPaint(painter: _GridPainter()),

        // Focus indicator
        showFocusIndicator && focusPoint != null
            ? Positioned(
                left: focusPoint!.dx - 30,
                top: focusPoint!.dy - 30,
                child: AnimatedOpacity(
                  opacity: showFocusIndicator ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellowAccent, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: 10,
                            height: 2,
                            color: Colors.yellowAccent,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: 2,
                            height: 10,
                            color: Colors.yellowAccent,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 2,
                            color: Colors.yellowAccent,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 2,
                            height: 10,
                            color: Colors.yellowAccent,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: 10,
                            height: 2,
                            color: Colors.yellowAccent,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: 2,
                            height: 10,
                            color: Colors.yellowAccent,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 2,
                            color: Colors.yellowAccent,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 2,
                            height: 10,
                            color: Colors.yellowAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),

        // Center scan guide
        Center(
          child: Container(
            width: 60.w,
            height: 30.h,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Corner accents
                _cornerAccent(top: 0, left: 0, isTopLeft: true),
                _cornerAccent(top: 0, right: 0, isTopRight: true),
                _cornerAccent(bottom: 0, left: 0, isBottomLeft: true),
                _cornerAccent(bottom: 0, right: 0, isBottomRight: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _cornerAccent({
    double? top,
    double? bottom,
    double? left,
    double? right,
    bool isTopLeft = false,
    bool isTopRight = false,
    bool isBottomLeft = false,
    bool isBottomRight = false,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: (isTopLeft || isTopRight)
                ? const BorderSide(color: Colors.white, width: 3)
                : BorderSide.none,
            bottom: (isBottomLeft || isBottomRight)
                ? const BorderSide(color: Colors.white, width: 3)
                : BorderSide.none,
            left: (isTopLeft || isBottomLeft)
                ? const BorderSide(color: Colors.white, width: 3)
                : BorderSide.none,
            right: (isTopRight || isBottomRight)
                ? const BorderSide(color: Colors.white, width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 0.5;

    // Draw 3x3 grid
    for (int i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int i = 1; i < 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
