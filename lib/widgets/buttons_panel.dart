import 'package:flutter/material.dart';
import 'button_sections/json_parsing_buttons.dart';
import 'button_sections/heavy_computation_buttons.dart';
import 'button_sections/isolate_run_buttons.dart';
import 'button_sections/parallel_computation_button.dart';
import 'button_sections/additional_examples_buttons.dart';

class ButtonsPanel extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onParseWithoutCompute;
  final VoidCallback onParseWithCompute;
  final VoidCallback onCompareJsonParsing;
  final VoidCallback onHeavyInMainIsolate;
  final VoidCallback onHeavyInSeparateIsolate;
  final VoidCallback onCompareIsolates;
  final VoidCallback onHeavyWithIsolateRun;
  final VoidCallback onCompareComputeVsIsolateRun;
  final VoidCallback onParallelComputation;
  final VoidCallback onFindPrimes;
  final VoidCallback onBackgroundIsolate;
  final VoidCallback onClearLog;

  const ButtonsPanel({
    super.key,
    required this.isBusy,
    required this.onParseWithoutCompute,
    required this.onParseWithCompute,
    required this.onCompareJsonParsing,
    required this.onHeavyInMainIsolate,
    required this.onHeavyInSeparateIsolate,
    required this.onCompareIsolates,
    required this.onHeavyWithIsolateRun,
    required this.onCompareComputeVsIsolateRun,
    required this.onParallelComputation,
    required this.onFindPrimes,
    required this.onBackgroundIsolate,
    required this.onClearLog,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  JsonParsingButtons(
                    isBusy: isBusy,
                    onParseWithoutCompute: onParseWithoutCompute,
                    onParseWithCompute: onParseWithCompute,
                    onCompare: onCompareJsonParsing,
                  ),
                  const SizedBox(height: 12),
                  HeavyComputationButtons(
                    isBusy: isBusy,
                    onHeavyInMainIsolate: onHeavyInMainIsolate,
                    onHeavyInSeparateIsolate: onHeavyInSeparateIsolate,
                    onCompare: onCompareIsolates,
                  ),
                  const SizedBox(height: 12),
                  IsolateRunButtons(
                    isBusy: isBusy,
                    onHeavyWithIsolateRun: onHeavyWithIsolateRun,
                    onCompare: onCompareComputeVsIsolateRun,
                  ),
                  const SizedBox(height: 12),
                  ParallelComputationButton(
                    isBusy: isBusy,
                    onParallelComputation: onParallelComputation,
                  ),
                  const SizedBox(height: 12),
                  AdditionalExamplesButtons(
                    isBusy: isBusy,
                    onFindPrimes: onFindPrimes,
                    onBackgroundIsolate: onBackgroundIsolate,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: isBusy ? null : onClearLog,
            icon: const Icon(Icons.clear, size: 18),
            label: const Text('Очистити лог'),
          ),
        ],
      ),
    );
  }
}

