import 'package:flutter/material.dart';

class AdditionalExamplesButtons extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onFindPrimes;
  final VoidCallback onBackgroundIsolate;

  const AdditionalExamplesButtons({
    super.key,
    required this.isBusy,
    required this.onFindPrimes,
    required this.onBackgroundIsolate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'ДОДАТКОВІ ПРИКЛАДИ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: isBusy ? null : onFindPrimes,
              icon: const Icon(Icons.calculate, size: 18),
              label: const Text('Прості числа (compute)'),
            ),
            ElevatedButton.icon(
              onPressed: isBusy ? null : onBackgroundIsolate,
              icon: const Icon(Icons.settings_backup_restore, size: 18),
              label: const Text('Background isolate'),
            ),
          ],
        ),
      ],
    );
  }
}

