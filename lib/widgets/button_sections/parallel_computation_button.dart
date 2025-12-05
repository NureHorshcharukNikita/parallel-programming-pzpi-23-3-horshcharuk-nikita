import 'package:flutter/material.dart';

class ParallelComputationButton extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onParallelComputation;

  const ParallelComputationButton({
    super.key,
    required this.isBusy,
    required this.onParallelComputation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'ПРИКЛАД: Справжній паралелізм',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        ElevatedButton.icon(
          onPressed: isBusy ? null : onParallelComputation,
          icon: const Icon(Icons.speed, size: 18),
          label: const Text('Паралельне виконання (4 ізоляти)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

