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
      ReefStage.tunas => 4,
      ReefStage.tumbuh => 7,
      ReefStage.subur => 11,
      ReefStage.ekosistem => 15,
    };
    final depth = switch (stage) {
      ReefStage.tunas => 2,
      ReefStage.tumbuh => 3,
      ReefStage.subur || ReefStage.ekosistem => 4,
    };
    final rng = math.Random(7);
    final groundY = size.height - 10;
    for (var i = 0; i < count; i++) {
      final baseX = size.width * (i + 0.5) / count + rng.nextDouble() * 24 - 12;
      final height = size.height * (0.55 + rng.nextDouble() * 0.28);
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
    _drawBubbles(canvas, size, rng);
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
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    // Batang utama tegak, lalu bercabang kipas dari ujungnya.
    _branch(
      canvas,
      paint,
      start: base,
      angle: -math.pi / 2 + (rng.nextDouble() * 0.2 - 0.1),
      length: height / depth,
      depthRemaining: depth,
      rng: rng,
    );
  }

  void _branch(
    Canvas canvas,
    Paint paint, {
    required Offset start,
    required double angle,
    required double length,
    required int depthRemaining,
    required math.Random rng,
  }) {
    paint.strokeWidth = 2.5 + depthRemaining * 3.5;
    final end = start + Offset(math.cos(angle), math.sin(angle)) * length;
    final control =
        start +
        Offset.fromDirection(angle, length * 0.5) +
        Offset(rng.nextDouble() * 16 - 8, 0);
    canvas.drawPath(
      Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy),
      paint,
    );
    if (depthRemaining == 1) {
      canvas.drawCircle(
        end,
        4 + paint.strokeWidth * 0.6,
        Paint()
          ..color = paint.color
          ..style = PaintingStyle.fill,
      );
      return;
    }
    for (final spread in [-0.75, -0.1, 0.55]) {
      _branch(
        canvas,
        paint,
        start: end,
        angle: angle + spread + (rng.nextDouble() * 0.24 - 0.12),
        length: length * (0.62 + rng.nextDouble() * 0.1),
        depthRemaining: depthRemaining - 1,
        rng: rng,
      );
    }
  }

  /// Gelembung samar agar area laut tidak terasa kosong (CD4: dunia hidup).
  void _drawBubbles(Canvas canvas, Size size, math.Random rng) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i < 10; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.55;
      canvas.drawCircle(Offset(x, y), 3 + rng.nextDouble() * 7, paint);
    }
  }

  void _drawSand(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x59FFE0B2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height - 14, size.width, 14),
        const Radius.circular(8),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant ReefPainter oldDelegate) =>
      oldDelegate.stage != stage || oldDelegate.health != health;
}
