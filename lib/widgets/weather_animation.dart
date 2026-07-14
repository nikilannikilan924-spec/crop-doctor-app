import 'dart:math';
import 'package:flutter/material.dart';

class WeatherBackground extends StatefulWidget {
  final String weatherType;
  final Widget child;

  const WeatherBackground({
    super.key,
    required this.weatherType,
    required this.child,
  });

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initParticles();
  }

  void _initParticles() {
    _particles.clear();
    for (int i = 0; i < 30; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 4 + 2,
        speed: _random.nextDouble() * 0.02 + 0.01,
        opacity: _random.nextDouble() * 0.3 + 0.1,
      ));
    }
  }

  @override
  void didUpdateWidget(WeatherBackground old) {
    super.didUpdateWidget(old);
    if (old.weatherType != widget.weatherType) {
      _initParticles();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        for (final p in _particles) {
          p.y += p.speed;
          if (p.y > 1) {
            p.y = -0.05;
            p.x = _random.nextDouble();
          }
          if (widget.weatherType == 'rain') {
            p.x += sin(p.y * 10) * 0.001;
          }
        }
        return Stack(
          children: [
            // Background gradient based on weather
            Container(
              decoration: BoxDecoration(
                gradient: _getGradient(),
              ),
            ),
            // Particle overlay
            if (widget.weatherType == 'rain' || widget.weatherType == 'clouds')
              Positioned.fill(
                child: CustomPaint(
                  painter: _ParticlePainter(
                    particles: _particles,
                    weatherType: widget.weatherType,
                  ),
                ),
              ),
            // Sun rays for sunny weather
            if (widget.weatherType == 'sunny')
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.15 + sin(_controller.value * 2 * pi) * 0.05),
                        blurRadius: 100,
                        spreadRadius: 50,
                      ),
                    ],
                  ),
                ),
              ),
            // Content
            widget.child,
          ],
        );
      },
    );
  }

  LinearGradient _getGradient() {
    switch (widget.weatherType) {
      case 'rain':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blueGrey[900]!,
            Colors.blueGrey[700]!,
            Colors.blueGrey[600]!,
          ],
        );
      case 'clouds':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[700]!,
            Colors.grey[500]!,
            Colors.grey[400]!,
          ],
        );
      default:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF87CEEB),
            const Color(0xFFE0F7FA),
            const Color(0xFFC8E6C9),
          ],
        );
    }
  }
}

class _Particle {
  double x, y, size, speed, opacity;
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final String weatherType;

  _ParticlePainter({required this.particles, required this.weatherType});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = weatherType == 'rain'
            ? Colors.lightBlue.withOpacity(p.opacity)
            : Colors.white.withOpacity(p.opacity)
        ..strokeWidth = weatherType == 'rain' ? 1.5 : p.size;
      
      if (weatherType == 'rain') {
        canvas.drawLine(
          Offset(p.x * size.width, p.y * size.height),
          Offset(p.x * size.width + 3, p.y * size.height + 8),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}
