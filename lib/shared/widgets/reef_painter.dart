import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/constants/game_rules.dart';

/// Menggambar terumbu karang prosedural (bukan aset berhak cipta —
/// agent.md §8: prioritas ilustrasi buatan sendiri).
///
/// CD4: karang ini *milik* pengguna — pertumbuhannya mengikuti tahap dan
/// warna memudar mengikuti [health] (CD8, bisa dipulihkan).
class ReefPainter extends CustomPainter {
  const ReefPainter({required this.stage, required this.health});

  final ReefStage stage;
  final int health;

  static const _palette = [
    Color(0xFFFF8A65),
    Color(0xFF4DD0E1),
    Color(0xFFAED581),
    Color(0xFFFFD54F),
    Color(0xFFBA68C8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final bleaching = (100 - health).clamp(0, 100) / 100.0;
    final count = switch (stage) {
      ReefStage.tunas => 3,
      ReefStage.tumbuh => 6,
      ReefStage.subur => 10,
      ReefStage.ekosistem => 14,
    };
    final depth = switch (stage) {
      ReefStage.tunas => 1,
      ReefStage.tumbuh => 2,
      ReefStage.subur || ReefStage.ekosistem => 3,
    };
    final rng = math.Random(7);
    final groundY = size.height;
    for (var i = 0; i < count; i++) {
      final baseX = size.width * (i + 0.5) / count + rng.nextDouble() * 24 - 12;
      final height = size.height * (0.16 + rng.nextDouble() * 0.14);
      final color = _palette[i % _palette.length];
      _drawCoral(
        canvas,
        base: Offset(baseX, groundY),
        height: height,
        depth: depth,
        color: ui.Color.lerp(color, Colors.white, bleaching)!,
        rng: rng,
      );
    }
    _drawSand(canvas, size);
  }

  void _drawCoral(
    Canvas canvas, {
    required Offset base,
    required double height,
    required int depth,
    required Color color,
    required math.Random rng,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    _branch(canvas, paint, base, Offset(0, -height / depth), depth, rng);
  }

  void _branch(
    Canvas canvas,
    Paint paint,
    Offset start,
    Offset vector,
    int depthRemaining,
    math.Random rng,
  ) {
    if (depthRemaining == 0) {
      paint.strokeWidth = 3;
      canvas.drawCircle(start + vector / 2, 3.5, Paint()..color = paint.color);
      return;
    }
    paint.strokeWidth = 2.0 + depthRemaining * 2.0;
    final control = start + vector * 0.5 + Offset(rng.nextDouble() * 16 - 8, 0);
    final end = start + vector;
    canvas.drawLine(start, control, paint);
    canvas.drawLine(control, end, paint);
    final shrink = 0.62;
    for (final angle in [-0.6, 0.15, 0.7]) {
      _branch(
        canvas,
        paint,
        end,
        _rotate(vector) * shrink + Offset(0, -vector.distance * 0.25 * angle),
        depthRemaining - 1,
        rng,
      );
    }
  }

  Offset _rotate(Offset v) =>
      Offset(-v.dy * 0.4, -v.dx.abs() * 0.35 - v.dy * 0.4);

  void _drawSand(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x33FFE0B2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height - 10, size.width, 10),
        const Radius.circular(6),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant ReefPainter oldDelegate) =>
      oldDelegate.stage != stage || oldDelegate.health != health;
}
