import 'package:flutter/material.dart';

class JsonParsingButtons extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onParseWithoutCompute;
  final VoidCallback onParseWithCompute;
  final VoidCallback onCompare;

  const JsonParsingButtons({
    super.key,
    required this.isBusy,
    required this.onParseWithoutCompute,
    required this.onParseWithCompute,
    required this.onCompare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'ПРИКЛАД 3.1: Парсинг JSON',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: isBusy ? null : onParseWithoutCompute,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('БЕЗ compute()'),
            ),
            ElevatedButton.icon(
              onPressed: isBusy ? null : onParseWithCompute,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('З compute()'),
            ),
            ElevatedButton.icon(
              onPressed: isBusy ? null : onCompare,
              icon: const Icon(Icons.compare_arrows, size: 18),
              label: const Text('Порівняння'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

