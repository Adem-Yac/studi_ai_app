import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/app_settings.dart';
import 'app/connectivity_monitor.dart';
import 'app/firebase_bootstrap.dart';
import 'core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    initializeDateFormatting('fr'),
    initializeDateFormatting('en'),
    initializeDateFormatting('ar'),
  ]);
  await initFirebaseSafely();
  await AppSettings.load();
  await configureDependencies();
  await ConnectivityMonitor.start();
  runApp(const StudyAIApp());
}
