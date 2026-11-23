import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/game_rules.dart';
import '../../core/providers.dart';
import '../../core/utils/game_logic.dart';
import '../../data/models/app_settings.dart';
import 'reef_painter.dart';

/// Scene terumbu hidup untuk Home (Unit B).
///
/// Satu [AnimationController] menggerakkan semua animasi ambient; painter
/// tidak pernah dibuat ulang per frame (item kinerja 7). Animasi berhenti
/// saat tab lain aktif (IndexedStack men-mute Ticker), aplikasi di
/// background, atau pengguna memilih "Hemat"/nonaktifkan animasi sistem.
///
/// CD4/CD6: mencatat aksi memicu burst gelembung + karang baru tumbuh
/// (scale-in) + haptic — umpan balik instan bahwa dunia bereaksi.
class ReefScene extends ConsumerStatefulWidget {
  const ReefScene({super.key});

  @override
  ConsumerState<ReefScene> createState() => _ReefSceneState();
}

class _ReefSceneState extends ConsumerState<ReefScene>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  static const _loopSeconds = 120.0;
  static const _shaderAsset = 'assets/shaders/caustics.frag';

  late final AnimationController _controller;
  late final ReefVisualState _visual;
  late final ReefPainter _painter;

  ui.FragmentProgram? _program;
  ReefLayout? _layout;

  /// Waktu (detik scene) saat efek dimulai; efek selesai bila lewat durasinya.
  double _burstStart = -100;
  double _popStart = -100;
  double _flashStart = -100;

  int _lastActions = -1;
  int _lastLevel = -1;
  ReefStage? _layoutStage;
  int _layoutBubbles = -1;
  bool _motionAllowed = true;
  bool _pausedByLifecycle = false;

  @override
  void initState() {
    super.initState();
    _visual = ReefVisualState(
      layout: ReefLayout.build(stage: ReefStage.tunas, bubbleCount: 26),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..addListener(_onTick);
    _painter = ReefPainter(_visual);
    WidgetsBinding.instance.addObserver(this);
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(_shaderAsset);
      if (!mounted) return;
      _program = program;
      _visual.mutate(() => _visual.causticsProgram = _effectiveProgram);
    } catch (_) {
      // Shader gagal dimuat: painter otomatis memakai fallback pita cahaya.
    }
  }

  ui.FragmentProgram? get _effectiveProgram => _qualityFull ? _program : null;

  bool _qualityFull = true;

  void _onTick() {
    final t = _controller.value * _loopSeconds;
    _visual.mutate(() {
      _visual.time = t;
      _visual.burst = (t - _burstStart) / 1.4;
      _visual.pop = (t - _popStart) / 0.9;
      _visual.flash = (t - _flashStart) / 0.9;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motionAllowed = !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    _syncController();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _pausedByLifecycle =
        state != AppLifecycleState.resumed &&
        state != AppLifecycleState.inactive;
    _syncController();
  }

  void _syncController() {
    if (_motionAllowed && !_pausedByLifecycle) {
      _controller.repeat();
    } else {
      _controller.stop();
      // Render satu frame statis agar terumbu tetap tampil utuh.
      _visual.mutate(() {
        _visual.time = 12.0;
        _visual.burst = 1;
        _visual.pop = 1;
        _visual.flash = 1;
      });
    }
  }

  void _handleActionLogged() {
    final t = _visual.time;
    _burstStart = t;
    _popStart = t;
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _visual.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final progress = ref.watch(progressProvider);
    final stage = reefStageFor(progress.totalActions);
    final growth = reefGrowthFraction(progress.totalActions);
    final qualityFull = settings.effectQuality == EffectQuality.full;
    _qualityFull = qualityFull;

    // Susunan karang hanya dibangun ulang saat tahap/jumlah gelembung berubah.
    final bubbleTarget = _bubbleTarget(progress.reefHealth, qualityFull);
    if (stage != _layoutStage || bubbleTarget != _layoutBubbles) {
      _layoutStage = stage;
      _layoutBubbles = bubbleTarget;
      _layout = ReefLayout.build(stage: stage, bubbleCount: bubbleTarget);
    }

    // Hook state permainan (item 5 Unit B).
    var eventsChanged = false;
    if (_lastActions >= 0 && progress.totalActions > _lastActions) {
      if (_motionAllowed && !_pausedByLifecycle) {
        _handleActionLogged();
      }
      eventsChanged = true;
    }
    if (_lastLevel >= 0 && progress.level > _lastLevel && _motionAllowed) {
      _flashStart = _visual.time;
      eventsChanged = true;
    }
    _lastActions = progress.totalActions;
    _lastLevel = progress.level;

    _visual.mutate(() {
      _visual.health = progress.reefHealth;
      _visual.growth = growth;
      _visual.layout = _layout!;
      _visual.causticsProgram = _effectiveProgram;
      if (eventsChanged) {
        _visual.burst = (_visual.time - _burstStart) / 1.4;
        _visual.pop = (_visual.time - _popStart) / 0.9;
        _visual.flash = (_visual.time - _flashStart) / 0.9;
      }
    });

    return RepaintBoundary(
      child: CustomPaint(size: Size.infinite, painter: _painter),
    );
  }

  /// Hemat = separuh gelembung; karang memudar = lebih sedikit gelembung.
  int _bubbleTarget(int health, bool qualityFull) {
    final base = qualityFull ? 26 : 13;
    final vitality = 0.6 + 0.4 * (health / 100).clamp(0.0, 1.0);
    return (base * vitality).round();
  }
}
