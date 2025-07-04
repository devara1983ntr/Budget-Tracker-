import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final bool showBackground;

  const AppLogo({
    super.key,
    this.size = 80,
    this.color,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? const Color(0xFF10B981); // Vibrant green
    final backgroundColor = const Color(0xFF1F2937); // Dark charcoal

    return Container(
      width: size,
      height: size,
      decoration: showBackground
          ? BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            )
          : null,
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.6, size * 0.6),
          painter: BudgetLogoPainter(logoColor),
        ),
      ),
    );
  }
}

class BudgetLogoPainter extends CustomPainter {
  final Color color;

  BudgetLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw the main "B" shape
    _drawStylizedB(canvas, size, paint);
    
    // Draw the currency symbol ($) integrated into the B
    _drawCurrencySymbol(canvas, size, strokePaint);
    
    // Draw the rising graph arrow
    _drawRisingArrow(canvas, size, strokePaint);
  }

  void _drawStylizedB(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    
    // Left vertical line of B
    final leftX = size.width * 0.15;
    final topY = size.height * 0.1;
    final bottomY = size.height * 0.9;
    final strokeWidth = size.width * 0.08;
    
    // Vertical stroke
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(leftX, topY, strokeWidth, bottomY - topY),
      Radius.circular(strokeWidth / 2),
    ));
    
    // Top curve of B
    final topCurveStart = leftX + strokeWidth;
    final topCurveEnd = size.width * 0.75;
    final topCurveHeight = size.height * 0.35;
    
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(topCurveStart, topY, topCurveEnd - topCurveStart, strokeWidth),
      Radius.circular(strokeWidth / 2),
    ));
    
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(topCurveEnd - strokeWidth, topY, strokeWidth, topCurveHeight - topY),
      Radius.circular(strokeWidth / 2),
    ));
    
    // Middle horizontal line
    final middleY = size.height * 0.5 - strokeWidth / 2;
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(topCurveStart, middleY, (topCurveEnd - topCurveStart) * 0.8, strokeWidth),
      Radius.circular(strokeWidth / 2),
    ));
    
    // Bottom curve of B
    final bottomCurveHeight = size.height * 0.65;
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(topCurveStart, bottomY - strokeWidth, topCurveEnd - topCurveStart, strokeWidth),
      Radius.circular(strokeWidth / 2),
    ));
    
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(topCurveEnd - strokeWidth, bottomCurveHeight, strokeWidth, bottomY - bottomCurveHeight),
      Radius.circular(strokeWidth / 2),
    ));
    
    canvas.drawPath(path, paint);
  }

  void _drawCurrencySymbol(Canvas canvas, Size size, Paint paint) {
    // Draw a subtle dollar sign integrated into the right side of the B
    final centerX = size.width * 0.82;
    final centerY = size.height * 0.5;
    final symbolHeight = size.height * 0.3;
    final symbolWidth = size.width * 0.08;
    
    // Vertical line of $
    canvas.drawLine(
      Offset(centerX, centerY - symbolHeight / 2),
      Offset(centerX, centerY + symbolHeight / 2),
      paint,
    );
    
    // Top curve of $
    final topCurvePath = Path();
    topCurvePath.addArc(
      Rect.fromCenter(
        center: Offset(centerX - symbolWidth / 4, centerY - symbolHeight / 4),
        width: symbolWidth,
        height: symbolHeight / 3,
      ),
      -3.14159 / 2, // Start angle
      3.14159, // Sweep angle
    );
    canvas.drawPath(topCurvePath, paint);
    
    // Bottom curve of $
    final bottomCurvePath = Path();
    bottomCurvePath.addArc(
      Rect.fromCenter(
        center: Offset(centerX + symbolWidth / 4, centerY + symbolHeight / 4),
        width: symbolWidth,
        height: symbolHeight / 3,
      ),
      3.14159 / 2, // Start angle
      3.14159, // Sweep angle
    );
    canvas.drawPath(bottomCurvePath, paint);
  }

  void _drawRisingArrow(Canvas canvas, Size size, Paint paint) {
    // Draw a small rising arrow in the top-right corner
    final arrowSize = size.width * 0.15;
    final arrowX = size.width * 0.85;
    final arrowY = size.height * 0.15;
    
    final arrowPath = Path();
    
    // Arrow line going up and right
    arrowPath.moveTo(arrowX - arrowSize, arrowY + arrowSize);
    arrowPath.lineTo(arrowX, arrowY);
    
    // Arrow head
    arrowPath.moveTo(arrowX - arrowSize * 0.4, arrowY);
    arrowPath.lineTo(arrowX, arrowY);
    arrowPath.lineTo(arrowX, arrowY + arrowSize * 0.4);
    
    canvas.drawPath(arrowPath, paint);
    
    // Small graph bars
    final barWidth = size.width * 0.02;
    final barSpacing = size.width * 0.025;
    final baseY = arrowY + arrowSize * 0.8;
    
    for (int i = 0; i < 3; i++) {
      final barHeight = (i + 1) * arrowSize * 0.15;
      final barX = arrowX - arrowSize * 0.8 + i * (barWidth + barSpacing);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, baseY - barHeight, barWidth, barHeight),
          Radius.circular(barWidth / 2),
        ),
        paint..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Animated version of the logo for splash screen
class AnimatedAppLogo extends StatefulWidget {
  final double size;
  final Color? color;
  final bool showBackground;
  final Duration duration;

  const AnimatedAppLogo({
    super.key,
    this.size = 80,
    this.color,
    this.showBackground = true,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<AnimatedAppLogo> createState() => _AnimatedAppLogoState();
}

class _AnimatedAppLogoState extends State<AnimatedAppLogo>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: Duration(milliseconds: widget.duration.inMilliseconds ~/ 2),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
    
    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _rotationController.forward().then((_) {
      _rotationController.reverse();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: AppLogo(
              size: widget.size,
              color: widget.color,
              showBackground: widget.showBackground,
            ),
          ),
        );
      },
    );
  }
}