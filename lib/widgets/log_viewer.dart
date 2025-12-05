import 'package:flutter/material.dart';

class LogViewer extends StatelessWidget {
  final String log;

  const LogViewer({
    super.key,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Text(
          log.isEmpty ? 'Натисніть кнопку для запуску тесту...' : log,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: Colors.lightGreenAccent,
          ),
        ),
      ),
    );
  }
}

