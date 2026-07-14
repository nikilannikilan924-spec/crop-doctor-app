import 'dart:math';
import 'package:flutter/material.dart';

class RiskGauge extends StatelessWidget {
  final String riskLevel;
  final double value;
  final double size;

  const RiskGauge({
    super.key,
    required this.riskLevel,
    this.value = 0,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    final riskValue = _riskValue;
    return SizedBox(
      width: size,
      height: size * 0.6,
      child: CustomPaint(
        painter: _GaugePainter(
          riskValue: riskValue,
          riskColor: _riskColor,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: size * 0.15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(riskValue * 100).round()}%',
                  style: TextStyle(
                    fontSize: size * 0.12,
                    fontWeight: FontWeight.bold,
                    color: _riskColor,
                  ),
                ),
                Text(
                  riskLevel.toUpperCase(),
                  style: TextStyle(
                    fontSize: size * 0.06,
                    fontWeight: FontWeight.w600,
                    color: _riskColor.withOpacity(0.8),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double get _riskValue {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return 0.85;
      case 'medium':
        return 0.5;
      default:
        return 0.15;
    }
  }

  Color get _riskColor {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return const Color(0xFFF44336);
      case 'medium':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFF4CAF50);
    }
  }
}

class _GaugePainter extends CustomPainter {
  final double riskValue;
  final Color riskColor;

  _GaugePainter({required this.riskValue, required this.riskColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 10;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      bgPaint,
    );

    // Risk color zones
    final greenPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * 0.3,
      false,
      greenPaint,
    );

    final yellowPaint = Paint()
      ..color = const Color(0xFFFFC107).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi + pi * 0.3,
      pi * 0.35,
      false,
      yellowPaint,
    );

    final redPaint = Paint()
      ..color = const Color(0xFFF44336).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi + pi * 0.65,
      pi * 0.35,
      false,
      redPaint,
    );

    // Active value arc
    final activePaint = Paint()
      ..color = riskColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * riskValue,
      false,
      activePaint,
    );

    // Needle
    final needleAngle = pi + pi * riskValue;
    final needlePaint = Paint()
      ..color = riskColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center,
      Offset(
        center.dx + cos(needleAngle) * (radius - 15),
        center.dy + sin(needleAngle) * (radius - 15),
      ),
      needlePaint,
    );

    // Center dot
    canvas.drawCircle(center, 8, Paint()..color = riskColor);
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.riskValue != riskValue;
}
