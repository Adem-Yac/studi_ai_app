import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Suivi léger de l'état réseau (online/offline) exposé via [online].
abstract final class ConnectivityMonitor {
  static final online = ValueNotifier<bool>(true);
  static StreamSubscription<List<ConnectivityResult>>? _sub;

  static Future<void> start() async {
    try {
      final result = await Connectivity().checkConnectivity();
      online.value = _isOnline(result);
      _sub ??= Connectivity().onConnectivityChanged.listen((r) {
        online.value = _isOnline(r);
      });
    } catch (_) {
      online.value = true; // par défaut optimiste
    }
  }

  static bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  static Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}
