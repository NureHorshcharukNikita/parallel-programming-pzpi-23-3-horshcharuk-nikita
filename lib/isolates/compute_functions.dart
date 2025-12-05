import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

List<Product> parseProducts(String jsonString) {
  final List<dynamic> data = jsonDecode(jsonString) as List<dynamic>;
  return data
      .map((e) => Product.fromJson(e as Map<String, dynamic>))
      .toList();
}

void heavyComputationEntryPoint(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    if (message is Map<String, dynamic>) {
      final start = message['start'] as int;
      final end = message['end'] as int;
      
      int sum = 0;
      for (int i = start; i < end; i++) {
        sum += (i * i * i) ~/ 1000 + (i % 1000) * 2 + (i * i) % 10000;
      }
      
      sendPort.send(sum);
      receivePort.close();
    } else if (message == 'stop') {
      sendPort.send(0);
      receivePort.close();
    }
  });
}

int heavySumMainIsolate(int n) {
  int sum = 0;
  for (int i = 0; i < n; i++) {
    sum += (i * i * i) ~/ 1000 + (i % 1000) * 2 + (i * i) % 10000;
  }
  return sum;
}

List<int> findPrimes(int maxNumber) {
  final List<int> primes = [];
  for (int num = 2; num <= maxNumber; num++) {
    bool isPrime = true;
    for (int i = 2; i * i <= num; i++) {
      if (num % i == 0) {
        isPrime = false;
        break;
      }
    }
    if (isPrime) {
      primes.add(num);
    }
  }
  return primes;
}

List<int> findPrimesIsolate(int maxNumber) {
  return findPrimes(maxNumber);
}

int heavyComputationTopLevel(int n) {
  int sum = 0;
  for (int i = 0; i < n; i++) {
    sum += (i * i * i) ~/ 1000 + (i % 1000) * 2 + (i * i) % 10000;
  }
  return sum;
}

Future<int> heavyComputationWithIsolateRun(int n) async {
  return await compute(heavyComputationTopLevel, n);
}

int computeRangeTopLevel(Map<String, int> params) {
  final start = params['start']!;
  final end = params['end']!;
  int sum = 0;
  for (int i = start; i < end; i++) {
    sum += (i * i * i) ~/ 1000 + (i % 1000) * 2 + (i * i) % 10000;
  }
  return sum;
}

int computeRange(int start, int end) {
  int sum = 0;
  for (int i = start; i < end; i++) {
    sum += (i * i * i) ~/ 1000 + (i % 1000) * 2 + (i * i) % 10000;
  }
  return sum;
}

// Функція для пошуку простих чисел у діапазоні (для паралелізації)
List<int> findPrimesInRange(Map<String, int> params) {
  final start = params['start']!;
  final end = params['end']!;
  final List<int> primes = [];
  for (int num = start; num <= end; num++) {
    if (num < 2) continue;
    bool isPrime = true;
    for (int i = 2; i * i <= num; i++) {
      if (num % i == 0) {
        isPrime = false;
        break;
      }
    }
    if (isPrime) {
      primes.add(num);
    }
  }
  return primes;
}

