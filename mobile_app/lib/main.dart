import 'package:flutter/material.dart';
import 'app.dart';
import 'core/network/service_locator.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all app dependencies (GetIt)
  await di.init();

  runApp(const ExamEaseApp());
}
