import 'package:flutter/material.dart';

import 'src/app/app_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await createAppDependencies();
  runApp(MacGyverApp(dependencies: dependencies));
}
