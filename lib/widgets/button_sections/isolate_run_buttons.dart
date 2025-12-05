import 'package:flutter/material.dart';

class IsolateRunButtons extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onHeavyWithIsolateRun;
  final VoidCallback onCompare;

  const IsolateRunButtons({
    super.key,
    required this.isBusy,
    required this.onHeavyWithIsolateRun,
    required this.onCompare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Isolate.run() - сучасний API',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: isBusy ? null : onHeavyWithIsolateRun,
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Isolate.run()'),
            ),
            ElevatedButton.icon(
              onPressed: isBusy ? null : onCompare,
              icon: const Icon(Icons.compare_arrows, size: 18),
              label: const Text('compute() vs Isolate.run()'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

