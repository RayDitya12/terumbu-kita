import 'package:flutter/material.dart';

/// Layar sementara sampai fiturnya dibangun di tahap berikutnya (spec.md §12).
class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    super.key,
    required this.title,
    required this.stageNote,
  });

  final String title;
  final String stageNote;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            stageNote,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
