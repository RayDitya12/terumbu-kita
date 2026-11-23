import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';

/// Barang untuk mini-game Pilah Cepat (spec.md §6.1 layar 6).
/// [recyclable] = bisa dipakai ulang (true) atau sekali pakai (false).
class SortItem {
  const SortItem(this.label, {required this.recyclable});
  final String label;
  final bool recyclable;
}

const sortItems = <SortItem>[
  SortItem('Tumbler stainless', recyclable: true),
  SortItem('Sedotan plastik', recyclable: false),
  SortItem('Tas kain', recyclable: true),
  SortItem('Kantong kresek', recyclable: false),
  SortItem('Botol isi ulang', recyclable: true),
  SortItem('Gelas styrofoam', recyclable: false),
  SortItem('Wadah makan sendiri', recyclable: true),
  SortItem('Sendok plastik sekali pakai', recyclable: false),
  SortItem('Botol PET', recyclable: false),
  SortItem('Sedotan stainless', recyclable: true),
];

/// Mini-game edukatif 30 detik (spec.md §1: gamifikasi eksplisit ±20%).
/// CD7: cepat & acak; CD2: skor → XP.
class MiniGameScreen extends ConsumerStatefulWidget {
  const MiniGameScreen({super.key});

  @override
  ConsumerState<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends ConsumerState<MiniGameScreen> {
  static const totalDuration = Duration(seconds: 30);

  // Seed tetap agar urutan deck dapat direproduksi (berguna untuk tes).
  final _rng = math.Random(7);
  late final List<SortItem> _deck = [...sortItems]..shuffle(_rng);
  int _index = 0;
  int _score = 0;
  Duration _remaining = totalDuration;
  Timer? _timer;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining.inSeconds <= 1) {
        t.cancel();
        setState(() {
          _remaining = Duration.zero;
          _finished = true;
        });
      } else {
        setState(() => _remaining -= const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _answer(bool answerRecyclable) {
    if (_finished) return;
    final correct = _deck[_index].recyclable == answerRecyclable;
    setState(() {
      if (correct) _score += 1;
      _index += 1;
      if (_index >= _deck.length) _finished = true;
    });
    if (_finished) _timer?.cancel();
  }

  Future<void> _claimReward() async {
    await ref.read(progressProvider.notifier).addBonusXp(_score * 2);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = _finished;
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.miniGameTitle),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_remaining.inSeconds}s',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: done
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 72,
                    color: AppColors.coralInk,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.miniGameScoreText(_score),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.miniGameRewardNote(_score * 2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('claim-reward'),
                    onPressed: _claimReward,
                    child: const Text(AppStrings.miniGameClaim),
                  ),
                ],
              )
            : Column(
                children: [
                  Text(
                    AppStrings.miniGamePrompt,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _deck[_index].label,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          key: const Key('answer-once'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.sunYellow,
                            foregroundColor: AppColors.ink,
                            minimumSize: const Size(0, 64),
                          ),
                          onPressed: () => _answer(false),
                          child: const Text(AppStrings.miniGameOnce),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          key: const Key('answer-reuse'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            minimumSize: const Size(0, 64),
                          ),
                          onPressed: () => _answer(true),
                          child: const Text(AppStrings.miniGameReuse),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
