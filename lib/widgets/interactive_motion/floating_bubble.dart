import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Ambient floating particles / glowing orbs / paw prints that drift gently.
class FloatingAmbientParticles extends StatefulWidget {
  final int count;
  final Color particleColor;
  final Widget child;

  const FloatingAmbientParticles({
    super.key,
    this.count = 6,
    this.particleColor = Colors.white,
    required this.child,
  });

  @override
  State<FloatingAmbientParticles> createState() => _FloatingAmbientParticlesState();
}

class _FloatingAmbientParticlesState extends State<FloatingAmbientParticles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _rnd = math.Random(42);

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.count; i++) {
      _particles.add(_Particle(
        x: _rnd.nextDouble(),
        y: _rnd.nextDouble(),
        size: _rnd.nextDouble() * 14 + 6,
        speed: _rnd.nextDouble() * 0.4 + 0.2,
        phase: _rnd.nextDouble() * 2 * math.pi,
        opacity: _rnd.nextDouble() * 0.25 + 0.12,
      ));
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _ParticlePainter(
                  particles: _particles,
                  progress: _controller.value,
                  baseColor: widget.particleColor,
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double speed;
  double phase;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color baseColor;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final currentY = (p.y - progress * p.speed) % 1.0;
      final currentX = p.x + 0.05 * math.sin(progress * 2 * math.pi + p.phase);

      final px = currentX * size.width;
      final py = currentY * size.height;

      final paint = Paint()
        ..color = baseColor.withValues(alpha: p.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

      canvas.drawCircle(Offset(px, py), p.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
