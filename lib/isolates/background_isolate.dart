import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void backgroundIsolateEntry(RootIsolateToken token) async {
  try {
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('backgroundIsolateRunning', true);
    final now = DateTime.now();
    final timeString = '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';
    await prefs.setString('backgroundIsolateTime', timeString);

    print('Background isolate запущено: $timeString');
  } catch (e) {
    print('Помилка в background isolate: $e');
  }
}

