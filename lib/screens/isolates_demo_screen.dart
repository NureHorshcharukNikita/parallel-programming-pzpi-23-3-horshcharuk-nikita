import 'package:flutter/material.dart';
import '../services/isolates_service.dart';
import '../widgets/log_viewer.dart';
import '../widgets/buttons_panel.dart';

class IsolatesDemoScreen extends StatefulWidget {
  const IsolatesDemoScreen({super.key});

  @override
  State<IsolatesDemoScreen> createState() => _IsolatesDemoScreenState();
}

class _IsolatesDemoScreenState extends State<IsolatesDemoScreen> {
  String _log = '';
  bool _isBusy = false;
  late IsolatesService _service;

  @override
  void initState() {
    super.initState();
    _service = IsolatesService(onLog: _appendLog);
  }

  void _appendLog(String text) {
    setState(() {
      _log += text;
    });
  }

  void _clearLog() {
    setState(() {
      _log = '';
    });
  }

  Future<void> _runWithBusyState(Future<void> Function() action) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dart Isolates Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isBusy)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: LinearProgressIndicator(),
              ),
            Flexible(
              child: LogViewer(log: _log),
            ),
            const Divider(height: 1),
            Expanded(
              child: ButtonsPanel(
                isBusy: _isBusy,
                onParseWithoutCompute: () => _runWithBusyState(_service.parseWithoutCompute),
                onParseWithCompute: () => _runWithBusyState(_service.parseWithCompute),
                onCompareJsonParsing: () => _runWithBusyState(_service.compareJsonParsing),
                onHeavyInMainIsolate: () => _runWithBusyState(_service.heavyInMainIsolate),
                onHeavyInSeparateIsolate: () => _runWithBusyState(_service.heavyInSeparateIsolate),
                onCompareIsolates: () => _runWithBusyState(_service.compareIsolates),
                onHeavyWithIsolateRun: () => _runWithBusyState(_service.heavyWithIsolateRun),
                onCompareComputeVsIsolateRun: () => _runWithBusyState(_service.compareComputeVsIsolateRun),
                onParallelComputation: () => _runWithBusyState(_service.parallelComputation),
                onFindPrimes: () => _runWithBusyState(_service.findPrimesWithCompute),
                onBackgroundIsolate: () => _runWithBusyState(_service.startBackgroundIsolate),
                onClearLog: _clearLog,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
