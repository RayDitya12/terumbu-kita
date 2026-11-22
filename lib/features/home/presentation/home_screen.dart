import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Bukti bahwa Clock sudah menjadi sumber waktu utama (Tahap 2+ menampilkan
    // terumbu, streak, dan XP bar di sini).
    final today = ref.watch(clockProvider).today;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: Center(
        child: Text(
          'Terumbu akan tumbuh di sini — hari: '
          '${today.day}/${today.month}/${today.year}',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
