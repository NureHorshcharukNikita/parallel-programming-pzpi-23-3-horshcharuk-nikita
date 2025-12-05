import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../isolates/compute_functions.dart';
import '../isolates/background_isolate.dart';

class IsolatesService {
  Isolate? _currentIsolate;
  final Function(String) onLog;

  IsolatesService({required this.onLog});

  void appendLog(String text) {
    onLog('${DateTime.now().toString().substring(11, 19)}: $text\n');
  }

  String generateBigJson({int count = 10000}) {
    final list = List.generate(count, (i) {
      return {
        'id': i,
        'name': 'Product $i',
        'price': (i % 100) + 0.99,
      };
    });
    return jsonEncode(list);
  }

  Future<void> parseWithoutCompute() async {
    appendLog('=== ПРИКЛАД 3.1: Парсинг БЕЗ compute() ===');
    appendLog('Початок парсингу в головному ізоляті...');

    final jsonString = generateBigJson(count: 10000);

    final sw = Stopwatch()..start();
    try {
      final List<dynamic> data = jsonDecode(jsonString) as List<dynamic>;
      final products = data
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
      sw.stop();

      appendLog('[OK] Кількість продуктів: ${products.length}');
      appendLog('[OK] Час парсингу БЕЗ compute(): ${sw.elapsedMilliseconds} мс');
      appendLog('[NOTE] UI міг "підвисати" під час парсингу');
    } catch (e) {
      sw.stop();
      appendLog('[ERROR] Помилка: $e');
    }
  }

  Future<void> parseWithCompute() async {
    appendLog('=== ПРИКЛАД 3.1: Парсинг З compute() ===');
    appendLog('Початок парсингу в окремому ізоляті...');

    final jsonString = generateBigJson(count: 10000);

    final sw = Stopwatch()..start();
    try {
      final products = await compute(parseProducts, jsonString);
      sw.stop();

      appendLog('[OK] Кількість продуктів: ${products.length}');
      appendLog('[OK] Час парсингу З compute(): ${sw.elapsedMilliseconds} мс');
      appendLog('[OK] UI залишався плавним під час парсингу');
    } catch (e) {
      sw.stop();
      appendLog('[ERROR] Помилка: $e');
    }
  }

  Future<void> compareJsonParsing() async {
    appendLog('=== ПОРІВНЯННЯ: Парсинг JSON БЕЗ vs З compute() ===');
    appendLog('Тестування обох підходів...');
    appendLog('');

    final jsonString = generateBigJson(count: 10000);

    appendLog('ТЕСТ 1: Парсинг БЕЗ compute() (в головному ізоляті)');
    appendLog('[NOTE] UI буде "підвисати" під час парсингу!');
    final sw1 = Stopwatch()..start();
    try {
      final List<dynamic> data = jsonDecode(jsonString) as List<dynamic>;
      final products1 = data
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
      sw1.stop();
      appendLog('[OK] Кількість продуктів: ${products1.length}');
      appendLog('Час парсингу БЕЗ compute(): ${sw1.elapsedMilliseconds} мс');
      appendLog('[NOTE] UI міг "підвисати" під час парсингу');
    } catch (e) {
      sw1.stop();
      appendLog('[ERROR] Помилка: $e');
    }
    appendLog('');

    await Future.delayed(const Duration(milliseconds: 500));

    appendLog('ТЕСТ 2: Парсинг З compute() (в окремому ізоляті)');
    final sw2 = Stopwatch()..start();
    try {
      final products2 = await compute(parseProducts, jsonString);
      sw2.stop();
      appendLog('[OK] Кількість продуктів: ${products2.length}');
      appendLog('Час парсингу З compute(): ${sw2.elapsedMilliseconds} мс');
      appendLog('[OK] UI залишався плавним під час парсингу');
    } catch (e) {
      sw2.stop();
      appendLog('[ERROR] Помилка: $e');
    }
    appendLog('');

    appendLog('-----------------------------------');
    appendLog('ВИСНОВОК:');
    appendLog('-----------------------------------');
    appendLog('БЕЗ compute(): UI блокується під час парсингу');
    appendLog('З compute(): UI залишається плавним');
    appendLog('[INFO] compute() використовує окреме ядро процесора');
    appendLog('-----------------------------------');
  }

  Future<void> heavyInMainIsolate() async {
    appendLog('=== ПРИКЛАД 3.2: Важке обчислення в головному ізоляті ===');
    appendLog('Початок важкого обчислення...');
    appendLog('[NOTE] UI буде "фризити" під час виконання!');

    const n = 20000000;

    final sw = Stopwatch()..start();
    try {
      final sum = heavySumMainIsolate(n);
      sw.stop();

      appendLog('[OK] Результат суми: $sum');
      final mainTime = sw.elapsedMilliseconds;
      appendLog('[OK] Час обчислення в головному ізоляті: $mainTime мс');
      appendLog('[NOTE] UI був заблокований під час виконання');
      appendLog('[INFO] Обчислення виконувалися в головному потоці (блокували UI)');
    } catch (e) {
      sw.stop();
      appendLog('[ERROR] Помилка: $e');
    }
  }

  Future<void> heavyInSeparateIsolate() async {
    appendLog('=== ПРИКЛАД 3.2: Важке обчислення в окремому ізоляті ===');
    appendLog('Створення робочого ізолята...');

    final receivePort = ReceivePort();
    final sw = Stopwatch()..start();
    final completer = Completer<void>();

    try {
      final isolate =
          await Isolate.spawn(heavyComputationEntryPoint, receivePort.sendPort);
      _currentIsolate = isolate;

      appendLog('[OK] Ізолят створено');

      SendPort? workerSendPort;

      receivePort.listen((message) {
        if (message is SendPort) {
          workerSendPort = message;
          appendLog('[OK] Отримано SendPort робочого ізолята');

          const count = 20000000;
          appendLog('Надсилання діапазону 0..$count до ізолята...');
          
          workerSendPort!.send({
            'start': 0,
            'end': count,
          });
          appendLog('[OK] Діапазон надіслано, обчислення виконується в ізоляті...');
        } else if (message is int) {
          sw.stop();

          appendLog('[OK] Результат суми з окремого ізолята: $message');
          final isolateTime = sw.elapsedMilliseconds;
          appendLog('[OK] Час обчислення в окремому ізоляті: $isolateTime мс');
          appendLog('[OK] UI залишався плавним (можна було скролити під час виконання)');
          appendLog('[INFO] Паралельне виконання використовує окреме ядро процесора');

          receivePort.close();
          isolate.kill(priority: Isolate.immediate);
          _currentIsolate = null;
          
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      });

      await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          sw.stop();
          appendLog('[WARNING] Обчислення не завершилися за 30 секунд');
          receivePort.close();
          if (_currentIsolate != null) {
            _currentIsolate!.kill(priority: Isolate.immediate);
            _currentIsolate = null;
          }
        },
      );
    } catch (e) {
      sw.stop();
      appendLog('[ERROR] Помилка: $e');
      receivePort.close();
      if (_currentIsolate != null) {
        _currentIsolate!.kill(priority: Isolate.immediate);
        _currentIsolate = null;
      }
    }
  }

  Future<void> parallelComputation() async {
    appendLog('=== ПРИКЛАД: Паралельне виконання кількох частин задачі ===');
    appendLog('Розділяємо задачу на 4 частини і виконуємо їх ПАРАЛЕЛЬНО');
    appendLog('Це демонструє справжню перевагу багатоядерних процесорів!');
    appendLog('');

    const totalN = 40000000;
    const parts = 4;

    appendLog('ТЕСТ 1: Послідовне виконання (в головному ізоляті)');
    final sw1 = Stopwatch()..start();
    int sequentialResult = 0;
    for (int part = 0; part < parts; part++) {
      final start = (totalN * part) ~/ parts;
      final end = (totalN * (part + 1)) ~/ parts;
      sequentialResult += computeRange(start, end);
    }
    sw1.stop();
    final sequentialTime = sw1.elapsedMilliseconds;
    appendLog('[OK] Результат: $sequentialResult');
    appendLog('Час послідовного виконання: $sequentialTime мс');
    appendLog('[NOTE] Виконувалося в одному потоці, UI був заблокований');
    appendLog('');

    await Future.delayed(const Duration(milliseconds: 500));

    appendLog('ТЕСТ 2: Паралельне виконання (4 ізоляти одночасно)');
    appendLog('[INFO] Кожен ізолят працює на своєму ядрі процесора');
    final sw2 = Stopwatch()..start();

    try {
      final futures = <Future<int>>[];
      for (int part = 0; part < parts; part++) {
        final start = (totalN * part) ~/ parts;
        final end = (totalN * (part + 1)) ~/ parts;
        
        futures.add(compute(computeRangeTopLevel, {'start': start, 'end': end}));
      }

      final results = await Future.wait(futures);
      final parallelResult = results.fold<int>(0, (sum, value) => sum + value);
      
      sw2.stop();
      final parallelTime = sw2.elapsedMilliseconds;

      appendLog('[OK] Результат: $parallelResult');
      appendLog('Час паралельного виконання: $parallelTime мс');
      appendLog('[OK] UI залишався плавним');
      appendLog('');

      appendLog('-----------------------------------');
      appendLog('ПОРІВНЯННЯ РЕЗУЛЬТАТІВ:');
      appendLog('-----------------------------------');
      appendLog('Послідовне виконання:  $sequentialTime мс');
      appendLog('Паралельне виконання:  $parallelTime мс');

      if (parallelTime < sequentialTime) {
        final speedup = (sequentialTime / parallelTime).toStringAsFixed(2);
        appendLog('[SUCCESS] Паралельний підхід ШВИДШЕ в $speedup разів!');
        appendLog('[INFO] Використано ${parts} ядер процесора одночасно');
      } else {
        final overhead = (parallelTime - sequentialTime);
        appendLog('[INFO] Накладні витрати: $overhead мс');
        appendLog('[INFO] Але UI залишався плавним');
      }
      appendLog('-----------------------------------');
    } catch (e) {
      sw2.stop();
      appendLog('[ERROR] Помилка: $e');
    }
  }

  Future<void> compareIsolates() async {
    appendLog('=== АВТОМАТИЧНЕ ПОРІВНЯННЯ ===');
    appendLog('Тестування обох підходів для демонстрації переваг паралелізму...');
    appendLog('');

    const n = 20000000;

    appendLog('ТЕСТ 1: Обчислення в головному ізоляті');
    final sw1 = Stopwatch()..start();
    final result1 = heavySumMainIsolate(n);
    sw1.stop();
    final mainTime = sw1.elapsedMilliseconds;
    appendLog('[OK] Результат: $result1');
    appendLog('Час виконання: $mainTime мс');
    appendLog('[NOTE] UI був заблокований');
    appendLog('');

    await Future.delayed(const Duration(milliseconds: 500));

    appendLog('ТЕСТ 2: Обчислення в окремому ізоляті');
    final receivePort = ReceivePort();
    final sw2 = Stopwatch()..start();

    try {
      final isolate = await Isolate.spawn(
        heavyComputationEntryPoint,
        receivePort.sendPort,
      );
      _currentIsolate = isolate;

      final completer = Completer<void>();

      receivePort.listen((message) {
        if (message is SendPort) {
          final workerSendPort = message;
          workerSendPort.send({
            'start': 0,
            'end': n,
          });
        } else if (message is int) {
          sw2.stop();
          final isolateTime = sw2.elapsedMilliseconds;
          final result2 = message;

          appendLog('[OK] Результат: $result2');
          appendLog('Час виконання: $isolateTime мс');
          appendLog('[OK] UI залишався плавним');

          receivePort.close();
          isolate.kill(priority: Isolate.immediate);
          _currentIsolate = null;

          appendLog('');
          appendLog('-----------------------------------');
          appendLog('ПОРІВНЯННЯ РЕЗУЛЬТАТІВ:');
          appendLog('-----------------------------------');
          appendLog('Головний ізолят:    $mainTime мс');
          appendLog('Окремий ізолят:     $isolateTime мс');

          if (isolateTime < mainTime) {
            final speedup = (mainTime / isolateTime).toStringAsFixed(2);
            appendLog('[SUCCESS] Паралельний підхід ШВИДШЕ в $speedup разів!');
            appendLog('[INFO] Використовується окреме ядро процесора');
          } else {
            final overhead = (isolateTime - mainTime);
            appendLog('[INFO] Накладні витрати на створення ізолята: $overhead мс');
            appendLog('[INFO] Але UI залишався плавним');
          }
          appendLog('-----------------------------------');

          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      });

      await completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          sw2.stop();
          appendLog('[WARNING] Обчислення не завершилися за 60 секунд');
          receivePort.close();
          if (_currentIsolate != null) {
            _currentIsolate!.kill(priority: Isolate.immediate);
            _currentIsolate = null;
          }
        },
      );
    } catch (e) {
      sw2.stop();
      appendLog('[ERROR] Помилка: $e');
      receivePort.close();
      if (_currentIsolate != null) {
        _currentIsolate!.kill(priority: Isolate.immediate);
        _currentIsolate = null;
      }
    }
  }

  Future<void> heavyWithIsolateRun() async {
    appendLog('=== Isolate.run() - сучасний API для ізолятів ===');
    appendLog('Початок важкого обчислення через Isolate.run()...');

    const n = 20000000;

    final sw = Stopwatch()..start();
    try {
      final result = await heavyComputationWithIsolateRun(n);
      sw.stop();

      appendLog('[OK] Результат: $result');
      appendLog('[OK] Час обчислення через Isolate.run(): ${sw.elapsedMilliseconds} мс');
      appendLog('[OK] UI залишався плавним');
      appendLog('[INFO] Isolate.run() - це сучасний API, еквівалентний compute()');
    } catch (e) {
      sw.stop();
      appendLog('[ERROR] Помилка: $e');
    }
  }

  Future<void> compareComputeVsIsolateRun() async {
    appendLog('=== ПОРІВНЯННЯ: compute() vs Isolate.run() ===');
    appendLog('Тестування обох підходів для парсингу JSON...');
    appendLog('');

    final jsonString = generateBigJson(count: 10000);

    appendLog('ТЕСТ 1: Парсинг через compute()');
    final sw1 = Stopwatch()..start();
    try {
      final products1 = await compute(parseProducts, jsonString);
      sw1.stop();
      appendLog('[OK] Кількість продуктів: ${products1.length}');
      appendLog('Час через compute(): ${sw1.elapsedMilliseconds} мс');
    } catch (e) {
      sw1.stop();
      appendLog('[ERROR] Помилка: $e');
    }
    appendLog('');

    await Future.delayed(const Duration(milliseconds: 500));

    appendLog('ТЕСТ 2: Парсинг через Isolate.run() (через compute)');
    final sw2 = Stopwatch()..start();
    try {
      final products2 = await compute(parseProducts, jsonString);
      sw2.stop();
      appendLog('[OK] Кількість продуктів: ${products2.length}');
      appendLog('Час через compute() (Isolate.run() всередині): ${sw2.elapsedMilliseconds} мс');
    } catch (e) {
      sw2.stop();
      appendLog('[ERROR] Помилка: $e');
    }
    appendLog('');

    appendLog('-----------------------------------');
    appendLog('ВИСНОВОК:');
    appendLog('-----------------------------------');
    appendLog('compute() використовує Isolate.run() всередині');
    appendLog('compute() - зручніший для Flutter (з flutter/foundation)');
    appendLog('Isolate.run() - сучасніший API (Dart 3+), але потребує top-level функцій');
    appendLog('-----------------------------------');
  }

  Future<void> findPrimesWithCompute() async {
    appendLog('=== ДОДАТКОВИЙ ПРИКЛАД: Пошук простих чисел через compute() ===');
    appendLog('Початок пошуку простих чисел...');

    const maxNumber = 50000;

    final sw = Stopwatch()..start();
    try {
      final primes = await compute(findPrimesIsolate, maxNumber);
      sw.stop();

      appendLog('[OK] Знайдено простих чисел: ${primes.length}');
      appendLog('[OK] Перші 10: ${primes.take(10).toList()}');
      appendLog('[OK] Останні 10: ${primes.skip(primes.length - 10).toList()}');
      appendLog('[OK] Час обчислення: ${sw.elapsedMilliseconds} мс');
      appendLog('[OK] UI залишався плавним');
    } catch (e) {
      sw.stop();
      appendLog('[ERROR] Помилка: $e');
    }
  }

  Future<void> comparePrimesSequentialVsParallel() async {
    appendLog('=== ПОРІВНЯННЯ: Пошук простих чисел (послідовно vs паралельно) ===');
    appendLog('Тестування обох підходів для демонстрації переваг паралелізму...');
    appendLog('');

    const maxNumber = 100000;
    const parts = 4;
    int sequentialTime = 0;

    appendLog('ТЕСТ 1: Послідовний пошук простих чисел (в головному ізоляті)');
    appendLog('[NOTE] UI буде "підвисати" під час виконання!');
    final sw1 = Stopwatch()..start();
    try {
      final primes1 = findPrimes(maxNumber);
      sw1.stop();
      sequentialTime = sw1.elapsedMilliseconds;
      appendLog('[OK] Знайдено простих чисел: ${primes1.length}');
      appendLog('Час послідовного виконання: $sequentialTime мс');
      appendLog('[NOTE] Виконувалося в одному потоці, UI був заблокований');
      appendLog('[NOTE] Перші 5: ${primes1.take(5).toList()}');
      appendLog('[NOTE] Останні 5: ${primes1.skip(primes1.length - 5).toList()}');
    } catch (e) {
      sw1.stop();
      sequentialTime = sw1.elapsedMilliseconds;
      appendLog('[ERROR] Помилка: $e');
    }
    appendLog('');

    await Future.delayed(const Duration(milliseconds: 500));

    appendLog('ТЕСТ 2: Паралельний пошук простих чисел (4 ізоляти одночасно)');
    appendLog('[INFO] Кожен ізолят працює на своєму ядрі процесора');
    final sw2 = Stopwatch()..start();

    try {
      final futures = <Future<List<int>>>[];
      for (int part = 0; part < parts; part++) {
        final start = (maxNumber * part) ~/ parts;
        final end = (maxNumber * (part + 1)) ~/ parts;
        
        futures.add(compute(findPrimesInRange, {'start': start, 'end': end}));
      }

      final results = await Future.wait(futures);
      final parallelPrimes = <int>[];
      for (final primesList in results) {
        parallelPrimes.addAll(primesList);
      }
      parallelPrimes.sort();
      
      sw2.stop();
      final parallelTime = sw2.elapsedMilliseconds;

      appendLog('[OK] Знайдено простих чисел: ${parallelPrimes.length}');
      appendLog('Час паралельного виконання: $parallelTime мс');
      appendLog('[OK] UI залишався плавним');
      appendLog('[NOTE] Перші 5: ${parallelPrimes.take(5).toList()}');
      appendLog('[NOTE] Останні 5: ${parallelPrimes.skip(parallelPrimes.length - 5).toList()}');
      appendLog('');

      appendLog('-----------------------------------');
      appendLog('ПОРІВНЯННЯ РЕЗУЛЬТАТІВ:');
      appendLog('-----------------------------------');
      appendLog('Послідовне виконання:  $sequentialTime мс');
      appendLog('Паралельне виконання:  $parallelTime мс');

      if (sequentialTime > 0 && parallelTime < sequentialTime) {
        final speedup = (sequentialTime / parallelTime).toStringAsFixed(2);
        final timeSaved = sequentialTime - parallelTime;
        appendLog('[SUCCESS] Паралельний підхід ШВИДШЕ в $speedup разів!');
        appendLog('[SUCCESS] Економія часу: $timeSaved мс');
        appendLog('[INFO] Використано ${parts} ядер процесора одночасно');
      } else if (sequentialTime > 0) {
        final overhead = (parallelTime - sequentialTime);
        appendLog('[INFO] Накладні витрати: $overhead мс');
        appendLog('[INFO] Але UI залишався плавним (головна перевага)');
        appendLog('[INFO] Послідовний варіант блокував UI, паралельний - ні');
      }
      appendLog('-----------------------------------');
    } catch (e) {
      sw2.stop();
      appendLog('[ERROR] Помилка: $e');
    }
  }

  Future<void> startBackgroundIsolate() async {
    appendLog('=== ДОДАТКОВИЙ ПРИКЛАД ===');
    appendLog('Спроба запустити background ізолят...');

    final sw = Stopwatch()..start();

    try {
      final rootIsolateToken = RootIsolateToken.instance;
      if (rootIsolateToken == null) {
        sw.stop();
        appendLog('[ERROR] RootIsolateToken недоступний');
        appendLog('[NOTE] Для повноцінного background isolate потрібен плагін');
        appendLog('   (наприклад, workmanager або flutter_background_service)');
        return;
      }

      appendLog('[OK] Отримано RootIsolateToken');

      final isolate = await Isolate.spawn(
        backgroundIsolateEntry,
        rootIsolateToken,
      );
      _currentIsolate = isolate;

      final spawnTime = sw.elapsedMilliseconds;
      appendLog('[OK] Background ізолят запущено (час створення: ${spawnTime} мс)');
      appendLog('[OK] Ізолят має доступ до плагінів (наприклад, SharedPreferences)');

      await Future.delayed(const Duration(seconds: 1));
      final prefs = await SharedPreferences.getInstance();
      final isRunning = prefs.getBool('backgroundIsolateRunning') ?? false;
      final time = prefs.getString('backgroundIsolateTime') ?? 'не встановлено';

      if (isRunning) {
        final checkTime = sw.elapsedMilliseconds;
        appendLog('[OK] Background ізолят успішно записав дані');
        appendLog('[OK] Час запуску background isolate: $time');
        appendLog('Час до перевірки даних: ${checkTime} мс');
      }

      await Future.delayed(const Duration(seconds: 2));
      isolate.kill(priority: Isolate.immediate);
      _currentIsolate = null;
      sw.stop();
      appendLog('[OK] Background ізолят зупинено');
      appendLog('Загальний час виконання: ${sw.elapsedMilliseconds} мс');
    } catch (e) {
      sw.stop();
      appendLog('[ERROR] Помилка: $e');
      appendLog('[NOTE] Для повноцінного background isolate потрібен плагін');
      appendLog('Час до помилки: ${sw.elapsedMilliseconds} мс');
      if (_currentIsolate != null) {
        _currentIsolate!.kill(priority: Isolate.immediate);
        _currentIsolate = null;
      }
    }
  }

  void dispose() {
    if (_currentIsolate != null) {
      _currentIsolate!.kill(priority: Isolate.immediate);
      _currentIsolate = null;
    }
  }
}

