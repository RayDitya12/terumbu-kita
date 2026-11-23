import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/constants/game_rules.dart';
import '../../core/constants/visual_config.dart';

/// Unit B: spesies karang prosedural (tanpa aset eksternal — agent.md §8).
/// Spesies baru terbuka seiring naiknya tahap terumbu.
enum CoralSpecies { branching, seaweed, table, brain, seaFan }

const Map<ReefStage, List<CoralSpecies>> _stageSpecies = {
  ReefStage.tunas: [CoralSpecies.branching, CoralSpecies.seaweed],
  ReefStage.tumbuh: [
    CoralSpecies.branching,
    CoralSpecies.seaweed,
    CoralSpecies.table,
  ],
  ReefStage.subur: [
    CoralSpecies.branching,
    CoralSpecies.seaweed,
    CoralSpecies.table,
    CoralSpecies.brain,
  ],
  ReefStage.ekosistem: [
    CoralSpecies.branching,
    CoralSpecies.seaweed,
    CoralSpecies.table,
    CoralSpecies.brain,
    CoralSpecies.seaFan,
  ],
};

/// Bentuk satu karang yang sudah "diacak" sekali (tidak digambar ulang
/// per frame — item kinerja Unit B: nol alokasi di paint()).
class CoralSpec {
  const CoralSpec({
    required this.x,
    required this.height,
    required this.colorIndex,
    required this.species,
    required this.seed,
    required this.phase,
  });

  /// Posisi dasar sebagai fraksi lebar (0..1).
  final double x;

  /// Tinggi sebagai fraksi area karang (0..1).
  final double height;
  final int colorIndex;
  final CoralSpecies species;

  /// Biji acak bentuk (cabang, alur, kipas).
  final double seed;

  /// Fase untuk animasi goyang (rumput laut, pita cahaya).
  final double phase;
}

class BubbleSpec {
  const BubbleSpec({
    required this.x,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.depth,
  });

  final double x;
  final double radius;
  final double speed;
  final double phase;

  /// Kedalaman semu 0..1: memengaruhi ukuran, opasitas, dan goyang (parallax).
  final double depth;
}

class RockSpec {
  const RockSpec({required this.x, required this.width, required this.height});
  final double x;
  final double width;
  final double height;
}

/// Susunan tetap terumbu untuk satu tahap. Dibangun ulang hanya saat
/// tahap/jumlah gelembung berubah, bukan per frame.
class ReefLayout {
  const ReefLayout({
    required this.corals,
    required this.bubbles,
    required this.rocks,
  });

  ReefLayout.build({required ReefStage stage, required int bubbleCount})
    : this(
        corals: _buildCorals(stage),
        bubbles: _buildBubbles(bubbleCount),
        rocks: _buildRocks(),
      );

  final List<CoralSpec> corals;
  final List<BubbleSpec> bubbles;
  final List<RockSpec> rocks;

  static const _coralCount = {
    ReefStage.tunas: 4,
    ReefStage.tumbuh: 7,
    ReefStage.subur: 11,
    ReefStage.ekosistem: 15,
  };

  static List<CoralSpec> _buildCorals(ReefStage stage) {
    final rng = math.Random(7);
    final unlocked = _stageSpecies[stage]!;
    final count = _coralCount[stage]!;
    return List.generate(count, (i) {
      return CoralSpec(
        x: (i + 0.5) / count + rng.nextDouble() * 0.05 - 0.025,
        height: 0.5 + rng.nextDouble() * 0.3,
        colorIndex: i % ReefPainter.palette.length,
        species: unlocked[i % unlocked.length],
        seed: rng.nextDouble() * 1000,
        phase: rng.nextDouble() * math.pi * 2,
      );
    });
  }

  static List<BubbleSpec> _buildBubbles(int count) {
    final rng = math.Random(42);
    return List.generate(count, (i) {
      return BubbleSpec(
        x: rng.nextDouble(),
        radius: 2 + rng.nextDouble() * 6,
        speed: 0.03 + rng.nextDouble() * 0.06,
        phase: rng.nextDouble(),
        depth:
            ((i % VisualConfig.bubbleParallaxLayers) + rng.nextDouble()) /
            VisualConfig.bubbleParallaxLayers,
      );
    });
  }

  static List<RockSpec> _buildRocks() {
    final rng = math.Random(11);
    return List.generate(5, (i) {
      return RockSpec(
        x: (i + 0.5) / 5 + rng.nextDouble() * 0.08 - 0.04,
        width: 26 + rng.nextDouble() * 34,
        height: 10 + rng.nextDouble() * 12,
      );
    });
  }
}

/// Status visual yang dibagikan ReefScene ke painter. Painter melanggankan
/// dirinya ke objek ini sehingga perubahan dari luar (health, burst) ikut
/// memicu repaint tanpa membuat instance painter baru.
class ReefVisualState extends ChangeNotifier {
  ReefVisualState({required this.layout});

  ReefLayout layout;
  double time = 0;
  int health = 100;
  double growth = 0;

  /// Progres burst gelembung setelah aksi dicatat; >= 1 berarti selesai.
  double burst = 1;

  /// Progres "scale-in" karang terbaru; >= 1 berarti penuh.
  double pop = 1;

  /// Progres kilatan cahaya saat naik level; >= 1 berarti selesai.
  double flash = 1;

  ui.FragmentProgram? causticsProgram;

  /// Pita/caustics shader; mati pada mode Minimal.
  bool showCaustics = true;

  /// Berkas cahaya; hanya hidup pada mode Penuh.
  bool showRays = true;

  void mutate(void Function() update) {
    update();
    notifyListeners();
  }
}

/// Pelukis terumbu Unit B: dasar laut berpasir + batu, pita cahaya
/// (shader caustics dengan fallback), 5 spesies karang prosedural,
/// gelembung parallax, burst aksi, dan kilatan level.
///
/// CD4: karang ini *milik* pengguna — tumbuh sedikit tiap aksi (growth),
/// spesies baru terbuka per tahap, warna memudar mengikuti [health] (CD8).
class ReefPainter extends CustomPainter {
  ReefPainter(this.state) : super(repaint: state);

  final ReefVisualState state;

  static const palette = [
    Color(0xFFFF8A65),
    Color(0xFF4DD0E1),
    Color(0xFFAED581),
    Color(0xFFFFD54F),
    Color(0xFFBA68C8),
    Color(0xFFF48FB1),
    Color(0xFF80CBC4),
  ];

  static const _tau = math.pi * 2;
  static const _sandTop = 22.0;

  // Semua Paint dan Path di-cache: paint() tidak boleh mengalokasi.
  final Paint _stroke = Paint()
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;
  final Paint _fill = Paint()..style = PaintingStyle.fill;
  final Path _path = Path();
  final Paint _layer = Paint();
  bool _silhouette = false;
  ui.FragmentShader? _shader;
  List<Color>? _bleachedPalette;
  List<Color>? _detailPalette;
  int _bleachedForHealth = -1;
  static const _silhouetteColor = Color(0xFFFFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final s = state;
    final groundY = size.height - _sandTop;
    _drawSeabed(canvas, size, s);
    _drawCorals(canvas, size, groundY, s);
    // Rays setelah dasar: berkas cahaya tampak menyambung sampai ke pasir.
    if (s.showRays) _drawLightRays(canvas, size, s);
    // Caustics setelah karang: pola cahaya dipotong tepat pada siluet
    // karang + pasir (layer dstIn), bukan aura di sekitarnya.
    if (s.showCaustics) _drawCaustics(canvas, size, groundY, s);
    _drawBubbles(canvas, size, groundY, s);
    _drawBurst(canvas, size, groundY, s);
    _drawFlash(canvas, size, s);
  }

  Color _color(int index, ReefVisualState s) {
    _ensurePalettes(s);
    return _bleachedPalette![index % _bleachedPalette!.length];
  }

  /// Warna aksen (polip, alur, pita) yang tetap terlihat saat karang
  /// memutih — bleaching asli masih menampilkan struktur keabuan.
  Color _detailColor(int index, ReefVisualState s) {
    _ensurePalettes(s);
    return _detailPalette![index % _detailPalette!.length];
  }

  void _ensurePalettes(ReefVisualState s) {
    final health = s.health;
    if (_bleachedForHealth != health) {
      // Cap 0.8: tubuh karang tidak pernah jadi putih datar 100%.
      final bleaching = math.min(0.8, (100 - health).clamp(0, 100) / 100.0);
      _bleachedPalette = [
        for (final c in palette) ui.Color.lerp(c, Colors.white, bleaching)!,
      ];
      _detailPalette = [
        for (final c in _bleachedPalette!)
          ui.Color.lerp(c, const Color(0xFF54707F), 0.45)!,
      ];
      _bleachedForHealth = health;
    }
  }

  double get _vitality => (state.health / 100).clamp(0.15, 1.0);

  // ---------------------------------------------------------------- cahaya

  /// Caustics hanya menempel TEPAT di bentuk karang dan pasir: siluet asli
  /// dirender ke layer lalu pola cahaya dipotong dengan BlendMode.dstIn.
  void _drawCaustics(
    Canvas canvas,
    Size size,
    double groundY,
    ReefVisualState s,
  ) {
    canvas.saveLayer(Offset.zero & size, _layer);
    _silhouette = true;
    _drawSeabed(canvas, size, s);
    _drawCorals(canvas, size, groundY, s);
    _silhouette = false;
    final program = s.causticsProgram;
    if (program != null) {
      final shader = _shader ??= program.fragmentShader();
      shader
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, s.time)
        ..setFloat(3, 0.55 * _vitality);
      _fill
        ..shader = shader
        ..blendMode = BlendMode.dstIn;
      canvas.drawRect(Offset.zero & size, _fill);
      _fill
        ..shader = null
        ..blendMode = BlendMode.srcOver;
    } else {
      _drawCausticsFallback(canvas, size, s);
    }
    canvas.restore();
  }

  /// Fallback dua lapis pita cahaya bergeser berlawanan (item 3 Unit B),
  /// ikut ter-potong oleh layer siluet saat mode Hemat.
  void _drawCausticsFallback(Canvas canvas, Size size, ReefVisualState s) {
    final alpha = 0.06 * _vitality;
    for (var layer = 0; layer < 2; layer++) {
      final dir = layer == 0 ? 1.0 : -1.0;
      final drift = s.time * 0.35 * dir + layer * 2.1;
      for (var band = 0; band < 4; band++) {
        final baseY = size.height * (0.42 + 0.14 * band) + layer * 10;
        _path
          ..reset()
          ..moveTo(0, baseY);
        for (var x = 20.0; x <= size.width; x += 40) {
          _path.quadraticBezierTo(
            x - 20,
            baseY + math.sin(x * 0.02 + drift + band) * 14,
            x,
            baseY + math.sin((x + 20) * 0.02 + drift + band) * 14,
          );
        }
        // Pita tipis: garis tebal, bukan area terisi.
        _stroke
          ..color = Colors.white.withValues(alpha: alpha)
          ..strokeWidth = 7
          ..blendMode = BlendMode.dstIn;
        canvas.drawPath(_path, _stroke);
      }
    }
    _stroke.blendMode = BlendMode.srcOver;
  }

  void _drawLightRays(Canvas canvas, Size size, ReefVisualState s) {
    for (var i = 0; i < 3; i++) {
      final sway = math.sin(s.time * 0.11 + i * 2.4) * size.width * 0.03;
      final top = size.width * (0.22 + 0.28 * i) + sway;
      final bottom = top + size.width * 0.09 * (i.isEven ? 1 : -1);
      _path
        ..reset()
        ..moveTo(top - 7, 0)
        ..lineTo(top + 7, 0)
        ..lineTo(bottom + 46, size.height)
        ..lineTo(bottom - 46, size.height)
        ..close();
      _fill.color = Colors.white.withValues(
        alpha: (0.05 + 0.025 * math.sin(s.time * 0.17 + i * 1.9)) * _vitality,
      );
      canvas.drawPath(_path, _fill);
    }
  }

  // ----------------------------------------------------------------- dasar

  void _drawSeabed(Canvas canvas, Size size, ReefVisualState s) {
    final top = size.height - _sandTop;
    _path
      ..reset()
      ..moveTo(0, top + 4);
    for (var x = 0.0; x <= size.width; x += 48) {
      _path.quadraticBezierTo(
        x + 24,
        top + math.sin(x * 0.02 + 1.3) * 5,
        x + 48,
        top + 4,
      );
    }
    _path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    _fill.color = _silhouette ? _silhouetteColor : const Color(0x73FFE0B2);
    canvas.drawPath(_path, _fill);
    for (final rock in s.layout.rocks) {
      final cx = rock.x * size.width;
      _fill.color = _silhouette
          ? _silhouetteColor
          : const Color(0xFF33566A).withValues(alpha: 0.55 + 0.25 * _vitality);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, top + 6),
          width: rock.width,
          height: rock.height,
        ),
        _fill,
      );
    }
  }

  // ---------------------------------------------------------------- karang

  void _drawCorals(
    Canvas canvas,
    Size size,
    double groundY,
    ReefVisualState s,
  ) {
    final areaHeight = size.height * 0.58;
    final scale = 0.82 + 0.18 * s.growth;
    final corals = s.layout.corals;
    // Dua pass: spesies besar (meja/otak) di belakang, yang ramping di depan.
    for (var pass = 0; pass < 2; pass++) {
      final backPass = pass == 0;
      for (var i = 0; i < corals.length; i++) {
        final spec = corals[i];
        final isBack =
            spec.species == CoralSpecies.table ||
            spec.species == CoralSpecies.brain;
        if (isBack != backPass) continue;
        // Karang terbaru (indeks terakhir) "tumbuh" saat pop < 1.
        final popScale = i == corals.length - 1 ? _easeOut(s.pop) : 1.0;
        final factor = scale * popScale;
        final color = _silhouette
            ? _silhouetteColor
            : _color(spec.colorIndex, s);
        final detail = _silhouette
            ? _silhouetteColor
            : _detailColor(spec.colorIndex, s);
        final base = Offset(
          size.width * 0.05 + spec.x * size.width * 0.9,
          groundY + 6,
        );
        final height = areaHeight * spec.height * factor;
        switch (spec.species) {
          case CoralSpecies.branching:
            _drawBranching(canvas, base, height, color, detail, spec, s);
          case CoralSpecies.seaweed:
            _drawSeaweed(canvas, base, height, color, detail, spec, s);
          case CoralSpecies.table:
            _drawTable(canvas, base, height, color, detail, spec);
          case CoralSpecies.brain:
            _drawBrain(canvas, base, height, color, detail, spec);
          case CoralSpecies.seaFan:
            _drawSeaFan(canvas, base, height, color, detail, spec);
        }
      }
    }
  }

  void _drawBranching(
    Canvas canvas,
    Offset base,
    double height,
    Color color,
    Color detail,
    CoralSpec spec,
    ReefVisualState s,
  ) {
    final rng = math.Random(spec.seed.toInt());
    _stroke
      ..color = color
      ..style = PaintingStyle.stroke;
    _branch(
      canvas,
      start: base,
      angle: -math.pi / 2 + (rng.nextDouble() * 0.2 - 0.1),
      length: height / 3,
      depthRemaining: 3,
      rng: rng,
      polyps: 1 + (s.growth * 2).round(),
      detail: detail,
    );
  }

  void _branch(
    Canvas canvas, {
    required Offset start,
    required double angle,
    required double length,
    required int depthRemaining,
    required math.Random rng,
    required int polyps,
    required Color detail,
  }) {
    _stroke.strokeWidth = 2.5 + depthRemaining * 3.0;
    final end = start + Offset(math.cos(angle), math.sin(angle)) * length;
    _path
      ..reset()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(
        (start.dx + end.dx) / 2 + rng.nextDouble() * 16 - 8,
        (start.dy + end.dy) / 2,
        end.dx,
        end.dy,
      );
    canvas.drawPath(_path, _stroke);
    if (depthRemaining == 1) {
      _fill.color = _stroke.color;
      final tip = 4 + _stroke.strokeWidth * 0.55;
      canvas.drawCircle(end, tip, _fill);
      // CD4: polip tambahan muncul saat growth naik dalam tahap.
      _fill.color = detail;
      for (var p = 0; p < polyps; p++) {
        final a = rng.nextDouble() * _tau;
        final d = tip + 3 + rng.nextDouble() * 4;
        canvas.drawCircle(
          end + Offset(math.cos(a) * d, math.sin(a) * d),
          1.8 + rng.nextDouble(),
          _fill,
        );
      }
      return;
    }
    for (final spread in [-0.75, -0.1, 0.55]) {
      _branch(
        canvas,
        start: end,
        angle: angle + spread + (rng.nextDouble() * 0.24 - 0.12),
        length: length * (0.62 + rng.nextDouble() * 0.1),
        depthRemaining: depthRemaining - 1,
        rng: rng,
        polyps: polyps,
        detail: detail,
      );
    }
  }

  void _drawSeaweed(
    Canvas canvas,
    Offset base,
    double height,
    Color color,
    Color detail,
    CoralSpec spec,
    ReefVisualState s,
  ) {
    _stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    for (var ribbon = 0; ribbon < 3; ribbon++) {
      _stroke.color = ribbon == 1 ? detail : color;
      final offset = (ribbon - 1) * 6.0;
      final sway = math.sin(s.time * 1.1 + spec.phase + ribbon) * 10;
      _path
        ..reset()
        ..moveTo(base.dx + offset, base.dy);
      var x = base.dx + offset;
      var y = base.dy;
      for (var seg = 1; seg <= 3; seg++) {
        final nextY = base.dy - height * seg / 3;
        final midX = x + sway * (seg.isEven ? 0.6 : -0.6);
        _path.quadraticBezierTo(midX, (y + nextY) / 2, x + sway * 0.3, nextY);
        x = x + sway * 0.3;
        y = nextY;
      }
      canvas.drawPath(_path, _stroke);
    }
  }

  void _drawTable(
    Canvas canvas,
    Offset base,
    double height,
    Color color,
    Color detail,
    CoralSpec spec,
  ) {
    final top = base - Offset(0, height);
    _stroke
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    _path
      ..reset()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(base.dx + 8, top.dy + height * 0.5, top.dx, top.dy);
    canvas.drawPath(_path, _stroke);
    final width = height * 0.95 + 10;
    _fill.color = color;
    canvas.drawOval(
      Rect.fromCenter(center: top, width: width, height: width * 0.22),
      _fill,
    );
    _stroke
      ..color = detail
      ..strokeWidth = 3;
    canvas.drawOval(
      Rect.fromCenter(center: top, width: width, height: width * 0.22),
      _stroke,
    );
    // Tangkai cabang kecil khas karang meja.
    _stroke.color = color;
    _path
      ..reset()
      ..moveTo(top.dx - width * 0.3, top.dy)
      ..lineTo(top.dx - width * 0.34, top.dy - 10)
      ..moveTo(top.dx + width * 0.25, top.dy)
      ..lineTo(top.dx + width * 0.3, top.dy - 8);
    canvas.drawPath(_path, _stroke);
  }

  void _drawBrain(
    Canvas canvas,
    Offset base,
    double height,
    Color color,
    Color detail,
    CoralSpec spec,
  ) {
    final mound = Rect.fromCenter(
      center: base - Offset(0, height * 0.24),
      width: height * 0.85,
      height: height * 0.58,
    );
    _fill.color = color;
    canvas.drawOval(mound, _fill);
    // Alur berkelok: empat pita horizontal, terpotong sesuai lebar oval.
    _stroke
      ..color = detail
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    final rng = math.Random(spec.seed.toInt());
    final cx = mound.center.dx;
    for (var g = 0; g < 4; g++) {
      final gy =
          mound.center.dy - mound.height * 0.28 + mound.height * 0.19 * g;
      final k = ((gy - mound.center.dy) / (mound.height / 2)).clamp(-0.9, 0.9);
      final halfW = mound.width / 2 * math.sqrt(1 - k * k) - 5;
      final w = halfW * 2;
      _path
        ..reset()
        ..moveTo(cx - halfW, gy);
      for (var x = 0.25; x <= 1.0; x += 0.25) {
        _path.quadraticBezierTo(
          cx - halfW + w * (x - 0.125),
          gy + (g.isEven ? 5 : -5) * (0.6 + rng.nextDouble() * 0.8),
          cx - halfW + w * x,
          gy,
        );
      }
      canvas.drawPath(_path, _stroke);
    }
  }

  void _drawSeaFan(
    Canvas canvas,
    Offset base,
    double height,
    Color color,
    Color detail,
    CoralSpec spec,
  ) {
    _stroke
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6;
    const ribs = 7;
    // Ruas-ruas kipas: garis melengkung menyebar dari pangkal.
    for (var i = 0; i < ribs; i++) {
      final t = i / (ribs - 1);
      final angle = -math.pi / 2 + (t - 0.5) * 1.5;
      final tip = base + Offset.fromDirection(angle, height);
      _path
        ..reset()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(
          base.dx + math.cos(angle) * height * 0.45 - 6,
          base.dy + math.sin(angle) * height * 0.55,
          tip.dx,
          tip.dy,
        );
      canvas.drawPath(_path, _stroke);
    }
    // Hubungan antar-ribs (jaring).
    _stroke
      ..color = detail
      ..strokeWidth = 1.6;
    for (final level in [0.45, 0.7]) {
      _path.reset();
      for (var i = 0; i < ribs; i++) {
        final t = i / (ribs - 1);
        final angle = -math.pi / 2 + (t - 0.5) * 1.5;
        final p = base + Offset.fromDirection(angle, height * level);
        if (i == 0) {
          _path.moveTo(p.dx, p.dy);
        } else {
          _path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(_path, _stroke);
    }
  }

  // ------------------------------------------------------------- gelembung

  void _drawBubbles(
    Canvas canvas,
    Size size,
    double groundY,
    ReefVisualState s,
  ) {
    _stroke
      ..color = Colors.white
      ..style = PaintingStyle.stroke;
    for (final b in s.layout.bubbles) {
      final cycle = (s.time * b.speed + b.phase) % 1.0;
      final y = groundY - cycle * (groundY - 8);
      final wobble = math.sin(s.time * (1.2 + b.speed * 10) + b.phase * _tau);
      final x = b.x * size.width + wobble * (2 + 6 * b.depth);
      final r = b.radius * (0.55 + 0.75 * b.depth);
      _stroke.strokeWidth = 1.4 + b.depth;
      _stroke.color = Colors.white.withValues(
        alpha: (0.06 + 0.14 * b.depth) * _vitality,
      );
      canvas.drawCircle(Offset(x, y), r, _stroke);
    }
  }

  void _drawBurst(Canvas canvas, Size size, double groundY, ReefVisualState s) {
    if (s.burst >= 1) return;
    final p = _easeOut(s.burst);
    final alpha = (1 - s.burst) * 0.45;
    final center = Offset(size.width / 2, groundY - 10);
    final spread = 16 + p * size.width * 0.45;
    _stroke
      ..color = Colors.white.withValues(alpha: alpha)
      ..strokeWidth = 2;
    for (var i = 0; i < 14; i++) {
      final a = i * _tau / 14 + 0.3;
      final pos =
          center + Offset(math.cos(a) * spread, math.sin(a) * spread * 0.6);
      canvas.drawCircle(pos, 5 * (1 - p) + 1.5, _stroke);
    }
  }

  void _drawFlash(Canvas canvas, Size size, ReefVisualState s) {
    if (s.flash >= 1) return;
    _fill.color = Colors.white.withValues(alpha: (1 - s.flash) * 0.3);
    canvas.drawRect(Offset.zero & size, _fill);
  }

  double _easeOut(double t) =>
      1 - math.pow(1 - t.clamp(0.0, 1.0), 3).toDouble();

  @override
  bool shouldRepaint(covariant ReefPainter oldDelegate) =>
      oldDelegate.state != state;
}
