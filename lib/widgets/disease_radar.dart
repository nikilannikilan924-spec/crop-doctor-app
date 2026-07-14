import 'dart:math';
import 'package:flutter/material.dart';

class DiseaseRadar extends StatefulWidget {
  final String riskLevel;
  final double size;

  const DiseaseRadar({
    super.key,
    required this.riskLevel,
    this.size = 200,
  });

  @override
  State<DiseaseRadar> createState() => _DiseaseRadarState();
}

class _DiseaseRadarState extends State<DiseaseRadar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _riskColor {
    switch (widget.riskLevel.toLowerCase()) {
      case 'high':
        return const Color(0xFFF44336);
      case 'medium':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _RadarPainter(
              radarAngle: _controller.value * 2 * pi,
              riskColor: _riskColor,
              riskLevel: widget.riskLevel,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: _riskColor,
                    size: widget.size * 0.15,
                  ),
                  Text(
                    widget.riskLevel.toUpperCase(),
                    style: TextStyle(
                      fontSize: widget.size * 0.1,
                      fontWeight: FontWeight.bold,
                      color: _riskColor,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double radarAngle;
  final Color riskColor;
  final String riskLevel;

  _RadarPainter({
    required this.radarAngle,
    required this.riskColor,
    required this.riskLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background rings
    final bgPaint = Paint()
      ..color = Colors.green.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, bgPaint);

    // Concentric rings
    for (int i = 1; i <= 3; i++) {
      final ringPaint = Paint()
        ..color = Colors.grey.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(center, radius * i / 3, ringPaint);
    }

    // Cross lines
    final linePaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;
    canvas.drawLine(center, Offset(center.dx + radius, center.dy), linePaint);
    canvas.drawLine(center, Offset(center.dx - radius, center.dy), linePaint);
    canvas.drawLine(center, Offset(center.dx, center.dy + radius), linePaint);
    canvas.drawLine(center, Offset(center.dx, center.dy - radius), linePaint);

    // Color zones - green, yellow, red arcs
    final greenPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius), -pi, pi * 0.4, true, greenPaint);

    final yellowPaint = Paint()
      ..color = const Color(0xFFFFC107).withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius), -pi * 0.6, pi * 0.4, true, yellowPaint);

    final redPaint = Paint()
      ..color = const Color(0xFFF44336).withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius), -pi * 0.2, pi * 0.4, true, redPaint);

    // Sweeping radar beam
    final beamPaint = Paint()
      ..color = riskColor.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final beamPath = Path();
    beamPath.moveTo(center.dx, center.dy);
    beamPath.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      radarAngle - 0.3,
      0.6,
      true,
    );
    beamPath.close();
    canvas.drawPath(beamPath, beamPaint);

    // Radar line
    final radarLinePaint = Paint()
      ..color = riskColor.withOpacity(0.6)
      ..strokeWidth = 2;
    canvas.drawLine(
      center,
      Offset(
        center.dx + cos(radarAngle) * radius,
        center.dy + sin(radarAngle) * radius,
      ),
      radarLinePaint,
    );

    // Blip dots
    final blipPaint = Paint()
      ..color = riskColor
      ..style = PaintingStyle.fill;
    final blips = _generateBlips(center, radius);
    for (final blip in blips) {
      canvas.drawCircle(blip, 3, blipPaint);
    }

    // Outer ring
    final outerPaint = Paint()
      ..color = riskColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, outerPaint);
  }

  List<Offset> _generateBlips(Offset center, double radius) {
    final random = Random(42);
    final blips = <Offset>[];
    final count = riskLevel.toLowerCase() == 'high'
        ? 12
        : riskLevel.toLowerCase() == 'medium'
            ? 6
            : 2;
    for (int i = 0; i < count; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final dist = random.nextDouble() * radius * 0.8 + radius * 0.1;
      blips.add(Offset(
        center.dx + cos(angle) * dist,
        center.dy + sin(angle) * dist,
      ));
    }
    return blips;
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.radarAngle != radarAngle;
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
