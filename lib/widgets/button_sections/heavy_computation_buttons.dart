import 'package:flutter/material.dart';

class HeavyComputationButtons extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onHeavyInMainIsolate;
  final VoidCallback onHeavyInSeparateIsolate;
  final VoidCallback onCompare;

  const HeavyComputationButtons({
    super.key,
    required this.isBusy,
    required this.onHeavyInMainIsolate,
    required this.onHeavyInSeparateIsolate,
    required this.onCompare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'ПРИКЛАД 3.2: Важкі обчислення',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: isBusy ? null : onHeavyInMainIsolate,
              icon: const Icon(Icons.warning, size: 18),
              label: const Text('В головному ізоляті'),
            ),
            ElevatedButton.icon(
              onPressed: isBusy ? null : onHeavyInSeparateIsolate,
              icon: const Icon(Icons.check_circle, size: 18),
              label: const Text('В окремому ізоляті'),
            ),
            ElevatedButton.icon(
              onPressed: isBusy ? null : onCompare,
              icon: const Icon(Icons.speed, size: 18),
              label: const Text('Порівняння'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

