import 'package:flutter/material.dart';

import 'app.dart';
import 'services/logger_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    LoggerService.instance.error('FlutterError', details.exception, details.stack);
  };
  runApp(const GpImmoApp());
}
